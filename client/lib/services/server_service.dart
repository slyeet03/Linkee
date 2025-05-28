import 'dart:convert';
import 'package:http/http.dart' as http;

class ServerService {
  final String serverIp;

  ServerService(this.serverIp);

  Future<void> moveMouseAbsolute(int x, int y) async {
    try {
      await http.post(
        Uri.parse('http://$serverIp:8000/mouse/move'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'x': x, 'y': y}),
      );
    } catch (e) {
      throw Exception('Mouse move error: $e');
    }
  }

  Future<void> clickMouse(String button) async {
    try {
      await http.post(
        Uri.parse('http://$serverIp:8000/mouse/click'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'button': button}),
      );
    } catch (e) {
      throw Exception('Mouse click error: $e');
    }
  }

  Future<void> pressKey(String key) async {
    try {
      await http.post(
        Uri.parse('http://$serverIp:8000/keyboard/press'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'key': key}),
      );
    } catch (e) {
      throw Exception('Key press error: $e');
    }
  }

  Future<void> keyboardAction(String action, String key) async {
    await http.post(
      Uri.parse('http://$serverIp:8000/keyboard/$action'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'key': key}),
    );
  }

  Future<void> keyCombo(List<String> modifiers, String key) async {
    await http.post(
      Uri.parse('http://$serverIp:8000/keyboard/combo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'modifiers': modifiers,
        'key': key
      }),
    );
  }

  Future<void> typeText(String text) async {
    await http.post(
      Uri.parse('http://$serverIp:8000/keyboard/type'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
  }

  Future<void> mediaControl(String action) async {
    await http.post(
      Uri.parse('http://$serverIp:8000/media/control'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'action': action}),
    );
  }

  Future<double> getVolume() async {
    try {
      final response = await http.get(
        Uri.parse('http://$serverIp:8000/volume'),
      );
      if (response.statusCode == 200) {
        // Handle different response formats
        final body = response.body.trim();
        if (body.isEmpty) {
          return 50.0; // Default volume
        }
        return double.parse(body);
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Return default volume on any error
      return 50.0;
    }
  }

  Future<void> setVolume(double volume) async {
    await http.post(
      Uri.parse('http://$serverIp:8000/volume/set'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'volume': volume}),
    );
  }

  Future<void> toggleMute() async {
    await http.post(
      Uri.parse('http://$serverIp:8000/volume/mute'),
    );
  }
}