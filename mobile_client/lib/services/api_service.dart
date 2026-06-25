import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  String screenStreamUrl([String? displayId]) {
    String url = '$baseUrl/screen/frame?pwd=$password';
    if (displayId != null && displayId.isNotEmpty) {
      url += '&displayId=$displayId';
    }
    return url;
  }

  Future<List<dynamic>> getDisplays() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/displays'), headers: headers);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return [];
  }
  
  Future<void> stopScreenStream() async {
    try {
      await http.post(Uri.parse('$baseUrl/screen/stop'), headers: headers);
    } catch (_) {}
  }
}
