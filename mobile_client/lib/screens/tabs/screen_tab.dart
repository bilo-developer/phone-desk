import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import '../../services/api_service.dart';

class ScreenTab extends StatefulWidget {
  const ScreenTab({super.key});

  @override
  State<ScreenTab> createState() => _ScreenTabState();
}

class _ScreenTabState extends State<ScreenTab> {
  @override
  void dispose() {
    ApiService().stopScreenStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 5.0,
          child: Mjpeg(
            isLive: true,
            stream: ApiService().screenStreamUrl,
            error: (context, error, stack) => Center(child: Text('Yayın Hatası: $error', style: const TextStyle(color: Colors.red))),
          ),
        ),
      ),
    );
  }
}
