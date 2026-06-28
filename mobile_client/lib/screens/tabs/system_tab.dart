import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../widgets/glass_container.dart';
import '../../theme.dart';

class SystemTab extends StatefulWidget {
  const SystemTab({super.key});

  @override
  State<SystemTab> createState() => _SystemTabState();
}

class _SystemTabState extends State<SystemTab> with SingleTickerProviderStateMixin {
  Map<String, dynamic> _systemInfo = {};
  List<dynamic> _processes = [];
  bool _isLoading = true;
  bool _showProcesses = false;
  Timer? _refreshTimer;
  double _volumeSlider = 50;
  double _brightnessSlider = 50;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) => _loadData());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final info = await ApiService().getSystemInfo();
    if (_showProcesses) {
      final procs = await ApiService().getProcesses();
      if (mounted) setState(() => _processes = procs);
    }
    if (mounted) {
      setState(() {
        _systemInfo = info;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProcesses() async {
    final procs = await ApiService().getProcesses();
    if (mounted) setState(() => _processes = procs);
  }

  void _showPowerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Güç Yönetimi', style: TextStyle(color: AppTheme.onSurface, fontFamily: 'Inter')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _powerButton(Icons.power_settings_new, 'Kapat', 'shutdown', AppTheme.error),
            const SizedBox(height: 8),
            _powerButton(Icons.restart_alt, 'Yeniden Başlat', 'restart', AppTheme.tertiary),
            const SizedBox(height: 8),
            _powerButton(Icons.lock, 'Kilitle', 'lock', AppTheme.primary),
            const SizedBox(height: 8),
            _powerButton(Icons.bedtime, 'Uyku Modu', 'sleep', AppTheme.secondary),
            const SizedBox(height: 8),
            _powerButton(Icons.save, 'Hazırda Beklet', 'hibernate', AppTheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _powerButton(IconData icon, String label, String action, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          _confirmPowerAction(action, label);
        },
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: AppTheme.onSurface, fontFamily: 'Inter')),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.surfaceContainer,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _confirmPowerAction(String action, String label) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Emin misiniz?', style: const TextStyle(color: AppTheme.onSurface, fontFamily: 'Inter')),
        content: Text('PC\'yi "$label" işlemi uygulanacak.', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontFamily: 'Inter')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: AppTheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ApiService().systemPower(action);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text(label, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showClipboardDialog() async {
    final pcClipboard = await ApiService().getClipboard();
    if (!mounted) return;
    
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Pano Senkronizasyonu', style: TextStyle(color: AppTheme.onSurface, fontFamily: 'Inter')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PC Panosundaki Metin:', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, fontFamily: 'Inter')),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  pcClipboard.isEmpty ? '(boş)' : pcClipboard,
                  style: const TextStyle(color: AppTheme.onSurface, fontFamily: 'JetBrains Mono', fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: pcClipboard));
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Telefona kopyalandı!'), duration: Duration(seconds: 1)),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Telefona Kopyala'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryContainer, foregroundColor: AppTheme.onPrimaryContainer),
                ),
              ),
              const Divider(height: 32, color: AppTheme.outlineVariant),
              const Text('Telefon → PC\'ye Gönder:', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, fontFamily: 'Inter')),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.onSurface, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: 'Metin girin veya yapıştırın...',
                  hintStyle: TextStyle(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: AppTheme.surfaceContainer,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final data = await Clipboard.getData(Clipboard.kTextPlain);
                        if (data?.text != null) controller.text = data!.text!;
                      },
                      icon: const Icon(Icons.paste, size: 16),
                      label: const Text('Yapıştır'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.surfaceContainerHighest, foregroundColor: AppTheme.onSurface),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          ApiService().setClipboard(controller.text);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('PC panosuna gönderildi!'), duration: Duration(seconds: 1)),
                          );
                        }
                      },
                      icon: const Icon(Icons.send, size: 16),
                      label: const Text('PC\'ye Gönder'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.onPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    final cpu = _systemInfo['cpu'] as Map<String, dynamic>? ?? {};
    final ram = _systemInfo['ram'] as Map<String, dynamic>? ?? {};
    final disk = _systemInfo['disk'] as Map<String, dynamic>? ?? {};
    final gpu = _systemInfo['gpu'] as Map<String, dynamic>? ?? {};
    final os = _systemInfo['os'] as Map<String, dynamic>? ?? {};
    final uptime = _systemInfo['uptime'] as Map<String, dynamic>? ?? {};
    final battery = _systemInfo['battery'] as Map<String, dynamic>? ?? {};
    final network = _systemInfo['network'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 16),
              child: Row(
                children: [
                  const Icon(Icons.monitor_heart, color: AppTheme.primary, size: 28),
                  const SizedBox(width: 12),
                  const Text('Sistem', style: TextStyle(color: AppTheme.onSurface, fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                  const Spacer(),
                  GlassContainer(
                    padding: EdgeInsets.zero,
                    borderRadius: 12,
                    child: IconButton(
                      icon: const Icon(Icons.content_paste, color: AppTheme.onSurface, size: 20),
                      onPressed: _showClipboardDialog,
                      tooltip: 'Pano',
                    ),
                  ),
                  const SizedBox(width: 8),
                  GlassContainer(
                    padding: EdgeInsets.zero,
                    borderRadius: 12,
                    child: IconButton(
                      icon: const Icon(Icons.power_settings_new, color: AppTheme.error, size: 20),
                      onPressed: _showPowerDialog,
                      tooltip: 'Güç',
                    ),
                  ),
                ],
              ),
            ),
            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.inputGlass,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outlineGlow, width: 1),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppTheme.primaryContainer.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryContainer.withAlpha(77), width: 1),
                  ),
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.onSurfaceVariant,
                  labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Genel Bakış'),
                    Tab(text: 'İşlemler'),
                    Tab(text: 'Kontrol'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(cpu, ram, disk, gpu, os, uptime, battery, network),
                  _buildProcessesTab(),
                  _buildControlsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    Map<String, dynamic> cpu,
    Map<String, dynamic> ram,
    Map<String, dynamic> disk,
    Map<String, dynamic> gpu,
    Map<String, dynamic> os,
    Map<String, dynamic> uptime,
    Map<String, dynamic> battery,
    Map<String, dynamic> network,
  ) {
    final drives = (disk['drives'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
      children: [
        // Hostname + OS
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.computer, color: AppTheme.primaryContainer, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_systemInfo['hostname'] ?? 'PC', style: const TextStyle(color: AppTheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                    Text('${os['name'] ?? 'Windows'}', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, fontFamily: 'Inter')),
                    Text('Build ${os['build'] ?? ''} • ${os['arch'] ?? ''}', style: TextStyle(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 11, fontFamily: 'Inter')),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // CPU + RAM Row
        Row(
          children: [
            Expanded(child: _buildGaugeCard('CPU', cpu['usage'] ?? 0, '%', AppTheme.primaryContainer, subtitle: '${cpu['cores'] ?? 0}C/${cpu['threads'] ?? 0}T')),
            const SizedBox(width: 12),
            Expanded(child: _buildGaugeCard('RAM', ram['usagePercent'] ?? 0, '%', AppTheme.secondary, subtitle: '${ram['usedGB'] ?? 0}/${ram['totalGB'] ?? 0} GB')),
          ],
        ),
        const SizedBox(height: 12),
        // CPU Name
        GlassContainer(
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.memory, color: AppTheme.primaryContainer, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(cpu['name'] ?? 'Unknown CPU', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, fontFamily: 'Inter'), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // GPU
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.tertiaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.videogame_asset, color: AppTheme.tertiaryContainer, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GPU', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 11, fontFamily: 'Inter')),
                    Text(gpu['name'] ?? 'Unknown', style: const TextStyle(color: AppTheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter'), overflow: TextOverflow.ellipsis),
                    Text('VRAM: ${gpu['vramGB'] ?? 0} GB', style: TextStyle(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 11, fontFamily: 'Inter')),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Disks
        ...drives.map((d) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildDiskCard(d),
        )),
        const SizedBox(height: 12),
        // Bottom Row: Uptime + Battery + Network
        Row(
          children: [
            Expanded(child: _buildInfoCard(Icons.timer, 'Uptime', '${uptime['days'] ?? 0}g ${uptime['hours'] ?? 0}s ${uptime['minutes'] ?? 0}d', AppTheme.primary)),
            const SizedBox(width: 12),
            if (battery['hasBattery'] == true)
              Expanded(child: _buildInfoCard(
                battery['charging'] == true ? Icons.battery_charging_full : Icons.battery_std,
                'Pil',
                '${battery['percent'] ?? 0}%',
                battery['charging'] == true ? AppTheme.tertiaryContainer : AppTheme.secondary,
              )),
            if (battery['hasBattery'] != true)
              Expanded(child: _buildInfoCard(Icons.power, 'Güç', 'Takılı', AppTheme.tertiaryContainer)),
          ],
        ),
        const SizedBox(height: 12),
        // Network
        GlassContainer(
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.wifi, color: AppTheme.primary, size: 18),
              const SizedBox(width: 12),
              Text('↑ ${network['sentKBps'] ?? 0} KB/s', style: const TextStyle(color: AppTheme.onSurface, fontSize: 13, fontFamily: 'JetBrains Mono')),
              const SizedBox(width: 16),
              Text('↓ ${network['recvKBps'] ?? 0} KB/s', style: const TextStyle(color: AppTheme.onSurface, fontSize: 13, fontFamily: 'JetBrains Mono')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGaugeCard(String title, int value, String unit, Color color, {String? subtitle}) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 80,
                  width: 80,
                  child: CircularProgressIndicator(
                    value: value / 100,
                    strokeWidth: 6,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text('$value$unit', style: TextStyle(color: AppTheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: AppTheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
          if (subtitle != null)
            Text(subtitle, style: TextStyle(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 11, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildDiskCard(Map<String, dynamic> drive) {
    final usage = drive['usagePercent'] ?? 0;
    return GlassContainer(
      borderRadius: 12,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage, color: usage > 90 ? AppTheme.error : AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text('${drive['drive']}', style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
              const Spacer(),
              Text('${drive['usedGB']} / ${drive['totalGB']} GB', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, fontFamily: 'JetBrains Mono')),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: usage / 100,
              backgroundColor: AppTheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(usage > 90 ? AppTheme.error : AppTheme.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return GlassContainer(
      borderRadius: 12,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 11, fontFamily: 'Inter')),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: AppTheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
        ],
      ),
    );
  }

  Widget _buildProcessesTab() {
    if (_processes.isEmpty) {
      // Auto-load on first visit
      _showProcesses = true;
      _loadProcesses();
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('${_processes.length} İşlem', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontFamily: 'Inter')),
              const Spacer(),
              GlassContainer(
                padding: EdgeInsets.zero,
                borderRadius: 10,
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: AppTheme.onSurface, size: 20),
                  onPressed: _loadProcesses,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 120),
            itemCount: _processes.length,
            itemBuilder: (context, index) {
              final proc = _processes[index];
              final name = proc['name'] ?? '';
              final pid = proc['pid'] ?? 0;
              final memMB = (proc['memoryMB'] as num?)?.toDouble() ?? 0;

              return GlassContainer(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.apps, color: AppTheme.onSurfaceVariant, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w500, fontFamily: 'Inter', fontSize: 14), overflow: TextOverflow.ellipsis),
                          Text('PID: $pid  •  ${memMB.toStringAsFixed(0)} MB', style: TextStyle(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 11, fontFamily: 'JetBrains Mono')),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.error, size: 18),
                      onPressed: () => _confirmKillProcess(pid, name),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _confirmKillProcess(int pid, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('İşlemi Sonlandır?', style: TextStyle(color: AppTheme.onSurface, fontFamily: 'Inter')),
        content: Text('"$name" (PID: $pid) sonlandırılacak.', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontFamily: 'Inter')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: AppTheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService().killProcess(pid);
              await _loadProcesses();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Sonlandır', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsTab() {
    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120, top: 16),
      children: [
        // Volume
        GlassContainer(
          borderRadius: 12,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Volume', style: TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 14)),
                  Text('${_volumeSlider.round()}%', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontFamily: 'Inter', fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.volume_up, color: AppTheme.onSurface, size: 20),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.primary,
                        inactiveTrackColor: AppTheme.surfaceContainerHighest,
                        thumbColor: AppTheme.primary,
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _volumeSlider,
                        min: 0,
                        max: 100,
                        onChanged: (val) => setState(() => _volumeSlider = val),
                        onChangeEnd: (val) => ApiService().setVolume(val.round()),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Brightness
        GlassContainer(
          borderRadius: 12,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Brightness', style: TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 14)),
                  Text('${_brightnessSlider.round()}%', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontFamily: 'Inter', fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.light_mode, color: AppTheme.onSurface, size: 20),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.secondary,
                        inactiveTrackColor: AppTheme.surfaceContainerHighest,
                        thumbColor: AppTheme.secondary,
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _brightnessSlider,
                        min: 0,
                        max: 100,
                        onChanged: (val) => setState(() => _brightnessSlider = val),
                        onChangeEnd: (val) => ApiService().setBrightness(val.round()),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Power Grid Section
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildPowerGridBtn(Icons.power_settings_new, 'Shutdown', AppTheme.error, 'shutdown'),
            _buildPowerGridBtn(Icons.restart_alt, 'Restart', AppTheme.primary, 'restart'),
            _buildPowerGridBtn(Icons.mode_night, 'Sleep', AppTheme.secondary, 'sleep'),
            _buildPowerGridBtn(Icons.lock, 'Lock', AppTheme.tertiary, 'lock'),
          ],
        ),
        const SizedBox(height: 16),
        // Quick Actions
        GlassContainer(
          borderRadius: 12,
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showClipboardDialog,
              icon: const Icon(Icons.content_paste),
              label: const Text('Clipboard Sync'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceContainer,
                foregroundColor: AppTheme.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPowerGridBtn(IconData icon, String label, Color color, String action) {
    return InkWell(
      onTap: () => _confirmPowerAction(action, label),
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        borderRadius: 20,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: AppTheme.onSurface, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
