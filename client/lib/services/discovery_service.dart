import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DiscoveryService {
  Future<String?> discoverServer() async {
    final prefs = await SharedPreferences.getInstance();
    final lastIp = prefs.getString('last_server_ip');

    if (lastIp != null && await testServerConnection(lastIp)) {
      return lastIp;
    }

    final subnet = await _getLocalSubnet();
    if (subnet == null) return null;

    final futures = List.generate(254, (i) {
      final ip = '$subnet.${i + 1}';
      return testServerConnection(ip).then((ok) => ok ? ip : null);
    });

    final results = await Future.wait(futures);
    final found = results.whereType<String>().firstOrNull;

    if (found != null) {
      await prefs.setString('last_server_ip', found);
    }
    return found;
  }

  Future<bool> testServerConnection(String ip) async {
    try {
      final url = Uri.parse('http://$ip:8000/status');
      final response = await http.get(url).timeout(const Duration(milliseconds: 800));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> _getLocalSubnet() async {
    final interfaces = await NetworkInterface.list();
    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          final parts = addr.address.split('.');
          if (parts.length == 4) {
            return '${parts[0]}.${parts[1]}.${parts[2]}';
          }
        }
      }
    }
    return null;
  }
}
