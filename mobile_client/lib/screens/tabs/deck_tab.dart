import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme.dart';

class DeckTab extends StatefulWidget {
  const DeckTab({super.key});

  @override
  State<DeckTab> createState() => _DeckTabState();
}

class _DeckTabState extends State<DeckTab> {
  List<dynamic> _profiles = [];
  List<dynamic> _buttons = [];
  String? _activeProfileId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await ApiService().getDeckProfiles();
    _profiles = data['profiles'] ?? [];
    _activeProfileId = data['activeProfileId'];
    if (_activeProfileId != null) {
      _buttons = await ApiService().getDeckButtons(_activeProfileId!);
    }
    setState(() => _isLoading = false);
  }

  void _onProfileChanged(String newId) async {
    setState(() {
      _activeProfileId = newId;
      _isLoading = true;
    });
    _buttons = await ApiService().getDeckButtons(newId);
    setState(() => _isLoading = false);
  }

  String get _activeProfileName {
    if (_activeProfileId == null) return 'Profil';
    for (final p in _profiles) {
      if (p['id'] == _activeProfileId) return p['name'] ?? 'Profil';
    }
    return 'Profil';
  }

  void _showProfileSelector() {
    if (_profiles.length <= 1) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outlineGlow, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 8),
              child: Text('Profil Seçin', style: TextStyle(color: AppTheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
            ),
            ..._profiles.map((p) {
              final id = p['id'];
              final name = p['name'] ?? 'Profil';
              final isActive = id == _activeProfileId;
              return InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  if (!isActive) _onProfileChanged(id);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primaryContainer.withAlpha(25) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: isActive ? AppTheme.primary : AppTheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        name,
                        style: TextStyle(
                          color: isActive ? AppTheme.primary : AppTheme.onSurface,
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _onButtonTap(Map<String, dynamic> button) {
    if (button['actionType'] == 'movie_mode') {
      _showScreenSelectionDialog(button);
    } else {
      ApiService().executeDeckButton(button);
    }
  }

  void _showScreenSelectionDialog(Map<String, dynamic> button) async {
    // Yükleniyor göstergesi gösterebiliriz ama hızlı olması için direkt API çağrısı yapalım
    List<dynamic> displays = [];
    try {
      displays = await ApiService().getDisplays();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ekranlar alınamadı: $e')));
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Ekran Seçin', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: displays.isEmpty 
            ? const Center(child: Text('Ekran bulunamadı', style: TextStyle(color: Colors.white70)))
            : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.6,
              ),
              itemCount: displays.length,
              itemBuilder: (context, index) {
                final disp = displays[index];
                final dispId = disp['id'].toString();
                final dispName = disp['name']?.toString() ?? 'Ekran $dispId';

                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    // Update the actionData with the selected screen name (e.g. \\.\DISPLAY1) for precise matching in PowerShell
                    final updatedButton = Map<String, dynamic>.from(button);
                    updatedButton['actionData'] = disp['name']?.toString() ?? index.toString();
                    ApiService().executeDeckButton(updatedButton);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          ApiService().screenSnapshotUrl(dispId),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => const Icon(Icons.monitor, color: Colors.white24, size: 40),
                        ),
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            color: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            alignment: Alignment.center,
                            child: Text(dispName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          )
        ],
      ),
    );
  }

  void _showAddButtonDialog() {
    if (_activeProfileId == null) return;
    final labelController = TextEditingController();
    final commandController = TextEditingController();
    String type = 'exe';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Kısayol Ekle', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Etiket', labelStyle: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: type,
                  dropdownColor: const Color(0xFF1E293B),
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'exe', child: Text('Program Çalıştır (.exe)')),
                    DropdownMenuItem(value: 'macro', child: Text('Klavye Kısayolu')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => type = val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commandController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: type == 'exe' ? 'Uygulama Yolu (C:\\...)' : 'Tuşlar (örn: ctrl+c)',
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              onPressed: () async {
                final btn = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'label': labelController.text,
                  'type': type,
                  'command': commandController.text,
                  'color': '#3B82F6'
                };
                Navigator.pop(context);
                setState(() => _isLoading = true);
                await ApiService().addDeckButton(_activeProfileId!, btn);
                await _loadData();
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Profile Selector
          if (_profiles.length > 1)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 48, bottom: 8),
              child: GestureDetector(
                onTap: _showProfileSelector,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.glassSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.outlineGlow, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.category, color: AppTheme.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _activeProfileName,
                          style: const TextStyle(
                            color: AppTheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const Icon(Icons.expand_more, color: AppTheme.onSurfaceVariant, size: 24),
                    ],
                  ),
                ),
              ),
            ),
          // Grid
          Expanded(
            child: GridView.builder(
        padding: EdgeInsets.only(left: 20, right: 20, top: _profiles.length > 1 ? 8 : 48, bottom: 140),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _buttons.length + 1, // +1 for the add button
        itemBuilder: (context, index) {
          // Last item is the "add" button
          if (index == _buttons.length) {
            return GestureDetector(
              onTap: _showAddButtonDialog,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withAlpha(20),
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: AppTheme.onSurfaceVariant, size: 28),
                    SizedBox(height: 8),
                    Text(
                      'Ekle',
                      style: TextStyle(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final btn = _buttons[index];
          final label = btn['label'] ?? '';
          final colorHex = btn['color']?.toString().replaceAll('#', '') ?? '3B82F6';
          final color = Color(int.parse('FF$colorHex', radix: 16));

          return GestureDetector(
            onTap: () => _onButtonTap(btn),
            onLongPress: () => _showDeleteDialog(btn),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(13),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(20), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getIconForButton(btn), color: color, size: 28),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForButton(Map<String, dynamic> btn) {
    final type = btn['type']?.toString() ?? '';
    final actionType = btn['actionType']?.toString() ?? '';
    final label = (btn['label'] ?? '').toString().toLowerCase();

    if (actionType == 'movie_mode') return Icons.movie;
    if (actionType == 'volume_up') return Icons.volume_up;
    if (actionType == 'volume_down') return Icons.volume_down;
    if (actionType == 'volume_mute') return Icons.volume_off;
    if (actionType == 'play_pause') return Icons.play_arrow;
    if (actionType == 'next_track') return Icons.skip_next;
    if (actionType == 'prev_track') return Icons.skip_previous;

    if (label.contains('kopyala') || label.contains('copy')) return Icons.content_copy;
    if (label.contains('yapıştır') || label.contains('paste')) return Icons.content_paste;
    if (label.contains('geri al') || label.contains('undo')) return Icons.undo;
    if (label.contains('kaydet') || label.contains('save')) return Icons.save;
    if (label.contains('kilit') || label.contains('lock')) return Icons.lock;
    if (label.contains('masaüstü') || label.contains('desktop')) return Icons.desktop_windows;
    if (label.contains('ses') || label.contains('volume')) return Icons.volume_up;
    if (label.contains('sessiz') || label.contains('mute') || label.contains('sustur')) return Icons.volume_off;
    if (label.contains('mikrofon') || label.contains('mic')) return Icons.mic_off;
    if (label.contains('kamera') || label.contains('camera')) return Icons.videocam;
    
    // Medya & Ses
    if (label.contains('sonraki') || label.contains('next')) return Icons.skip_next;
    if (label.contains('önceki') || label.contains('prev')) return Icons.skip_previous;
    if (label.contains('youtube')) return Icons.smart_display;
    if (label.contains('10sn ileri') || label.contains('forward')) return Icons.forward_10;
    if (label.contains('10sn geri') || label.contains('replay')) return Icons.replay_10;
    if (label.contains('oynat') || label.contains('play') || label.contains('duraklat') || label.contains('pause')) return Icons.play_arrow;
    
    // Geliştirici
    if (label.contains('format')) return Icons.format_align_left;
    if (label.contains('terminal') || label.contains('cmd') || label.contains('powershell')) return Icons.terminal;
    if (label.contains('sil') || label.contains('delete')) return Icons.backspace;
    if (label.contains('github') || label.contains('git')) return Icons.merge_type;
    if (label.contains('ara') || label.contains('search')) return Icons.search;

    // Oyun & Yayın
    if (label.contains('kayıt') || label.contains('record')) return Icons.fiber_manual_record;
    if (label.contains('xbox') || label.contains('game')) return Icons.sports_esports;
    if (label.contains('twitch') || label.contains('yayın')) return Icons.live_tv;

    // Toplantı
    if (label.contains('paylaş') || label.contains('share')) return Icons.screen_share;
    if (label.contains('sohbet') || label.contains('chat')) return Icons.chat;
    
    // Genel
    if (label.contains('dosya') || label.contains('explorer')) return Icons.folder;
    if (label.contains('görev') || label.contains('task')) return Icons.analytics;
    if (label.contains('ekran görüntüsü') || label.contains('screenshot') || label.contains('print')) return Icons.screenshot_monitor;
    if (label.contains('tarayıcı') || label.contains('browser') || label.contains('google') || label.contains('chrome')) return Icons.public;
    if (label.contains('kapat') || label.contains('shutdown') || label.contains('power')) return Icons.power_settings_new;
    if (label.contains('yenile') || label.contains('refresh')) return Icons.refresh;
    if (label.contains('uygulama') || label.contains('switch') || label.contains('app')) return Icons.recent_actors;
    if (label.contains('tam ekran') || label.contains('fullscreen')) return Icons.fullscreen;
    if (label.contains('mail') || label.contains('posta')) return Icons.mail;
    if (label.contains('hesap') || label.contains('calc')) return Icons.calculate;
    if (label.contains('müzik') || label.contains('music') || label.contains('spotify')) return Icons.music_note;
    if (label.contains('ayarlar') || label.contains('settings')) return Icons.settings;

    if (type == 'macro') return Icons.keyboard;
    if (type == 'exe') return Icons.launch;

    return Icons.bolt;
  }

  void _showDeleteDialog(Map<String, dynamic> btn) {
    if (_activeProfileId == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Kısayolu Sil', style: TextStyle(color: AppTheme.onSurface, fontFamily: 'Inter')),
        content: Text('"${btn['label']}" silinsin mi?', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontFamily: 'Inter')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: AppTheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              await ApiService().deleteDeckButton(_activeProfileId!, btn['id']);
              await _loadData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
