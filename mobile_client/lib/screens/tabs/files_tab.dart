import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';

class FilesTab extends StatefulWidget {
  const FilesTab({super.key});

  @override
  State<FilesTab> createState() => _FilesTabState();
}

class _FilesTabState extends State<FilesTab> {
  List<dynamic> _directories = [];
  List<dynamic> _files = [];
  String? _currentDir;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDirectories();
  }

  Future<void> _loadDirectories() async {
    setState(() => _isLoading = true);
    _directories = await ApiService().getDirectories();
    if (_directories.isNotEmpty) {
      await _loadFiles(_directories.first['name']);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFiles(String dirName) async {
    setState(() {
      _currentDir = dirName;
      _isLoading = true;
    });
    _files = await ApiService().getFiles(dirName);
    setState(() => _isLoading = false);
  }

  void _downloadFile(String fileName) async {
    if (_currentDir == null) return;
    final url = '${ApiService().baseUrl}/download/${Uri.encodeComponent(fileName)}?dir=${Uri.encodeComponent(_currentDir!)}&pwd=${ApiService().password}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: _directories.map((d) {
                final isSelected = d['name'] == _currentDir;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(d['name']),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) _loadFiles(d['name']);
                    },
                    selectedColor: Colors.blueAccent,
                    backgroundColor: const Color(0xFF1E293B),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final f = _files[index];
                  final isDir = f['isDir'] == true;
                  final name = f['name'] ?? '';
                  final size = f['size'] ?? 0;
                  return ListTile(
                    leading: Icon(
                      isDir ? Icons.folder : Icons.insert_drive_file,
                      color: isDir ? Colors.amber : Colors.blueAccent,
                    ),
                    title: Text(name, style: const TextStyle(color: Colors.white)),
                    subtitle: isDir ? null : Text('$size bytes', style: const TextStyle(color: Colors.white54)),
                    trailing: isDir ? null : IconButton(
                      icon: const Icon(Icons.download, color: Colors.white70),
                      onPressed: () => _downloadFile(name),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}
