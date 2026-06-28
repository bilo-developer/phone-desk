import 'package:flutter/material.dart';
import 'tabs/touchpad_tab.dart';
import 'tabs/screen_tab.dart';
import 'tabs/files_tab.dart';
import 'tabs/deck_tab.dart';
import 'tabs/system_tab.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_container.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  void changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  final List<Widget> _tabs = const [
    TouchpadTab(),
    ScreenTab(),
    FilesTab(),
    DeckTab(),
    SystemTab(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AppBackground(
        child: LiquidGlassLayer(
          fake: true,
          settings: const LiquidGlassSettings(
            thickness: 10,
            blur: 15,
            glassColor: Color(0x22FFFFFF),
          ),
          child: Stack(
            children: [
              _tabs[_currentIndex],

              if (_currentIndex != 1)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: SafeArea(
                    child: GlassContainer(
                      borderRadius: 30.0,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(0, Icons.ads_click, 'Touchpad'),
                          _buildNavItem(1, Icons.desktop_windows, 'Screen'),
                          _buildNavItem(2, Icons.folder_open, 'Files'),
                          _buildNavItem(3, Icons.grid_view, 'Deck'),
                          _buildNavItem(4, Icons.settings_suggest, 'Sistem'),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withAlpha(13) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isActive ? 1.0 : 0.6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isActive ? AppTheme.primary : AppTheme.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? AppTheme.primary : AppTheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
