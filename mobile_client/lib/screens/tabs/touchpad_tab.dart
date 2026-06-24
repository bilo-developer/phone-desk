import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TouchpadTab extends StatelessWidget {
  const TouchpadTab({super.key});

  void _onPanUpdate(DragUpdateDetails details) {
    ApiService().sendMouse('relative', dx: details.delta.dx.toInt(), dy: details.delta.dy.toInt());
  }

  void _onTap() {
    ApiService().sendMouse('left_click', click: true);
  }

  void _onSecondaryTap() {
    ApiService().sendMouse('right_click');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onTap: _onTap,
      onSecondaryTap: _onSecondaryTap,
      onDoubleTap: () => ApiService().sendMouse('left_click', click: true),
      child: Container(
        color: Colors.transparent,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, size: 80, color: Colors.white24),
              SizedBox(height: 16),
              Text('Touchpad Alanı', style: TextStyle(color: Colors.white54, fontSize: 18)),
              Text('Fareyi hareket ettirmek için sürükleyin', style: TextStyle(color: Colors.white38)),
            ],
          ),
        ),
      ),
    );
  }
}
