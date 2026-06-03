import re

with open('lib/phone_link_app.dart', 'r', encoding='utf-8') as f:
    content = f.read()

endpoints_replacement = '''        if (request.method == 'GET' && path == '/directories') {
          final dirs = _rootDirs.keys.map((k) => {'name': k, 'path': k}).toList();
          response.headers.contentType = ContentType.json;
          response.write(jsonEncode(dirs));
          await response.close();
          continue;
        }
        if (request.method == 'GET' && path == '/files') {
          final reqDir = request.uri.queryParameters['dir'] ?? 'PhoneLink';
          final realPath = _getRealPath(reqDir);
          
          if (realPath.isEmpty) {
            response.statusCode = 400;
            response.write('[]');
            await response.close();
            continue;
          }
          
          final dir = Directory(realPath);
          if (!await dir.exists()) {
             if (reqDir == 'PhoneLink') await dir.create(recursive: true);
             else { response.statusCode = 404; await response.close(); continue; }
          }
          
          final list = <Map<String, dynamic>>[];
          try {
            final entities = dir.listSync();
            for (var e in entities) {
              final name = e.path.split(Platform.pathSeparator).last;
              if (name == '.metadata.json' || name.startsWith('.')) continue;
              final stat = e.statSync();
              list.add({
                'name': name,
                'isDir': stat.type == FileSystemEntityType.directory,
                'size': stat.size,
                'origin': (reqDir == 'PhoneLink') ? (_fileOrigins[name] ?? 'PC') : 'PC',
              });
            }
          } catch(err) {}
            
          response.headers.contentType = ContentType.json;
          response.write(jsonEncode(list));
          await response.close();
        }
        else if (request.method == 'GET' && path.startsWith('/download/')) {
          final rawFileName = Uri.decodeComponent(path.substring('/download/'.length));
          final reqDir = request.uri.queryParameters['dir'] ?? 'PhoneLink';
          final realPath = _getRealPath(reqDir);
          final safeFileName = _sanitizeFileName(rawFileName);
          
          if (realPath.isEmpty) { response.statusCode = 404; await response.close(); continue; }
          
          final file = File('$realPath${Platform.pathSeparator}$safeFileName');
          if (await file.exists()) {
            response.headers.contentType = ContentType.binary;
            response.headers.add('Content-Disposition', 'attachment; filename="$safeFileName"');
            await response.addStream(file.openRead());
          } else {
            response.statusCode = 404;
            response.write('Dosya bulunamadı');
          }
          await response.close();
        }
        else if (request.method == 'POST' && path == '/upload') {
          final rawFileName = Uri.decodeComponent(request.uri.queryParameters['name'] ?? 'unknown_file');
          final reqDir = request.uri.queryParameters['dir'] ?? 'PhoneLink';
          final realPath = _getRealPath(reqDir);
          final safeFileName = _sanitizeFileName(rawFileName);
          
          if (realPath.isEmpty) { response.statusCode = 400; await response.close(); continue; }
          
          final dir = Directory(realPath);
          if (!await dir.exists()) await dir.create(recursive: true);
          
          final file = File('$realPath${Platform.pathSeparator}$safeFileName');
          final sink = file.openWrite();
          await sink.addStream(request);
          await sink.flush();
          await sink.close();
          
          if (reqDir == 'PhoneLink') {
            _fileOrigins[safeFileName] = 'Phone';
            _saveMetadata();
            _loadSharedFiles();
          }
          response.statusCode = 200;
          response.write('OK');
          await response.close();
        }'''

# Replace the specific block of if/else if starting with /files
content = re.sub(r"        if \(request\.method == 'GET' && path == '/files'\) \{[\s\S]*?response\.statusCode = 200;\s+response\.write\('OK'\);\s+await response\.close\(\);\s+\}", endpoints_replacement, content)

with open('lib/phone_link_app.dart', 'w', encoding='utf-8') as f:
    f.write(content)
