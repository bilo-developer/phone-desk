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

  String get screenStreamUrl => '$baseUrl/screen/frame?pwd=$password';
  
  Future<void> stopScreenStream() async {
    try {
      await http.post(Uri.parse('$baseUrl/screen/stop'), headers: headers);
    } catch (_) {}
  }
}
