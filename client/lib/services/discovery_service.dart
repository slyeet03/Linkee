// services/discovery_service.dart (fixed filename)
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DiscoveryService {
  Future<String?> discoverServer() async {
    // 1. Try last used IP first
    final prefs = await SharedPreferences.getInstance();
    final lastIp = prefs.getString('last_server_ip');
    
    if (lastIp != null && await testServerConnection(lastIp)) {
      return lastIp;
    }

    // 2. Try common IP ranges
    final commonIps = await _getCommonLocalIps();
    for (var ip in commonIps) {
      if (await testServerConnection(ip)) {
        await prefs.setString('last_server_ip', ip);
        return ip;
      }
    }

    return null;
  }

  Future<bool> testServerConnection(String ip) async {
    try {
      final url = Uri.parse('http://$ip:8000/status');
      final response = await http.get(url).timeout(const Duration(seconds: 1));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> _getCommonLocalIps() async {
    final interfaces = await NetworkInterface.list();
    final List<String> ips = [];

    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          final parts = addr.address.split('.');
          if (parts.length == 4) {
            for (int i = 1; i < 255; i++) {
              ips.add('${parts[0]}.${parts[1]}.${parts[2]}.$i');
            }
          }
        }
      }
    }

    return [
      ...ips.where((ip) => ip.endsWith('.1')),
      ...ips.where((ip) => ip.endsWith('.100')),
      ...ips.where((ip) => ip.endsWith('.200')),
      ...ips,
    ];
  }
}
