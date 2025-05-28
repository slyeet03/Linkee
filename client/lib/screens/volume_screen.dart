import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VolumeControlScreen extends StatelessWidget {
  final String serverIp;

  const VolumeControlScreen({super.key, required this.serverIp});

  Future<void> _volumeControl(BuildContext context, String action) async {
    try {
      await http.post(
        Uri.parse('http://$serverIp:8000/volume/control'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': action}),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildVolumeButton(
            context: context,
            icon: Icons.volume_off,
            action: 'mute',
          ),
          const SizedBox(width: 20),
          _buildVolumeButton(
            context: context,
            icon: Icons.volume_down,
            action: 'down',
          ),
          const SizedBox(width: 20),
          _buildVolumeButton(
            context: context,
            icon: Icons.volume_up,
            action: 'up',
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeButton({
    required BuildContext context,
    required IconData icon,
    required String action,
  }) {
    return ElevatedButton(
      onPressed: () => _volumeControl(context, action),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        fixedSize: const Size(60, 60),
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
      ),
      child: Icon(icon, size: 24),
    );
  }
}
