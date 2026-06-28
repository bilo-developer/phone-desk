import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/glass_container.dart';
import '../../theme.dart';

class TouchpadTab extends StatefulWidget {
  const TouchpadTab({super.key});

  @override
  State<TouchpadTab> createState() => _TouchpadTabState();
}

class _TouchpadTabState extends State<TouchpadTab> {
  bool _showKeyboard = false;
  final TextEditingController _keyboardController = TextEditingController();
  final FocusNode _keyboardFocus = FocusNode();

  @override
  void dispose() {
    _keyboardController.dispose();
    _keyboardFocus.dispose();
    super.dispose();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount == 1) {
      ApiService().sendMouse('move', dx: details.focalPointDelta.dx.toInt(), dy: details.focalPointDelta.dy.toInt());
    } else if (details.pointerCount == 2) {
      ApiService().sendMouse('scroll', dy: details.focalPointDelta.dy.toInt());
    }
  }

  void _onTap() {
    ApiService().sendMouse('left_click', click: true);
  }

  void _onSecondaryTap() {
    ApiService().sendMouse('right_click');
  }

  void _sendSpecialKey(String key) {
    ApiService().sendKeyboard('special', key);
  }

  void _sendCombo(String combo) {
    ApiService().sendKeyboard('combo', combo);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 120),
        child: Column(
          children: [
            // Title + Subtitle (outside touchpad)
            const SizedBox(height: 24),
            const Text(
              'Touchpad Alanı',
              style: TextStyle(
                color: AppTheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                letterSpacing: -0.24,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fareyi hareket ettirmek için sürükleyin',
              style: TextStyle(
                color: AppTheme.onSurfaceVariant,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 24),
            // Touchpad Area
            Expanded(
              child: GestureDetector(
                onScaleUpdate: _onScaleUpdate,
                onTap: _onTap,
                onSecondaryTap: _onSecondaryTap,
                onDoubleTap: () => ApiService().sendMouse('left_click', click: true),
                child: GlassContainer(
                  width: double.infinity,
                  borderRadius: 28,
                  child: Center(
                    child: Icon(
                      Icons.pan_tool_alt,
                      size: 64,
                      color: _showKeyboard ? AppTheme.secondary : AppTheme.primaryContainer.withAlpha(77),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Mouse buttons + keyboard toggle
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => ApiService().sendMouse('left_click', click: true),
                    child: GlassContainer(
                      height: 56,
                      borderRadius: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mouse, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text('Sol Tık', style: TextStyle(color: AppTheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() => _showKeyboard = !_showKeyboard);
                    if (_showKeyboard) {
                      Future.delayed(const Duration(milliseconds: 200), () {
                        _keyboardFocus.requestFocus();
                      });
                    }
                  },
                  child: GlassContainer(
                    height: 56,
                    width: 56,
                    borderRadius: 16,
                    borderColor: _showKeyboard ? AppTheme.primaryContainer : null,
                    child: Icon(
                      _showKeyboard ? Icons.keyboard_hide : Icons.keyboard,
                      color: _showKeyboard ? AppTheme.primaryContainer : AppTheme.onSurface,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => ApiService().sendMouse('right_click'),
                    child: GlassContainer(
                      height: 56,
                      borderRadius: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.ads_click, color: AppTheme.secondary, size: 20),
                          const SizedBox(width: 8),
                          const Text('Sağ Tık', style: TextStyle(color: AppTheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Keyboard Panel
            if (_showKeyboard) ...[
              const SizedBox(height: 12),
              // Text input field
              GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextField(
                  controller: _keyboardController,
                  focusNode: _keyboardFocus,
                  style: const TextStyle(color: AppTheme.onSurface, fontFamily: 'Inter'),
                  decoration: InputDecoration(
                    hintText: 'Metin yazın ve gönderin...',
                    hintStyle: TextStyle(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5)),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: AppTheme.primaryContainer),
                      onPressed: () {
                        if (_keyboardController.text.isNotEmpty) {
                          ApiService().sendKeyboard('text', _keyboardController.text);
                          _keyboardController.clear();
                        }
                      },
                    ),
                  ),
                  onSubmitted: (text) {
                    if (text.isNotEmpty) {
                      ApiService().sendKeyboard('text', text);
                      _keyboardController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Special keys
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _specialKeyButton('Enter', 'enter'),
                    _specialKeyButton('Tab', 'tab'),
                    _specialKeyButton('Esc', 'escape'),
                    _specialKeyButton('←', 'backspace'),
                    _specialKeyButton('Del', 'delete'),
                    _specialKeyButton('↑', 'up'),
                    _specialKeyButton('↓', 'down'),
                    _specialKeyButton('◀', 'left'),
                    _specialKeyButton('▶', 'right'),
                    _specialKeyButton('Space', 'space'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Combo shortcuts
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _comboKeyButton('Ctrl+C', 'ctrl+c'),
                    _comboKeyButton('Ctrl+V', 'ctrl+v'),
                    _comboKeyButton('Ctrl+Z', 'ctrl+z'),
                    _comboKeyButton('Ctrl+A', 'ctrl+a'),
                    _comboKeyButton('Ctrl+S', 'ctrl+s'),
                    _comboKeyButton('Alt+Tab', 'alt+tab'),
                    _comboKeyButton('Alt+F4', 'alt+f4'),
                    _comboKeyButton('Win+D', 'win+d'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _specialKeyButton(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => _sendSpecialKey(key),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Text(label, style: const TextStyle(color: AppTheme.onSurface, fontSize: 13, fontFamily: 'JetBrains Mono', fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _comboKeyButton(String label, String combo) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => _sendCombo(combo),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.primaryContainer.withValues(alpha: 0.3)),
          ),
          child: Text(label, style: const TextStyle(color: AppTheme.primaryContainer, fontSize: 13, fontFamily: 'JetBrains Mono', fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
