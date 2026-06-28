import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import '../../widgets/glass_container.dart';
import '../../theme.dart';

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
    
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İndirme başlatılamadı: $e', style: const TextStyle(fontFamily: 'Inter')),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _uploadFile() async {
    if (_currentPath.isEmpty) return;
    final dirName = _currentPath.join('/');
    FilePickerResult? result = await FilePicker.pickFiles();
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

  bool _isImage(String name) {
    final ext = name.split('.').last.toLowerCase();
    return ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'].contains(ext);
  }

  IconData _getFileIcon(String name, bool isDir) {
    if (isDir) return Icons.folder;
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'png': case 'jpg': case 'jpeg': case 'gif': case 'bmp': case 'webp': case 'svg':
        return Icons.image;
      case 'mp4': case 'avi': case 'mkv': case 'mov': case 'wmv':
        return Icons.videocam;
      case 'mp3': case 'wav': case 'flac': case 'aac': case 'ogg':
        return Icons.audiotrack;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc': case 'docx': case 'txt': case 'rtf':
        return Icons.description;
      case 'xls': case 'xlsx': case 'csv':
        return Icons.table_chart;
      case 'zip': case 'rar': case '7z': case 'tar': case 'gz':
        return Icons.archive;
      case 'exe': case 'msi':
        return Icons.apps;
      case 'ico':
        return Icons.image_aspect_ratio;
      case 'html': case 'css': case 'js': case 'dart': case 'py': case 'java':
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor(String name, bool isDir) {
    if (isDir) return AppTheme.tertiaryContainer;
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'png': case 'jpg': case 'jpeg': case 'gif': case 'bmp': case 'webp': case 'svg':
        return AppTheme.secondary;
      case 'mp4': case 'avi': case 'mkv': case 'mov':
        return AppTheme.error;
      case 'mp3': case 'wav': case 'flac':
        return AppTheme.tertiary;
      case 'pdf':
        return AppTheme.error;
      case 'zip': case 'rar': case '7z':
        return AppTheme.secondaryContainer;
      case 'exe': case 'msi':
        return AppTheme.primaryContainer;
      default:
        return AppTheme.primary;
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
              padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 4),
              child: Row(
                children: [
                  if (_currentPath.length > 1)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface, size: 20),
                        onPressed: () {
                          setState(() {
                            _currentPath.removeLast();
                          });
                          _loadFiles();
                        },
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        padding: EdgeInsets.zero,
                      ),
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
                            child: GestureDetector(
                              onTap: () {
                                _currentPath = [rootName];
                                _loadFiles();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryContainer.withAlpha(51)
                                      : AppTheme.inputGlass,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryContainer.withAlpha(77)
                                        : AppTheme.outlineGlow,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  rootName,
                                  style: TextStyle(
                                    color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GlassContainer(
                    padding: EdgeInsets.zero,
                    borderRadius: 12,
                    child: IconButton(
                      icon: const Icon(Icons.upload_file, color: AppTheme.onSurface, size: 20),
                      onPressed: _uploadFile,
                      tooltip: 'Dosya Yükle',
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 8, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _currentPath.length > 1 ? _currentPath.last : 'Dosyalar',
                style: const TextStyle(
                  color: AppTheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _files.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_open, color: AppTheme.onSurfaceVariant.withAlpha(77), size: 48),
                        const SizedBox(height: 12),
                        const Text('Klasör boş', style: TextStyle(color: AppTheme.onSurfaceVariant, fontFamily: 'Inter')),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      final f = _files[index];
                      final isDir = f['isDir'] == true;
                      final name = f['name'] ?? '';
                      final size = f['size'] ?? 0;

                      // Format size
                      String sizeStr = '$size bytes';
                      if (size > 1024 * 1024) {
                        sizeStr = '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
                      } else if (size > 1024) {
                        sizeStr = '${(size / 1024).toStringAsFixed(1)} KB';
                      }

                      return GlassContainer(
                        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: InkWell(
                          onTap: isDir 
                            ? () {
                                setState(() {
                                  _currentPath.add(name);
                                });
                                _loadFiles();
                              } 
                            : () {
                                if (_isImage(name)) {
                                  _showImagePreview(name);
                                } else {
                                  _showFileActions(name, sizeStr);
                                }
                              },
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _getFileIconColor(name, isDir).withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: (!isDir && _isImage(name))
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        '${ApiService().baseUrl}/download/${Uri.encodeComponent(name)}?dir=${Uri.encodeComponent(_currentPath.join('/'))}&pwd=${ApiService().password}',
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) => Icon(_getFileIcon(name, isDir), color: _getFileIconColor(name, isDir), size: 24),
                                        loadingBuilder: (ctx, child, progress) {
                                          if (progress == null) return child;
                                          return const Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          );
                                        },
                                      ),
                                    )
                                  : Icon(
                                      _getFileIcon(name, isDir),
                                      color: _getFileIconColor(name, isDir),
                                      size: 24,
                                    ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: const TextStyle(color: AppTheme.onSurface, fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14), overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text(isDir ? 'Klasör' : sizeStr, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontFamily: 'Inter', fontSize: 12)),
                                  ],
                                ),
                              ),
                              if (!isDir)
                                IconButton(
                                  icon: const Icon(Icons.download, color: AppTheme.primary, size: 22),
                                  onPressed: () => _downloadFile(name),
                                  tooltip: 'İndir',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                )
                              else
                                const Icon(Icons.chevron_right, color: AppTheme.onSurfaceVariant, size: 22),
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

  void _showImagePreview(String fileName) {
    final dirName = _currentPath.join('/');
    final url = '${ApiService().baseUrl}/download/${Uri.encodeComponent(fileName)}?dir=${Uri.encodeComponent(dirName)}&pwd=${ApiService().password}';
    
    showDialog(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.black.withAlpha(230),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator(color: AppTheme.primary);
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: GlassContainer(
                borderRadius: 30,
                padding: EdgeInsets.zero,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 16,
              child: GlassContainer(
                borderRadius: 30,
                padding: EdgeInsets.zero,
                child: IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _downloadFile(fileName);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFileActions(String fileName, String sizeStr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outlineGlow, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(fileName, style: const TextStyle(color: AppTheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
            const SizedBox(height: 4),
            Text(sizeStr, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13, fontFamily: 'Inter')),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.download, color: AppTheme.primary),
              title: const Text('İndir', style: TextStyle(color: AppTheme.onSurface, fontFamily: 'Inter')),
              onTap: () {
                Navigator.pop(ctx);
                _downloadFile(fileName);
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppTheme.inputGlass,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.close, color: AppTheme.error),
              title: const Text('İptal', style: TextStyle(color: AppTheme.error, fontFamily: 'Inter')),
              onTap: () => Navigator.pop(ctx),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppTheme.inputGlass,
            ),
          ],
        ),
      ),
    );
  }
}
