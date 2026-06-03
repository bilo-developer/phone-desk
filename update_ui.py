import re

with open('lib/phone_link_app.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the header of the right panel
old_header = '''                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.folder_shared_rounded, color: context.theme.primaryContainer),
                                        const SizedBox(width: 12),
                                        Text('Paylaşılanlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: context.theme.onSurface)),
                                      ],
                                    ),
                                    Text('${_sharedFiles.length} dosya', style: TextStyle(color: context.theme.onSurfaceVariant, fontSize: 13)),
                                  ],
                                ),
                              ),'''

new_header = '''                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => setState(() => _currentTab = 0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.folder_shared_rounded, color: _currentTab == 0 ? context.theme.primaryContainer : Colors.white54),
                                              const SizedBox(width: 8),
                                              Text('Dosyalar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _currentTab == 0 ? context.theme.onSurface : Colors.white54)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        InkWell(
                                          onTap: () => setState(() => _currentTab = 1),
                                          child: Row(
                                            children: [
                                              Icon(Icons.photo_library_rounded, color: _currentTab == 1 ? context.theme.accentPurple : Colors.white54),
                                              const SizedBox(width: 8),
                                              Text('Cihaz Galerisi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _currentTab == 1 ? context.theme.onSurface : Colors.white54)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text('${_currentTab == 0 ? _sharedFiles.length : _sharedFiles.where((f) {
                                      final n = f.path.split(Platform.pathSeparator).last;
                                      final o = _fileOrigins[n] ?? "PC";
                                      final e = n.split(".").last.toLowerCase();
                                      return o == "Phone" && ["jpg","jpeg","png","gif","webp","mp4","mov"].contains(e);
                                    }).length} öğe', style: TextStyle(color: context.theme.onSurfaceVariant, fontSize: 13)),
                                  ],
                                ),
                              ),'''

content = content.replace(old_header, new_header)


old_grid = '''                              Expanded(
                                child: _sharedFiles.isEmpty
                                    ? Center('''

new_grid = '''                              Expanded(
                                child: _currentTab == 1 
                                  ? _buildGalleryView()
                                  : _sharedFiles.isEmpty
                                    ? Center('''

content = content.replace(old_grid, new_grid)

# Insert _buildGalleryView method right above `Widget build(BuildContext context)`
gallery_method = '''
  Widget _buildGalleryView() {
    final mediaFiles = _sharedFiles.where((f) {
      final name = f.path.split(Platform.pathSeparator).last;
      if (name == '.metadata.json') return false;
      final origin = _fileOrigins[name] ?? 'PC';
      final ext = name.split('.').last.toLowerCase();
      return origin == 'Phone' && ['jpg','jpeg','png','gif','webp','mp4','mov'].contains(ext);
    }).toList();

    if (mediaFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: context.theme.outline.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('Telefondan henüz fotoğraf\\ngönderilmedi.', textAlign: TextAlign.center, style: TextStyle(color: context.theme.outline, height: 1.5)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: mediaFiles.length,
      itemBuilder: (context, index) {
        final file = mediaFiles[index];
        final fileName = file.path.split(Platform.pathSeparator).last;
        final isVideo = ['mp4', 'mov'].contains(fileName.split('.').last.toLowerCase());

        return InkWell(
          onTap: () => _openFile(file.path),
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isVideo
                    ? Container(
                        color: Colors.black12,
                        child: const Icon(Icons.videocam_rounded, color: Colors.white54, size: 32),
                      )
                    : Image.file(file, fit: BoxFit.cover, filterQuality: FilterQuality.low),
              ),
              if (isVideo)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('VIDEO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build('''

content = content.replace("  @override\n  Widget build(", gallery_method)

with open('lib/phone_link_app.dart', 'w', encoding='utf-8') as f:
    f.write(content)
