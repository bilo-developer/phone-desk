import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'key_simulator.dart';

/// Represents a single button on the deck
class DeckButton {
  String id;
  String label;
  String iconName; // Material icon name
  String color; // Hex color code (e.g. "FF6B35")
  String actionType; // 'hotkey', 'launch', 'media', 'volume', 'command', 'folder', 'text', 'url'
  String actionData; // Action-specific data

  DeckButton({
    required this.id,
    required this.label,
    this.iconName = 'touch_app',
    this.color = '3B82F6',
    required this.actionType,
    required this.actionData,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'iconName': iconName,
    'color': color,
    'actionType': actionType,
    'actionData': actionData,
  };

  factory DeckButton.fromJson(Map<String, dynamic> json) => DeckButton(
    id: json['id'] ?? '',
    label: json['label'] ?? '',
    iconName: json['iconName'] ?? 'touch_app',
    color: json['color'] ?? '3B82F6',
    actionType: json['actionType'] ?? 'hotkey',
    actionData: json['actionData'] ?? '',
  );
}

/// Represents a profile containing a set of buttons
class DeckProfile {
  String id;
  String name;
  String iconName;
  String color;
  List<DeckButton> buttons;

  DeckProfile({
    required this.id,
    required this.name,
    this.iconName = 'dashboard',
    this.color = '3B82F6',
    List<DeckButton>? buttons,
  }) : buttons = buttons ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconName': iconName,
    'color': color,
    'buttons': buttons.map((b) => b.toJson()).toList(),
  };

  factory DeckProfile.fromJson(Map<String, dynamic> json) => DeckProfile(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    iconName: json['iconName'] ?? 'dashboard',
    color: json['color'] ?? '3B82F6',
    buttons: (json['buttons'] as List<dynamic>?)
        ?.map((b) => DeckButton.fromJson(b as Map<String, dynamic>))
        .toList() ?? [],
  );
}

/// Action type descriptors for the UI
class ActionTypeInfo {
  final String type;
  final String label;
  final String description;
  final IconData icon;

  const ActionTypeInfo({
    required this.type,
    required this.label,
    required this.description,
    required this.icon,
  });
}

const List<ActionTypeInfo> actionTypes = [
  ActionTypeInfo(type: 'hotkey', label: 'Klavye Kısayolu', description: 'Tuş kombinasyonu gönder (Ctrl+C vb.)', icon: Icons.keyboard),
  ActionTypeInfo(type: 'launch', label: 'Uygulama Başlat', description: 'Bir program veya dosya aç', icon: Icons.launch),
  ActionTypeInfo(type: 'media', label: 'Medya Kontrolü', description: 'Oynat/Duraklat, İleri, Geri', icon: Icons.play_circle),
  ActionTypeInfo(type: 'volume', label: 'Ses Kontrolü', description: 'Sesi artır, azalt veya kapat', icon: Icons.volume_up),
  ActionTypeInfo(type: 'command', label: 'Komut Çalıştır', description: 'PowerShell/CMD komutu çalıştır', icon: Icons.terminal),
  ActionTypeInfo(type: 'folder', label: 'Klasör Aç', description: 'Bir klasörü Explorer ile aç', icon: Icons.folder_open),
  ActionTypeInfo(type: 'text', label: 'Metin Yapıştır', description: 'Bir metni yazarak yapıştır', icon: Icons.text_fields),
  ActionTypeInfo(type: 'url', label: 'URL Aç', description: 'Bir web sayfası aç', icon: Icons.link),
  ActionTypeInfo(type: 'movie_mode', label: 'Film Modu', description: 'Netflix aç ve diğer ekranı karart', icon: Icons.movie),
];

/// Available icon names for buttons
const List<String> availableIcons = [
  'touch_app', 'keyboard', 'launch', 'play_circle', 'volume_up',
  'terminal', 'folder_open', 'text_fields', 'link', 'music_note',
  'videocam', 'mic', 'screenshot', 'screen_share', 'cast',
  'gamepad', 'sports_esports', 'headset', 'speaker', 'camera',
  'brush', 'code', 'bug_report', 'build', 'settings',
  'power_settings_new', 'lock', 'brightness_6', 'wifi', 'bluetooth',
  'notifications', 'email', 'chat', 'call', 'sms',
  'shopping_cart', 'favorite', 'star', 'bookmark', 'flag',
  'home', 'search', 'add', 'remove', 'delete',
  'save', 'share', 'download', 'upload', 'cloud',
  'discord', 'monitor', 'desktop_windows', 'web', 'refresh', 'movie',
];

/// Available gradient colors for buttons
const List<String> availableColors = [
  '3B82F6', // Blue
  '8B5CF6', // Purple
  'EC4899', // Pink
  'EF4444', // Red
  'F97316', // Orange
  'F59E0B', // Amber
  '22C55E', // Green
  '14B8A6', // Teal
  '06B6D4', // Cyan
  '6366F1', // Indigo
  'A855F7', // Violet
  'D946EF', // Fuchsia
  '64748B', // Slate
  '78716C', // Stone
  'F43F5E', // Rose
  '0EA5E9', // Sky
];

/// Manages deck profiles and button execution
class DeckManager {
  List<DeckProfile> profiles = [];
  String activeProfileId = '';
  final KeySimulator _keySimulator = KeySimulator();
  KeySimulator get keySimulator => _keySimulator;

  DeckProfile? get activeProfile {
    try {
      return profiles.firstWhere((p) => p.id == activeProfileId);
    } catch (_) {
      return profiles.isNotEmpty ? profiles.first : null;
    }
  }

  /// Load profiles from SharedPreferences
  Future<void> load() async {
    // Force create defaults to apply the new highly useful macro combinations
    _createDefaults();
    await save();

    if (activeProfileId.isEmpty && profiles.isNotEmpty) {
      activeProfileId = profiles.first.id;
    }
  }

  /// Save profiles to SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode({
      'profiles': profiles.map((p) => p.toJson()).toList(),
      'activeProfileId': activeProfileId,
    });
    await prefs.setString('deck_profiles', data);
  }

  /// Create default profiles with sample buttons
  void _createDefaults() {
    profiles = [
      DeckProfile(
        id: 'general',
        name: 'Genel (Üretkenlik)',
        iconName: 'dashboard',
        color: '3B82F6',
        buttons: [
          DeckButton(id: 'gen_1', label: 'Kopyala', iconName: 'content_copy', color: '3B82F6', actionType: 'hotkey', actionData: 'ctrl+c'),
          DeckButton(id: 'gen_2', label: 'Yapıştır', iconName: 'content_paste', color: '8B5CF6', actionType: 'hotkey', actionData: 'ctrl+v'),
          DeckButton(id: 'gen_3', label: 'Geri Al', iconName: 'undo', color: 'F59E0B', actionType: 'hotkey', actionData: 'ctrl+z'),
          DeckButton(id: 'gen_4', label: 'Dosya Gezgini', iconName: 'folder', color: 'F59E0B', actionType: 'hotkey', actionData: 'win+e'),
          DeckButton(id: 'gen_5', label: 'Masaüstü', iconName: 'desktop_windows', color: '6366F1', actionType: 'hotkey', actionData: 'win+d'),
          DeckButton(id: 'gen_6', label: 'Görev Yöneticisi', iconName: 'monitor', color: 'EF4444', actionType: 'hotkey', actionData: 'ctrl+shift+esc'),
          DeckButton(id: 'gen_7', label: 'Ekran Görüntüsü', iconName: 'screenshot', color: '22C55E', actionType: 'hotkey', actionData: 'win+shift+s'),
          DeckButton(id: 'gen_8', label: 'Uygulama Değiştir', iconName: 'swap_horiz', color: '06B6D4', actionType: 'hotkey', actionData: 'alt+tab'),
          DeckButton(id: 'gen_9', label: 'Tarayıcı (Google)', iconName: 'web', color: '14B8A6', actionType: 'url', actionData: 'https://google.com'),
          DeckButton(id: 'gen_10', label: 'Ekranı Kilitle', iconName: 'lock', color: 'EF4444', actionType: 'hotkey', actionData: 'win+l'),
          DeckButton(id: 'btn_shutdown', label: 'PC Kapat', iconName: 'power_settings_new', color: 'EF4444', actionType: 'command', actionData: 'shutdown /s /t 0'),
        ],
      ),
      DeckProfile(
        id: 'media',
        name: 'Medya & Ses',
        iconName: 'headset',
        color: 'EC4899',
        buttons: [
          DeckButton(id: 'med_1', label: 'Ses Aç', iconName: 'volume_up', color: '06B6D4', actionType: 'volume', actionData: 'up'),
          DeckButton(id: 'med_2', label: 'Ses Kıs', iconName: 'volume_down', color: '06B6D4', actionType: 'volume', actionData: 'down'),
          DeckButton(id: 'med_3', label: 'Sistemi Sustur', iconName: 'volume_off', color: 'EF4444', actionType: 'volume', actionData: 'mute'),
          DeckButton(id: 'med_4', label: 'Oynat/Duraklat', iconName: 'play_circle', color: 'EC4899', actionType: 'media', actionData: 'play_pause'),
          DeckButton(id: 'med_5', label: 'Sonraki Şarkı', iconName: 'skip_next', color: 'EC4899', actionType: 'media', actionData: 'next'),
          DeckButton(id: 'med_6', label: 'Önceki Şarkı', iconName: 'skip_previous', color: 'EC4899', actionType: 'media', actionData: 'prev'),
          DeckButton(id: 'med_7', label: 'YouTube Aç', iconName: 'play_arrow', color: 'EF4444', actionType: 'url', actionData: 'https://youtube.com'),
          DeckButton(id: 'med_8', label: 'Spotify Müzik', iconName: 'music_note', color: '22C55E', actionType: 'url', actionData: 'https://open.spotify.com'),
        ],
      ),
      DeckProfile(
        id: 'meeting',
        name: 'Toplantı (Zoom/Teams)',
        iconName: 'videocam',
        color: '3B82F6',
        buttons: [
          DeckButton(id: 'meet_1', label: 'Mikrofon Sustur', iconName: 'mic_off', color: 'EF4444', actionType: 'hotkey', actionData: 'alt+a'),
          DeckButton(id: 'meet_2', label: 'Kamera Aç/Kapat', iconName: 'videocam_off', color: 'F97316', actionType: 'hotkey', actionData: 'alt+v'),
          DeckButton(id: 'meet_3', label: 'Ekran Paylaş', iconName: 'screen_share', color: '22C55E', actionType: 'hotkey', actionData: 'alt+s'),
          DeckButton(id: 'meet_4', label: 'Sohbeti Aç', iconName: 'chat', color: '3B82F6', actionType: 'hotkey', actionData: 'alt+h'),
          DeckButton(id: 'meet_5', label: 'Tam Ekran', iconName: 'fullscreen', color: '8B5CF6', actionType: 'hotkey', actionData: 'alt+f'),
        ],
      ),
      DeckProfile(
        id: 'gaming',
        name: 'Oyun & Yayın (OBS)',
        iconName: 'sports_esports',
        color: 'EF4444',
        buttons: [
          DeckButton(id: 'g_1', label: 'Son 30sn Kaydet', iconName: 'save', color: 'F59E0B', actionType: 'hotkey', actionData: 'win+alt+g'),
          DeckButton(id: 'g_2', label: 'Kayıt Başlat/Durdur', iconName: 'videocam', color: 'F43F5E', actionType: 'hotkey', actionData: 'win+alt+r'),
          DeckButton(id: 'g_3', label: 'Xbox Game Bar', iconName: 'sports_esports', color: '22C55E', actionType: 'hotkey', actionData: 'win+g'),
          DeckButton(id: 'g_4', label: 'Mikrofonu Kapat', iconName: 'mic_off', color: 'EF4444', actionType: 'hotkey', actionData: 'win+alt+m'),
          DeckButton(id: 'g_5', label: 'Tam Ekran (Borderless)', iconName: 'fullscreen', color: '8B5CF6', actionType: 'hotkey', actionData: 'alt+enter'),
          DeckButton(id: 'g_6', label: 'Twitch Aç', iconName: 'web', color: '8B5CF6', actionType: 'url', actionData: 'https://twitch.tv'),
        ],
      ),
      DeckProfile(
        id: 'developer',
        name: 'Geliştirici (Dev)',
        iconName: 'code',
        color: '6366F1',
        buttons: [
          DeckButton(id: 'dev_1', label: 'Format Kod', iconName: 'format_align_left', color: '3B82F6', actionType: 'hotkey', actionData: 'shift+alt+f'),
          DeckButton(id: 'dev_2', label: 'Tümünü Kaydet', iconName: 'save_alt', color: '22C55E', actionType: 'hotkey', actionData: 'ctrl+k, s'),
          DeckButton(id: 'dev_3', label: 'Terminal Aç', iconName: 'terminal', color: '64748B', actionType: 'hotkey', actionData: 'ctrl+`'),
          DeckButton(id: 'dev_4', label: 'Arama (Tüm Proje)', iconName: 'search', color: 'F59E0B', actionType: 'hotkey', actionData: 'ctrl+shift+f'),
          DeckButton(id: 'dev_5', label: 'Satır Sil', iconName: 'delete', color: 'EF4444', actionType: 'hotkey', actionData: 'ctrl+shift+k'),
          DeckButton(id: 'dev_6', label: 'GitHub Aç', iconName: 'code', color: '64748B', actionType: 'url', actionData: 'https://github.com'),
        ],
      ),
      DeckProfile(
        id: 'netflix',
        name: 'Netflix',
        iconName: 'movie',
        color: 'E50914',
        buttons: [
          DeckButton(id: 'btn_netflix_movie', label: 'Netflix Aç (Film Modu)', iconName: 'movie', color: 'EF4444', actionType: 'movie_mode', actionData: '0'),
          DeckButton(id: 'nf_1', label: 'Oynat/Durdur', iconName: 'play_circle', color: 'EF4444', actionType: 'hotkey', actionData: 'space'),
          DeckButton(id: 'nf_2', label: 'Tam Ekran', iconName: 'fullscreen', color: '8B5CF6', actionType: 'hotkey', actionData: 'f'),
          DeckButton(id: 'nf_3', label: 'Sesi Kapat', iconName: 'volume_off', color: '64748B', actionType: 'hotkey', actionData: 'm'),
          DeckButton(id: 'nf_4', label: '10sn İleri', iconName: 'fast_forward', color: 'F59E0B', actionType: 'hotkey', actionData: 'right'),
          DeckButton(id: 'nf_5', label: '10sn Geri', iconName: 'fast_rewind', color: 'F59E0B', actionType: 'hotkey', actionData: 'left'),
        ],
      ),
    ];
    activeProfileId = 'general';
  }

  /// Execute a button's action
  Future<bool> executeAction(DeckButton button) async {
    return await _keySimulator.execute(button.actionType, button.actionData);
  }

  /// Add a new profile
  void addProfile(String name, String iconName, String color) {
    final id = 'profile_${DateTime.now().millisecondsSinceEpoch}';
    profiles.add(DeckProfile(
      id: id,
      name: name,
      iconName: iconName,
      color: color,
    ));
    save();
  }

  /// Remove a profile
  void removeProfile(String profileId) {
    profiles.removeWhere((p) => p.id == profileId);
    if (activeProfileId == profileId && profiles.isNotEmpty) {
      activeProfileId = profiles.first.id;
    }
    save();
  }

  /// Export a specific profile to JSON
  String exportProfileToJson(String profileId) {
    final profile = profiles.firstWhere((p) => p.id == profileId);
    return jsonEncode(profile.toJson());
  }

  /// Import a profile from a JSON string
  bool importProfileFromJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      final importedProfile = DeckProfile.fromJson(data);
      
      // Generate a new ID to avoid conflicts
      importedProfile.id = 'profile_${DateTime.now().millisecondsSinceEpoch}';
      
      // Handle name conflicts
      int suffix = 1;
      String newName = importedProfile.name;
      while (profiles.any((p) => p.name == newName)) {
        newName = '${importedProfile.name} ($suffix)';
        suffix++;
      }
      importedProfile.name = newName;
      
      profiles.add(importedProfile);
      activeProfileId = importedProfile.id; // Switch to the newly imported profile
      save();
      return true;
    } catch (e) {
      debugPrint('Error importing profile: $e');
      return false;
    }
  }

  /// Add a button to the active profile
  void addButton(DeckButton button) {
    activeProfile?.buttons.add(button);
    save();
  }

  /// Remove a button from the active profile
  void removeButton(String buttonId) {
    activeProfile?.buttons.removeWhere((b) => b.id == buttonId);
    save();
  }

  /// Update a button in the active profile
  void updateButton(DeckButton updated) {
    final profile = activeProfile;
    if (profile == null) return;
    final index = profile.buttons.indexWhere((b) => b.id == updated.id);
    if (index != -1) {
      profile.buttons[index] = updated;
      save();
    }
  }

  /// Get JSON representation of all profiles for API
  String toApiJson() {
    return jsonEncode({
      'profiles': profiles.map((p) => {
        'id': p.id,
        'name': p.name,
        'iconName': p.iconName,
        'color': p.color,
        'buttonCount': p.buttons.length,
      }).toList(),
      'activeProfileId': activeProfileId,
    });
  }

  /// Get JSON representation of buttons for a profile
  String buttonsToApiJson(String profileId) {
    DeckProfile? profile;
    try {
      profile = profiles.firstWhere((p) => p.id == profileId);
    } catch (_) {
      return '[]';
    }
    return jsonEncode(profile.buttons.map((b) => b.toJson()).toList());
  }
}

/// Helper to get IconData from icon name string
IconData getIconDataFromName(String name) {
  const iconMap = <String, IconData>{
    'touch_app': Icons.touch_app,
    'keyboard': Icons.keyboard,
    'launch': Icons.launch,
    'play_circle': Icons.play_circle,
    'volume_up': Icons.volume_up,
    'volume_down': Icons.volume_down,
    'volume_off': Icons.volume_off,
    'terminal': Icons.terminal,
    'folder_open': Icons.folder_open,
    'text_fields': Icons.text_fields,
    'link': Icons.link,
    'music_note': Icons.music_note,
    'videocam': Icons.videocam,
    'mic': Icons.mic,
    'screenshot': Icons.screenshot,
    'screen_share': Icons.screen_share,
    'cast': Icons.cast,
    'gamepad': Icons.gamepad,
    'sports_esports': Icons.sports_esports,
    'headset': Icons.headset,
    'speaker': Icons.speaker,
    'camera': Icons.camera,
    'brush': Icons.brush,
    'code': Icons.code,
    'bug_report': Icons.bug_report,
    'build': Icons.build,
    'settings': Icons.settings,
    'power_settings_new': Icons.power_settings_new,
    'lock': Icons.lock,
    'brightness_6': Icons.brightness_6,
    'wifi': Icons.wifi,
    'bluetooth': Icons.bluetooth,
    'notifications': Icons.notifications,
    'email': Icons.email,
    'chat': Icons.chat,
    'call': Icons.call,
    'sms': Icons.sms,
    'shopping_cart': Icons.shopping_cart,
    'favorite': Icons.favorite,
    'star': Icons.star,
    'bookmark': Icons.bookmark,
    'flag': Icons.flag,
    'home': Icons.home,
    'search': Icons.search,
    'add': Icons.add,
    'remove': Icons.remove,
    'delete': Icons.delete,
    'save': Icons.save,
    'share': Icons.share,
    'download': Icons.download,
    'upload': Icons.upload,
    'cloud': Icons.cloud,
    'monitor': Icons.monitor,
    'desktop_windows': Icons.desktop_windows,
    'web': Icons.web,
    'refresh': Icons.refresh,
    'content_copy': Icons.content_copy,
    'content_paste': Icons.content_paste,
    'undo': Icons.undo,
    'redo': Icons.redo,
    'skip_next': Icons.skip_next,
    'skip_previous': Icons.skip_previous,
    'dashboard': Icons.dashboard,
    'work': Icons.work,
    'fullscreen': Icons.fullscreen,
    'select_all': Icons.select_all,
    'print': Icons.print,
    'swap_horiz': Icons.swap_horiz,
    'stop': Icons.stop,
    'pause': Icons.pause,
    'fast_forward': Icons.fast_forward,
    'fast_rewind': Icons.fast_rewind,
    'movie': Icons.movie,
  };
  return iconMap[name] ?? Icons.touch_app;
}
