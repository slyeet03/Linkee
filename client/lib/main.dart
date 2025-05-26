import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const RemoteApp());
}

class RemoteApp extends StatelessWidget {
  const RemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Control',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainMenuScreen(),
      routes: {
        '/mouse': (_) => const MouseControlScreen(),
        '/keyboard': (_) => const KeyboardControlScreen(),
        '/media': (_) => const MediaControlScreen(),
        '/volume': (_) => const VolumeControlScreen(),
      },
    );
  }
}

const String serverIp = "http://192.168.0.114:3000"; // your server IP + port

// Main menu screen
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remote Control - Main Menu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/mouse'),
                child: const Text('Mouse Controls')),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/keyboard'),
                child: const Text('Keyboard Controls')),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/media'),
                child: const Text('Media Controls')),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/volume'),
                child: const Text('Volume Controls')),
          ],
        ),
      ),
    );
  }
}

// Mouse control screen with trackpad
class MouseControlScreen extends StatefulWidget {
  const MouseControlScreen({super.key});

  @override
  State<MouseControlScreen> createState() => _MouseControlScreenState();
}

class _MouseControlScreenState extends State<MouseControlScreen> {
  int currentX = 500;
  int currentY = 500;

  Future<void> moveMouseAbsolute(int x, int y) async {
    try {
      await http.post(Uri.parse('$serverIp/mouse/move'),
          headers: {'Content-Type': 'application/json'},
          body: '{"x": $x, "y": $y}');
    } catch (e) {
      debugPrint('Mouse move error: $e');
    }
  }

  Future<void> clickMouse(String button) async {
    try {
      await http.post(Uri.parse('$serverIp/mouse/click'),
          headers: {'Content-Type': 'application/json'},
          body: '{"button": "$button"}');
    } catch (e) {
      debugPrint('Mouse click error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mouse Controls')),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                currentX += (details.delta.dx * 3).toInt();
                currentY += (details.delta.dy * 3).toInt();

                if (currentX < 0) currentX = 0;
                if (currentY < 0) currentY = 0;

                moveMouseAbsolute(currentX, currentY);
              },
              child: Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Text(
                    'Trackpad\nMove your finger to control the cursor',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () => clickMouse("left"),
                    child: const Text("Left Click")),
                ElevatedButton(
                    onPressed: () => clickMouse("right"),
                    child: const Text("Right Click")),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Keyboard control screen
class KeyboardControlScreen extends StatefulWidget {
  const KeyboardControlScreen({super.key});

  @override
  State<KeyboardControlScreen> createState() => _KeyboardControlScreenState();
}

class _KeyboardControlScreenState extends State<KeyboardControlScreen> {
  final TextEditingController _textController = TextEditingController();

  Future<void> typeText(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await http.post(Uri.parse('$serverIp/keyboard/type'),
          headers: {'Content-Type': 'application/json'},
          body: '{"text": "$text"}');
    } catch (e) {
      debugPrint('Type text error: $e');
    }
    _textController.clear();
  }

  Future<void> pressKey(String key) async {
    try {
      await http.post(Uri.parse('$serverIp/keyboard/press'),
          headers: {'Content-Type': 'application/json'},
          body: '{"key": "$key"}');
    } catch (e) {
      debugPrint('Press key error: $e');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keyboard Controls')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: "Type Text"),
              onSubmitted: typeText,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () => pressKey("Enter"),
                    child: const Text("Enter")),
                ElevatedButton(
                    onPressed: () => pressKey("Escape"),
                    child: const Text("Esc")),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Media control screen
class MediaControlScreen extends StatelessWidget {
  const MediaControlScreen({super.key});

  Future<void> mediaControl(String action) async {
    try {
      await http.post(Uri.parse('$serverIp/media/control'),
          headers: {'Content-Type': 'application/json'},
          body: '{"action": "$action"}');
    } catch (e) {
      debugPrint('Media control error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Controls')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () => mediaControl("prev"), child: const Text("Prev")),
            ElevatedButton(
                onPressed: () => mediaControl("playpause"),
                child: const Text("Play/Pause")),
            ElevatedButton(
                onPressed: () => mediaControl("next"), child: const Text("Next")),
          ],
        ),
      ),
    );
  }
}

// Volume control screen
class VolumeControlScreen extends StatelessWidget {
  const VolumeControlScreen({super.key});

  Future<void> volumeControl(String action) async {
    try {
      await http.post(Uri.parse('$serverIp/volume/control'),
          headers: {'Content-Type': 'application/json'},
          body: '{"action": "$action"}');
    } catch (e) {
      debugPrint('Volume control error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Volume Controls')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () => volumeControl("up"), child: const Text("Vol +")),
            ElevatedButton(
                onPressed: () => volumeControl("down"), child: const Text("Vol -")),
            ElevatedButton(
                onPressed: () => volumeControl("mute"), child: const Text("Mute")),
          ],
        ),
      ),
    );
  }
}
