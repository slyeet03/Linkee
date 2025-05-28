import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/discovery_service.dart';
import 'home_screen.dart';

class ServerDiscoveryScreen extends StatefulWidget {
  const ServerDiscoveryScreen({super.key});

  @override
  State<ServerDiscoveryScreen> createState() => _ServerDiscoveryScreenState();
}

class _ServerDiscoveryScreenState extends State<ServerDiscoveryScreen> {
  String _status = "Searching for server...";
  String? _serverIp;
  bool _manualInput = false;
  final TextEditingController _ipController = TextEditingController();
  final DiscoveryService _discoveryService = DiscoveryService();

  @override
  void initState() {
    super.initState();
    _discoverServer();
  }

  Future<void> _discoverServer() async {
    final ip = await _discoveryService.discoverServer();
    if (ip != null) {
      setState(() {
        _serverIp = ip;
        _status = "Connected to $ip";
      });
      _navigateToMainApp();
    } else {
      setState(() {
        _status = "Server not found automatically";
        _manualInput = true;
      });
    }
  }

  void _navigateToMainApp() {
    if (_serverIp != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => UnifiedHomeScreen(serverIp: _serverIp!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_find, size: 60, color: Colors.blue),
              const SizedBox(height: 20),
              Text(_status, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              if (_manualInput) ...[
                TextField(
                  controller: _ipController,
                  decoration: const InputDecoration(
                    labelText: "Enter server IP",
                    hintText: "192.168.1.100",
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_ipController.text.isNotEmpty) {
                      final ip = _ipController.text;
                      if (await _discoveryService.testServerConnection(ip)) {
                        setState(() {
                          _serverIp = ip;
                          _status = "Connected to $ip";
                        });
                        _navigateToMainApp();
                      } else {
                        setState(() {
                          _status = "Connection failed, please check IP";
                        });
                      }
                    }
                  },
                  child: const Text("Connect"),
                ),
              ],
              if (!_manualInput) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
