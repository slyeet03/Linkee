
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const RemoteApp());
}

const String serverIp = "http://192.168.0.114:8000";

class RemoteApp extends StatelessWidget {
  const RemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linkee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F1F1F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      home: const UnifiedHomeScreen(),
    );
  }
}

class UnifiedHomeScreen extends StatefulWidget {
  const UnifiedHomeScreen({super.key});

  @override
  State<UnifiedHomeScreen> createState() => _UnifiedHomeScreenState();
}

class _UnifiedHomeScreenState extends State<UnifiedHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    MouseControlScreen(),
    KeyboardControlScreen(),
    MediaControlScreen(),
    VolumeControlScreen(),
  ];

  final List<String> _titles = const [
    "Mouse",
    "Keyboard",
    "Media",
    "Volume",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Linkee - ${_titles[_selectedIndex]}"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: const Color(0xFF1F1F1F),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mouse), label: "Mouse"),
          BottomNavigationBarItem(icon: Icon(Icons.keyboard), label: "Keyboard"),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Media"),
          BottomNavigationBarItem(icon: Icon(Icons.volume_up), label: "Volume"),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

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
      final response = await http.post(
        Uri.parse('$serverIp/mouse/move'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'x': x, 'y': y}),
      );
    } catch (e) {
      debugPrint('Mouse move error: $e');
    }
  }

  Future<void> clickMouse(String button) async {
    try {
      await http.post(
        Uri.parse('$serverIp/mouse/click'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'button': button}),
      );
    } catch (e) {
      debugPrint('Mouse click error: $e');
    }
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
              moveMouseAbsolute(currentX, currentY);
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
              ElevatedButton(onPressed: () => clickMouse("left"), child: const Text("Left")),
              ElevatedButton(onPressed: () => clickMouse("middle"), child: const Text("Middle")),
              ElevatedButton(onPressed: () => clickMouse("right"), child: const Text("Right")),
            ],
          ),
        ),
      ],
    );
  }
}

class KeyboardControlScreen extends StatefulWidget {
  const KeyboardControlScreen({super.key});
  @override
  State<KeyboardControlScreen> createState() => _KeyboardControlScreenState();
}

class _KeyboardControlScreenState extends State<KeyboardControlScreen> {
  final TextEditingController _textController = TextEditingController();
  
  // Track which modifier keys are currently held
  Set<String> _heldModifiers = {};

  // Map display text to server keywords
  final Map<String, String> _keyMapping = {
    '↑': 'Up',
    '↓': 'Down',
    '←': 'Left',
    '→': 'Right',
    'Cmd': 'Cmd',
    'Option': 'Alt', 
    '^': 'Control',
    'Esc': 'Escape',
    'Shift': 'Shift',
    'Tab': 'Tab',
    'Backspace': 'Backspace',
    'Enter': 'Enter',
    'Space': 'Space',
  };

  // Modifier keys that can be held
  final Set<String> _modifierKeys = {'Cmd', 'Option', '^', 'Shift'};

  Future<void> typeText(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await http.post(
        Uri.parse('$serverIp/keyboard/type'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );
    } catch (e) {
      debugPrint('Type text error: $e');
    }
    _textController.clear();
  }

  Future<void> pressKey(String displayKey) async {
    try {
      String actualKey = _keyMapping[displayKey] ?? displayKey;
      
      if (_modifierKeys.contains(displayKey)) {
        // Toggle modifier key
        setState(() {
          if (_heldModifiers.contains(actualKey)) {
            _heldModifiers.remove(actualKey);
          } else {
            _heldModifiers.add(actualKey);
          }
        });
        
        // Send modifier toggle to server
        await http.post(
          Uri.parse('$serverIp/keyboard/modifier'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'modifier': actualKey,
            'action': _heldModifiers.contains(actualKey) ? 'hold' : 'release'
          }),
        );
      } else {
        // Regular key press with any held modifiers
        if (_heldModifiers.isNotEmpty) {
          await http.post(
            Uri.parse('$serverIp/keyboard/combo'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'modifiers': _heldModifiers.toList(),
              'key': actualKey
            }),
          );
        } else {
          await http.post(
            Uri.parse('$serverIp/keyboard/press'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'key': actualKey}),
          );
        }
      }
    } catch (e) {
      debugPrint('Press key error: $e');
    }
  }

  // Clear all held modifiers
  Future<void> clearModifiers() async {
    try {
      await http.post(
        Uri.parse('$serverIp/keyboard/clear-modifiers'),
        headers: {'Content-Type': 'application/json'},
      );
      setState(() {
        _heldModifiers.clear();
      });
    } catch (e) {
      debugPrint('Clear modifiers error: $e');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _textController,
            decoration: const InputDecoration(labelText: "Type Text"),
            onSubmitted: typeText,
          ),
          const SizedBox(height: 10),
          
          // Show held modifiers
          if (_heldModifiers.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Holding: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_heldModifiers.join(" + ")),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: clearModifiers,
                    child: const Text("Clear All"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          
          // Keyboard grid layout
          Column(
            children: [
              // Top row - Modifiers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildModifierKey("Cmd"),
                  _buildModifierKey("Option"),
                  _buildModifierKey("^"),
                  _buildModifierKey("Shift"),
                ],
              ),
              const SizedBox(height: 10),
              
              // Function keys row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKey("Esc", flex: 1),
                  _buildKey("Tab", flex: 1),
                  _buildKey("↑", flex: 1),
                  _buildKey("Backspace", flex: 2),
                ],
              ),
              const SizedBox(height: 10),
              
              // Arrow keys row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKey("←", flex: 1),
                  _buildKey("↓", flex: 1),
                  _buildKey("→", flex: 1),
                ],
              ),
              const SizedBox(height: 10),
              
              // Bottom Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKey("Space", flex: 2),
                  _buildKey("Enter", flex: 1),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String keyText, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(2),
        child: ElevatedButton(
          onPressed: () => pressKey(keyText),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            minimumSize: const Size(60, 40),
          ),
          child: Text(
            keyText,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildModifierKey(String keyText) {
    bool isHeld = _heldModifiers.contains(_keyMapping[keyText]);
    
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        child: ElevatedButton(
          onPressed: () => pressKey(keyText),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            minimumSize: const Size(60, 40),
            backgroundColor: isHeld 
              ? Colors.blue.withOpacity(0.3) 
              : const Color(0xFF1F1F1F),
            side: isHeld 
              ? const BorderSide(color: Colors.blue, width: 2)
              : null,
          ),
          child: Text(
            keyText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHeld ? FontWeight.bold : FontWeight.normal,
              color: isHeld ? Colors.blue.shade300 : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class MediaControlScreen extends StatelessWidget {
  const MediaControlScreen({super.key});

  Future<void> mediaControl(String action) async {
    try {
      await http.post(
        Uri.parse('$serverIp/media/control'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': action}),
      );
    } catch (e) {
      debugPrint('Media control error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.skip_previous, size: 32),
            onPressed: () => mediaControl("prev"),
            padding: EdgeInsets.all(16),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.1),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.play_arrow, size: 32),
            onPressed: () => mediaControl("playpause"),
            padding: EdgeInsets.all(16),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.2),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.skip_next, size: 32),
            onPressed: () => mediaControl("next"),
            padding: EdgeInsets.all(16),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}


class VolumeControlScreen extends StatelessWidget {
  const VolumeControlScreen({super.key});

  Future<void> volumeControl(String action) async {
    try {
      await http.post(
        Uri.parse('$serverIp/volume/control'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': action}),
      );
    } catch (e) {
      debugPrint('Volume control error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildVolumeButton(Icons.volume_off, () => volumeControl("mute")),
          SizedBox(width: 20),
          _buildVolumeButton(Icons.volume_down, () => volumeControl("down")),
          SizedBox(width: 20),
          _buildVolumeButton(Icons.volume_up, () => volumeControl("up")),
          SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildVolumeButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 28),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.blue.withOpacity(0.1), 
        padding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        fixedSize: Size(60, 60),
      ),
    );
  }
}