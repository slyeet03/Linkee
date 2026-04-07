import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BrightnessControlScreen extends StatelessWidget {
  final String serverIp;

  const BrightnessControlScreen({super.key, required this.serverIp});

  Future<void> _brightnessControl(BuildContext context, String action) async {
    try {
      await http.post(
        Uri.parse('http://$serverIp:8000/brightness/control'),
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
          _buildBrightnessButton(
            context: context,
            icon: Icons.brightness_low,
            action: 'down',
          ),
          const SizedBox(width: 20),
          _buildBrightnessButton(
            context: context,
            icon: Icons.brightness_high,
            action: 'up',
          ),
        ],
      ),
    );
  }

  Widget _buildBrightnessButton({
    required BuildContext context,
    required IconData icon,
    required String action,
  }) {
    return ElevatedButton(
      onPressed: () => _brightnessControl(context, action),
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
