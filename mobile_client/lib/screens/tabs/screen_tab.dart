import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import '../../services/api_service.dart';
import '../../widgets/glass_container.dart';
import '../dashboard_screen.dart' as dashboard;

class ScreenTab extends StatefulWidget {
  const ScreenTab({super.key});

  @override
  State<ScreenTab> createState() => _ScreenTabState();
}

class _ScreenTabState extends State<ScreenTab> {
  List<dynamic> _displays = [];
  String? _selectedDisplayId;
  String _errorMsg = 'Yükleniyor...';
  int _fps = 15;
  int _res = 1080;
  bool _controlMode = false;

  @override
  void initState() {
    super.initState();
    _loadDisplays();
  }

  Future<void> _loadDisplays() async {
    try {
      final displays = await ApiService().getDisplays();
      if (mounted) {
        setState(() {
          if (displays.isNotEmpty) {
             _displays = displays;
             _selectedDisplayId = displays.first['id'].toString();
             _errorMsg = '';
          } else {
             _errorMsg = 'Liste boş döndü.';
          }
        });
      }
    } catch(e) {
      if (mounted) setState(() => _errorMsg = 'Hata: $e');
    }
  }

  @override
  void dispose() {
    ApiService().stopScreenStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neonStyle = const TextStyle(
      color: Colors.cyanAccent,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      shadows: [
        Shadow(color: Colors.cyan, blurRadius: 4),
      ],
    );
    final streamUrl = ApiService().screenStreamUrl(_selectedDisplayId, _fps, _res);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Center(
            child: _displays.isEmpty
              ? const CircularProgressIndicator(color: Colors.white)
              : InteractiveViewer(
                  panEnabled: !_controlMode,
                  scaleEnabled: !_controlMode,
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: _controlMode 
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return GestureDetector(
                            onTapDown: (details) {
                              final xPct = details.localPosition.dx / constraints.maxWidth;
                              final yPct = details.localPosition.dy / constraints.maxHeight;
                              ApiService().sendMouseAbsolute(xPct, yPct, click: true);
                            },
                            onPanUpdate: (details) {
                              final xPct = details.localPosition.dx / constraints.maxWidth;
                              final yPct = details.localPosition.dy / constraints.maxHeight;
                              ApiService().sendMouseAbsolute(xPct, yPct, click: false);
                            },
                            child: Mjpeg(
                              key: ValueKey(streamUrl),
                              isLive: true,
                              stream: streamUrl,
                              error: (context, error, stack) => Center(child: Text('Yayın Hatası: $error', style: const TextStyle(color: Colors.red))),
                            ),
                          );
                        }
                      )
                    : Mjpeg(
                        key: ValueKey(streamUrl),
                        isLive: true,
                        stream: streamUrl,
                        error: (context, error, stack) => Center(child: Text('Yayın Hatası: $error', style: const TextStyle(color: Colors.red))),
                      ),
                ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    borderRadius: 30,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Display Selector
                        PopupMenuButton<String>(
                          color: const Color(0xFF1E293B),
                          onSelected: (val) => setState(() => _selectedDisplayId = val),
                          itemBuilder: (context) => _displays.map((d) {
                            return PopupMenuItem<String>(
                              value: d['id'].toString(),
                              child: Text(d['name'] ?? 'Ekran ${d['id']}', style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedDisplayId != null ? (_displays.firstWhere((d) => d['id'].toString() == _selectedDisplayId, orElse: () => {'name': 'Ekran'})['name'] ?? 'Ekran') : (_errorMsg.isNotEmpty ? _errorMsg : 'Ekran Seç'),
                                  style: neonStyle,
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down, color: Colors.cyanAccent, size: 20),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1, height: 20, color: Colors.cyanAccent.withValues(alpha: 0.3)),
                        // Resolution Selector
                        PopupMenuButton<int>(
                          color: const Color(0xFF1E293B),
                          onSelected: (val) => setState(() => _res = val),
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 480, child: Text('480p', style: TextStyle(color: Colors.white))),
                            PopupMenuItem(value: 720, child: Text('720p', style: TextStyle(color: Colors.white))),
                            PopupMenuItem(value: 1080, child: Text('1080p', style: TextStyle(color: Colors.white))),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${_res}p', style: neonStyle.copyWith(fontSize: 13)),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down, color: Colors.cyanAccent, size: 18),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1, height: 20, color: Colors.cyanAccent.withValues(alpha: 0.3)),
                        // FPS Selector
                        PopupMenuButton<int>(
                          color: const Color(0xFF1E293B),
                          onSelected: (val) => setState(() => _fps = val),
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 15, child: Text('15 FPS', style: TextStyle(color: Colors.white))),
                            PopupMenuItem(value: 30, child: Text('30 FPS', style: TextStyle(color: Colors.white))),
                            PopupMenuItem(value: 60, child: Text('60 FPS', style: TextStyle(color: Colors.white))),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('$_fps FPS', style: neonStyle.copyWith(fontSize: 13)),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down, color: Colors.cyanAccent, size: 18),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1, height: 20, color: Colors.cyanAccent.withValues(alpha: 0.3)),
                        const SizedBox(width: 4),
                        // Control Mode Toggle
                        IconButton(
                          icon: Icon(
                            Icons.mouse, 
                            color: _controlMode ? Colors.cyanAccent : Colors.white70, 
                            size: 20,
                            shadows: _controlMode ? [const Shadow(color: Colors.cyan, blurRadius: 6)] : null,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() => _controlMode = !_controlMode);
                          },
                        ),
                        const SizedBox(width: 12),
                        Container(width: 1, height: 20, color: Colors.cyanAccent.withValues(alpha: 0.3)),
                        const SizedBox(width: 4),
                        // Close Button
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.redAccent, size: 20, shadows: [Shadow(color: Colors.red, blurRadius: 4)]),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            final dashboardState = context.findAncestorStateOfType<dashboard.DashboardScreenState>();
                            if (dashboardState != null && dashboardState.mounted) {
                               dashboardState.changeTab(0);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
