import 'package:flutter/material.dart';
import 'mouse_screen.dart';
import 'keyboard_screen.dart';
import 'media_screen.dart';
import 'volume_screen.dart';

class UnifiedHomeScreen extends StatefulWidget {
  final String serverIp;

  const UnifiedHomeScreen({super.key, required this.serverIp});

  @override
  State<UnifiedHomeScreen> createState() => _UnifiedHomeScreenState();
}

class _UnifiedHomeScreenState extends State<UnifiedHomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    MouseControlScreen(serverIp: widget.serverIp),
    KeyboardControlScreen(serverIp: widget.serverIp),
    MediaControlScreen(serverIp: widget.serverIp),
    VolumeControlScreen(serverIp: widget.serverIp),
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