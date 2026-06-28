import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String ipAddress = '';
  int port = 8080;
  String password = '';

  String get baseUrl => 'http://$ipAddress:$port';

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    ipAddress = prefs.getString('ipAddress') ?? '';
    port = prefs.getInt('port') ?? 8080;
    password = prefs.getString('password') ?? '';
  }

  Future<void> saveConfig(String ip, int p, String pwd) async {
    ipAddress = ip;
    port = p;
    password = pwd;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ipAddress', ip);
    await prefs.setInt('port', p);
    await prefs.setString('password', pwd);
  }

  Map<String, String> get headers => {
    'Authorization': password,
    'Content-Type': 'application/json',
  };

  Future<bool> connect(Map<String, dynamic> deviceInfo) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/connect'),
        headers: headers,
        body: jsonEncode(deviceInfo),
      ).timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> sendMouse(String action, {double? x, double? y, bool? click, int? dx, int? dy}) async {
    try {
      final map = <String, dynamic>{'action': action};
      if (x != null) map['x'] = x;
      if (y != null) map['y'] = y;
      if (click != null) map['click'] = click;
      if (dx != null) map['dx'] = dx;
      if (dy != null) map['dy'] = dy;
      await http.post(
        Uri.parse('$baseUrl/mouse'),
        headers: headers,
        body: jsonEncode(map),
      );
    } catch (_) {}
  }

  Future<List<dynamic>> getDirectories() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/directories'), headers: headers);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return [];
  }

  Future<List<dynamic>> getFiles(String dir) async {
    try {
      final encodedDir = Uri.encodeComponent(dir);
      final res = await http.get(Uri.parse('$baseUrl/files?dir=$encodedDir'), headers: headers);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>> getDeckProfiles() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/deck/profiles'), headers: headers);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return {};
  }

  Future<List<dynamic>> getDeckButtons(String profileId) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/deck/buttons?profile=$profileId'), headers: headers);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return [];
  }

  Future<void> executeDeckButton(Map<String, dynamic> button) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/deck/execute'),
        headers: headers,
        body: jsonEncode(button),
      );
    } catch (_) {}
  }

  Future<bool> addDeckButton(String profileId, Map<String, dynamic> button) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/deck/add-button'),
        headers: headers,
        body: jsonEncode({'profileId': profileId, 'button': button}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteDeckButton(String profileId, String buttonId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/deck/delete-button'),
        headers: headers,
        body: jsonEncode({'profileId': profileId, 'buttonId': buttonId}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/password/update'),
        headers: headers,
        body: jsonEncode({'newPassword': newPassword}),
      );
      if (res.statusCode == 200) {
        password = newPassword;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('password', newPassword);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  String screenStreamUrl([String? displayId, int fps = 15, int res = 1080]) {
    String url = '$baseUrl/screen/frame?pwd=$password&fps=$fps&res=$res';
    if (displayId != null && displayId.isNotEmpty) {
      url += '&displayId=$displayId';
    }
    return url;
  }

  String screenSnapshotUrl([String? displayId]) {
    String url = '$baseUrl/screen/snapshot?pwd=$password&t=${DateTime.now().millisecondsSinceEpoch}';
    if (displayId != null && displayId.isNotEmpty) {
      url += '&displayId=${Uri.encodeComponent(displayId)}';
    }
    return url;
  }

  Future<void> sendMouseAbsolute(double xPct, double yPct, {bool click = false}) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/mouse'),
        headers: headers,
        body: jsonEncode({
          'action': 'absolute',
          'x': xPct,
          'y': yPct,
          'click': click,
        }),
      );
    } catch (_) {}
  }

  Future<List<dynamic>> getDisplays() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/displays'), headers: headers);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        debugPrint('getDisplays error: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      debugPrint('getDisplays exception: $e');
    }
    return [];
  }
  
  Future<void> stopScreenStream() async {
    try {
      await http.post(Uri.parse('$baseUrl/screen/stop'), headers: headers);
    } catch (_) {}
  }

  // ===== SYSTEM INFO =====

  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/system/info'), headers: headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return {};
  }

  Future<List<dynamic>> getProcesses() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/system/processes'), headers: headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return [];
  }

  Future<bool> killProcess(int pid) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/system/kill-process'),
        headers: headers,
        body: jsonEncode({'pid': pid}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ===== CLIPBOARD =====

  Future<String> getClipboard() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/clipboard'), headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['text'] ?? '';
      }
    } catch (_) {}
    return '';
  }

  Future<bool> setClipboard(String text) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/clipboard'),
        headers: headers,
        body: jsonEncode({'text': text}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ===== KEYBOARD =====

  Future<void> sendKeyboard(String type, String value) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/keyboard'),
        headers: headers,
        body: jsonEncode({'type': type, 'value': value}),
      );
    } catch (_) {}
  }

  // ===== POWER =====

  Future<bool> systemPower(String action) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/system/power'),
        headers: headers,
        body: jsonEncode({'action': action}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ===== VOLUME =====

  Future<int> getVolume() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/system/volume'), headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['volume'] ?? 50;
      }
    } catch (_) {}
    return 50;
  }

  Future<bool> setVolume(int level) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/system/volume'),
        headers: headers,
        body: jsonEncode({'volume': level}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ===== BRIGHTNESS =====

  Future<bool> setBrightness(int level) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/system/brightness'),
        headers: headers,
        body: jsonEncode({'brightness': level}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ===== NOTIFICATIONS =====

  Future<List<dynamic>> getNotifications() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/notifications'), headers: headers);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return [];
  }
}
