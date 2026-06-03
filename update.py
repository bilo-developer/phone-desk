import re

with open('lib/phone_link_app.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Variables and Getters
var_replacement = '''  int _currentTab = 0; // 0: Dosyalar, 1: Galeri

  @override
  void initState() {'''
content = re.sub(r'  @override\s+void initState\(\) \{', var_replacement, content)

dirs_replacement = '''  String get _home {
    if (Platform.isWindows) return Platform.environment['USERPROFILE'] ?? Directory.current.path;
    return Platform.environment['HOME'] ?? Directory.current.path;
  }

  Map<String, String> get _rootDirs {
    final sep = Platform.pathSeparator;
    return {
      'PhoneLink': '$_home${sep}Downloads${sep}PhoneLink',
      'İndirilenler': '$_home${sep}Downloads',
      'Masaüstü': '$_home${sep}Desktop',
      'Belgeler': '$_home${sep}Documents',
      'Resimler': '$_home${sep}Pictures',
      'Videolar': '$_home${sep}Videos',
    };
  }
  
  String get _phoneLinkDir => _rootDirs['PhoneLink']!;

  String _getRealPath(String virtualPath) {
    if (virtualPath.isEmpty) return '';
    final parts = virtualPath.split('/');
    final rootName = Uri.decodeComponent(parts.first);
    if (!_rootDirs.containsKey(rootName)) return '';
    
    var realPath = _rootDirs[rootName]!;
    if (parts.length > 1) {
      for (int i = 1; i < parts.length; i++) {
         final p = Uri.decodeComponent(parts[i]);
         if (p == '..' || p == '.') continue;
         realPath += '${Platform.pathSeparator}$p';
      }
    }
    return realPath;
  }

  String _sanitizeFileName(String name) {'''

content = re.sub(r'  String get _downloadsDir \{[\s\S]*?  String _sanitizeFileName\(String name\) \{', dirs_replacement, content)
content = content.replace('_downloadsDir', '_phoneLinkDir')

with open('lib/phone_link_app.dart', 'w', encoding='utf-8') as f:
    f.write(content)
