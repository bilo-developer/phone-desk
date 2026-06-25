import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/glass_container.dart';

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

  void _onProfileChanged(String? newId) async {
    if (newId == null) return;
    setState(() {
      _activeProfileId = newId;
      _isLoading = true;
    });
    _buttons = await ApiService().getDeckButtons(newId);
    setState(() => _isLoading = false);
  }

  void _onButtonTap(Map<String, dynamic> button) {
    ApiService().executeDeckButton(button);
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddButtonDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          SafeArea(
            child: GlassContainer(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _activeProfileId,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  items: _profiles.map((p) => DropdownMenuItem<String>(
                    value: p['id'],
                    child: Text(p['name']),
                  )).toList(),
                  onChanged: _onProfileChanged,
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _buttons.length,
              itemBuilder: (context, index) {
                final btn = _buttons[index];
                final label = btn['label'] ?? '';
                final colorHex = btn['color']?.replaceAll('#', 'FF') ?? 'FF3B82F6';
                final color = Color(int.parse(colorHex, radix: 16));

                return InkWell(
                  onTap: () => _onButtonTap(btn),
                  borderRadius: BorderRadius.circular(16),
                  child: GlassContainer(
                    opacity: 0.2,
                    borderColor: color.withAlpha(128),
                    child: Center(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 60), // Bottom nav bar space
        ],
      ),
    );
  }
}
