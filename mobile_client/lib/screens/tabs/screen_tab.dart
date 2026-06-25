import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import '../../services/api_service.dart';
import '../../widgets/glass_container.dart';

class ScreenTab extends StatefulWidget {
  const ScreenTab({super.key});

  @override
  State<ScreenTab> createState() => _ScreenTabState();
}

class _ScreenTabState extends State<ScreenTab> {
  List<dynamic> _displays = [];
  String? _selectedDisplayId;

  @override
  void initState() {
    super.initState();
    _loadDisplays();
  }

  Future<void> _loadDisplays() async {
    final displays = await ApiService().getDisplays();
    if (displays.isNotEmpty && mounted) {
      setState(() {
        _displays = displays;
        _selectedDisplayId = displays.first['id'].toString();
      });
    }
  }

  @override
  void dispose() {
    ApiService().stopScreenStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamUrl = ApiService().screenStreamUrl(_selectedDisplayId);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              child: Mjpeg(
                key: ValueKey(streamUrl),
                isLive: true,
                stream: streamUrl,
                error: (context, error, stack) => Center(child: Text('Yayın Hatası: $error', style: const TextStyle(color: Colors.red))),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_displays.isNotEmpty)
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    borderRadius: 12,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDisplayId,
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDisplayId = val);
                        },
                        items: _displays.map((d) {
                          return DropdownMenuItem<String>(
                            value: d['id'].toString(),
                            child: Text(d['name'] ?? 'Ekran ${d['id']}'),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                GlassContainer(
                  borderRadius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: () {
                      final dashboardState = context.findAncestorStateOfType<State<StatefulWidget>>();
                      if (dashboardState != null && dashboardState.mounted) {
                         // ignore: invalid_use_of_protected_member
                         dashboardState.setState(() {
                            (dashboardState as dynamic)._currentIndex = 0;
                         });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
