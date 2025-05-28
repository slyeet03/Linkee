// lib/screens/media_screen.dart
import 'package:flutter/material.dart';
import '../services/server_service.dart';

class MediaControlScreen extends StatefulWidget {
  final String serverIp;

  const MediaControlScreen({super.key, required this.serverIp});

  @override
  State<MediaControlScreen> createState() => _MediaControlScreenState();
}

class _MediaControlScreenState extends State<MediaControlScreen> {
  late ServerService _serverService;

  @override
  void initState() {
    super.initState();
    _serverService = ServerService(widget.serverIp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Play/Pause Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaButton(
                  icon: Icons.skip_previous,
                  action: 'prev',
                  isPrimary: false,
                ),
                _buildMediaButton(
                  icon: Icons.play_arrow,
                  action: 'playpause',
                  isPrimary: true,
                ),
                _buildMediaButton(
                  icon: Icons.skip_next,
                  action: 'next',
                  isPrimary: false,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String action,
    required bool isPrimary,
  }) {
    // Remove const and calculate size dynamically
    final double size = isPrimary ? 72 : 60;
    
    return ElevatedButton(
      onPressed: () async {
        try {
          await _serverService.mediaControl(action);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.blue : const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        fixedSize: Size(size, size), // Remove const here
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
      ),
      child: Icon(
        icon,
        size: isPrimary ? 32 : 24,
      ),
    );
  }
}