import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import '../widgets/glass_container.dart';
import '../widgets/app_background.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController(text: '8080');
  final _pwdController = TextEditingController();
  bool _isScanning = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    await ApiService().loadConfig();
    setState(() {
      _ipController.text = ApiService().ipAddress;
      if (ApiService().port != 0) {
        _portController.text = ApiService().port.toString();
      }
      _pwdController.text = ApiService().password;
    });
  }

  Future<void> _connect() async {
    setState(() => _isLoading = true);
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 8080;
    final pwd = _pwdController.text.trim();

    await ApiService().saveConfig(ip, port, pwd);
    
    String deviceName = 'MobileClient';
    int? batteryLevel;
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        deviceName = (await deviceInfo.androidInfo).model;
      } else if (Platform.isIOS) {
        deviceName = (await deviceInfo.iosInfo).name;
      }
      batteryLevel = await Battery().batteryLevel;
    } catch (_) {}

    final success = await ApiService().connect({
      'name': deviceName,
      'battery': batteryLevel,
    });
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bağlantı kurulamadı veya şifre hatalı.')),
      );
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;
    final String code = capture.barcodes.first.rawValue ?? '';
    if (code.startsWith('http://')) {
      final uri = Uri.tryParse(code);
      if (uri != null) {
        setState(() {
          _ipController.text = uri.host;
          _portController.text = uri.port.toString();
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isScanning) {
      return Scaffold(
        appBar: AppBar(title: const Text('QR Kodu Okutun')),
        body: Stack(
          children: [
            MobileScanner(onDetect: _onDetect),
            Positioned(
              bottom: 40, left: 0, right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () => setState(() => _isScanning = false),
                  child: const Text('İptal'),
                ),
              ),
            )
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: GlassContainer(
                  padding: const EdgeInsets.all(32.0),
                  borderRadius: 32.0,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(13),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withAlpha(25)),
                        ),
                        child: const Center(
                          child: Icon(Icons.settings_remote, size: 48, color: AppTheme.primary),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Phone Desk', style: TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.onSurface, letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      const Text('Bilgisayarınıza Bağlanın', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppTheme.onSurfaceVariant)),
                      const SizedBox(height: 40),
                      _buildTextField(
                        controller: _ipController,
                        label: 'IP Adresi',
                        icon: Icons.router,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: _buildTextField(
                              controller: _portController,
                              label: 'Port',
                              icon: null,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 8,
                            child: _buildTextField(
                              controller: _pwdController,
                              label: 'Güvenlik Şifresi',
                              icon: Icons.lock,
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppTheme.primaryContainer, AppTheme.inversePrimary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.inversePrimary.withAlpha(102),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: _isLoading ? null : _connect,
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: AppTheme.onPrimary)
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text('Bağlan', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onPrimary)),
                                        const SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 20, color: AppTheme.onPrimary),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Divider(color: Color(0x0DFFFFFF), height: 1),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: AppTheme.onSurfaceVariant),
                        onPressed: () => setState(() => _isScanning = true),
                        icon: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(13),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.qr_code_scanner, size: 20),
                        ),
                        label: const Text('QR Kod ile Bağlan', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Güvenli bağlantı AES-256 ile uçtan uca şifrelenir.',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppTheme.onSurfaceVariant.withAlpha(102)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool obscureText = false,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.inputGlass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        textAlign: textAlign,
        style: const TextStyle(color: AppTheme.onSurface, fontFamily: 'Inter', fontSize: 16),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: AppTheme.onSurfaceVariant.withAlpha(128)),
          prefixIcon: icon != null ? Icon(icon, color: AppTheme.onSurfaceVariant) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
