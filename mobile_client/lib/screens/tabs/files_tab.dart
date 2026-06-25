import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import '../../widgets/glass_container.dart';

class FilesTab extends StatefulWidget {
  const FilesTab({super.key});

  @override
  State<FilesTab> createState() => _FilesTabState();
}

class _FilesTabState extends State<FilesTab> {
  List<dynamic> _directories = [];
  List<dynamic> _files = [];
  List<String> _currentPath = [];
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
      _currentPath = [_directories.first['name']];
      await _loadFiles();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFiles() async {
    if (_currentPath.isEmpty) return;
    setState(() => _isLoading = true);
    final dirName = _currentPath.join('/');
    _files = await ApiService().getFiles(dirName);
    setState(() => _isLoading = false);
  }

  void _downloadFile(String fileName) async {
    if (_currentPath.isEmpty) return;
    final dirName = _currentPath.join('/');
    final url = '${ApiService().baseUrl}/download/${Uri.encodeComponent(fileName)}?dir=${Uri.encodeComponent(dirName)}&pwd=${ApiService().password}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _uploadFile() async {
    if (_currentPath.isEmpty) return;
    final dirName = _currentPath.join('/');
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() => _isLoading = true);
      try {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final url = Uri.parse('${ApiService().baseUrl}/upload?dir=${Uri.encodeComponent(dirName)}&name=${Uri.encodeComponent(fileName)}');
        final bytes = await file.readAsBytes();
        await http.post(url, headers: ApiService().headers, body: bytes);
        await _loadFiles();
      } catch (_) {}
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoot = _currentPath.isNotEmpty ? _currentPath.first : null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  if (_currentPath.length > 1)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _currentPath.removeLast();
                        });
                        _loadFiles();
                      },
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _directories.map((d) {
                          final rootName = d['name'];
                          final isSelected = rootName == currentRoot;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ChoiceChip(
                              label: Text(rootName),
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) {
                                  _currentPath = [rootName];
                                  _loadFiles();
                                }
                              },
                              selectedColor: Colors.blueAccent.withAlpha(128),
                              backgroundColor: Colors.white.withAlpha(26),
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  GlassContainer(
                    padding: EdgeInsets.zero,
                    child: IconButton(
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      onPressed: _uploadFile,
                      tooltip: 'Dosya Yükle',
                    ),
                  ),
                ],
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
                    return GlassContainer(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      opacity: 0.1,
                      child: ListTile(
                        onTap: isDir ? () {
                          setState(() {
                            _currentPath.add(name);
                          });
                          _loadFiles();
                        } : null,
                        leading: Icon(
                          isDir ? Icons.folder : Icons.insert_drive_file,
                          color: isDir ? Colors.amber : Colors.blueAccent,
                        ),
                        title: Text(name, style: const TextStyle(color: Colors.white)),
                        subtitle: isDir ? null : Text('$size bytes', style: const TextStyle(color: Colors.white54)),
                        trailing: isDir ? const Icon(Icons.chevron_right, color: Colors.white38) : IconButton(
                          icon: const Icon(Icons.download, color: Colors.white70),
                          onPressed: () => _downloadFile(name),
                        ),
                      ),
                    );
                  },
                ),
          ),
          const SizedBox(height: 60), // Bottom nav bar spacing
        ],
      ),
    );
  }
}
