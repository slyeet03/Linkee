import 'package:flutter/material.dart';
import '../services/server_service.dart';

class MouseControlScreen extends StatefulWidget {
  final String serverIp;

  const MouseControlScreen({super.key, required this.serverIp});

  @override
  State<MouseControlScreen> createState() => _MouseControlScreenState();
}

class _MouseControlScreenState extends State<MouseControlScreen> {
  int currentX = 500;
  int currentY = 500;
  late final ServerService _serverService;

  @override
  void initState() {
    super.initState();
    _serverService = ServerService(widget.serverIp);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                currentX += (details.delta.dx * 2).toInt();
                currentY += (details.delta.dy * 2).toInt();
                if (currentX < 0) currentX = 0;
                if (currentY < 0) currentY = 0;
              });
              _serverService.moveMouseAbsolute(currentX, currentY);
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'Trackpad\nSwipe to move mouse',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _serverService.clickMouse("left"), 
                child: const Text("Left")),
              ElevatedButton(
                onPressed: () => _serverService.clickMouse("middle"), 
                child: const Text("Middle")),
              ElevatedButton(
                onPressed: () => _serverService.clickMouse("right"), 
                child: const Text("Right")),
            ],
          ),
        ),
      ],
    );
  }
}