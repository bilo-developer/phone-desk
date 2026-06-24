import 'package:flutter/material.dart';
import 'tabs/touchpad_tab.dart';
import 'tabs/screen_tab.dart';
import 'tabs/files_tab.dart';
import 'tabs/deck_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    TouchpadTab(),
    ScreenTab(),
    FilesTab(),
    DeckTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.touch_app), label: 'Touchpad'),
          BottomNavigationBarItem(icon: Icon(Icons.desktop_windows), label: 'Ekran'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Dosyalar'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Deck'),
        ],
      ),
    );
  }
}
