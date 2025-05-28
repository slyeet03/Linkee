import 'package:flutter/material.dart';
import '../services/server_service.dart';

class KeyboardControlScreen extends StatefulWidget {
  final String serverIp;

  const KeyboardControlScreen({super.key, required this.serverIp});

  @override
  State<KeyboardControlScreen> createState() => _KeyboardControlScreenState();
}

class _KeyboardControlScreenState extends State<KeyboardControlScreen> {
  final TextEditingController _textController = TextEditingController();
  late final ServerService _serverService;
  Set<String> _heldModifiers = {};

  final Map<String, String> _keyMapping = {
    '↑': 'Up',
    '↓': 'Down',
    '←': 'Left',
    '→': 'Right',
    'Cmd': 'Cmd',
    'Option': 'Alt',
    'Ctrl': 'Control',
    'Esc': 'Escape',
    'Shift': 'Shift',
    'Tab': 'Tab',
    'Backspace': 'Backspace',
    'Enter': 'Return',
    'Space': 'Space',
    'Del': 'Delete',
  };

  final Set<String> _modifierKeys = {'Cmd', 'Option', 'Ctrl', 'Shift'};

  @override
  void initState() {
    super.initState();
    _serverService = ServerService(widget.serverIp);
  }

  @override
  void dispose() {
    _textController.dispose();
    _releaseAllModifiers();
    super.dispose();
  }

  Future<void> _releaseAllModifiers() async {
    for (var modifier in _heldModifiers) {
      await _serverService.keyboardAction('release', modifier);
    }
    setState(() {
      _heldModifiers.clear();
    });
  }

  Future<void> typeText(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _serverService.typeText(text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error typing text: $e')),
      );
    }
    _textController.clear();
  }

  Future<void> pressKey(String displayKey) async {
    try {
      String actualKey = _keyMapping[displayKey] ?? displayKey;

      if (_modifierKeys.contains(displayKey)) {
        setState(() {
          if (_heldModifiers.contains(actualKey)) {
            _heldModifiers.remove(actualKey);
          } else {
            _heldModifiers.add(actualKey);
          }
        });

        await _serverService.keyboardAction(
          _heldModifiers.contains(actualKey) ? 'press' : 'release',
          actualKey,
        );
      } else {
        if (_heldModifiers.isNotEmpty) {
          await _serverService.keyCombo(_heldModifiers.toList(), actualKey);
        } else {
          await _serverService.keyboardAction('press', actualKey);
          await Future.delayed(const Duration(milliseconds: 100));
          await _serverService.keyboardAction('release', actualKey);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Key press error: $e')),
      );
    }
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
                    onPressed: _releaseAllModifiers,
                    child: const Text("Clear All"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Keyboard layout
          Column(
            children: [
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKey("Esc"),
                  _buildKey("Tab"),
                  _buildKey("↑"),
                  _buildKey("Backspace", flex: 2),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKey("←"),
                  _buildKey("↓"),
                  _buildKey("→"),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKey("Space", flex: 2),
                  _buildKey("Enter"),
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
