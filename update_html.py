import re

with open('lib/phone_link_app.dart', 'r', encoding='utf-8') as f:
    content = f.read()

new_html = r"""  String _getHtmlContent() {
    return r'''
<!DOCTYPE html>
<html lang="tr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">
<meta name="theme-color" content="#0f172a">
<meta name="apple-mobile-web-app-capable" content="yes">
<link rel="apple-touch-icon" href="/icon.svg">
<link rel="manifest" href="/manifest.json">
<title>Phone Link</title>
<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; font-family: 'Outfit', sans-serif; }
  body { 
    margin: 0; padding: 0; background: radial-gradient(circle at top right, #1e1b4b, #0f172a); 
    color: #f8fafc; min-height: 100vh; overflow-x: hidden;
  }
  .container { max-width: 800px; margin: 0 auto; padding: 24px; }
  .glass {
    background: rgba(255, 255, 255, 0.03); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);
    border: 1px solid rgba(255, 255, 255, 0.05); border-radius: 24px; box-shadow: 0 20px 40px rgba(0,0,0,0.4);
  }
  h1 { font-size: 28px; font-weight: 700; margin: 0 0 8px 0; background: linear-gradient(135deg, #60a5fa, #c084fc); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
  p { color: #94a3b8; margin: 0 0 24px 0; font-size: 15px; }
  .btn {
    background: linear-gradient(135deg, #3b82f6, #8b5cf6);
    color: white; border: none; padding: 16px 24px; border-radius: 16px; width: 100%;
    font-size: 16px; font-weight: 600; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px;
  }
  .btn:active { transform: scale(0.98); opacity: 0.9; }
  input[type="password"] {
    width: 100%; padding: 16px; border-radius: 16px; border: 1px solid rgba(255,255,255,0.1);
    background: rgba(0,0,0,0.2); color: white; font-size: 16px; outline: none; margin-bottom: 16px;
  }
  input[type="file"] { display: none; }
  
  .path-bar { display: flex; align-items: center; gap: 8px; padding: 12px 16px; background: rgba(0,0,0,0.2); border-radius: 12px; margin-bottom: 16px; overflow-x: auto; white-space: nowrap; font-size: 14px; }
  .path-item { cursor: pointer; color: #94a3b8; }
  .path-item:hover { color: white; }
  .path-sep { color: #475569; }
  
  .file-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); gap: 16px; }
  .file-card {
    background: rgba(255,255,255,0.02); border: 1px solid rgba(255,255,255,0.03); border-radius: 16px;
    padding: 16px; display: flex; flex-direction: column; align-items: center; text-decoration: none; cursor: pointer; position: relative; overflow: hidden;
  }
  .file-card:hover { background: rgba(255,255,255,0.06); }
  .file-icon-large {
    width: 60px; height: 60px; border-radius: 16px; display: flex; align-items: center; justify-content: center;
    margin-bottom: 12px; color: white; font-size: 24px; font-weight: bold;
  }
  .file-name { font-size: 13px; font-weight: 500; text-align: center; color: #f1f5f9; width: 100%; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .file-size { font-size: 11px; color: #64748b; margin-top: 4px; }
  .upload-status { margin-top: 16px; font-size: 14px; color: #94a3b8; text-align: center; height: 20px; font-weight: 500;}
  #login-view, #app-view { display: none; }
  .active-view { display: block !important; animation: fadeIn 0.4s ease; }
  @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
  .header { text-align: center; padding: 40px 0 20px 0; }
</style>
</head>
<body>

<div class="container">
  <div class="header">
    <h1>Phone Link</h1>
    <p id="subtitle">Bağlanılıyor...</p>
  </div>

  <div id="login-view" class="glass" style="padding: 32px; max-width: 400px; margin: 0 auto;">
    <h2 style="margin: 0 0 24px 0; font-size: 20px; text-align:center;">Güvenlik Parolası</h2>
    <input type="password" id="pwd" placeholder="PC'deki Parolayı Girin" onkeypress="if(event.key === 'Enter') login()">
    <button class="btn" onclick="login()">Bağlan</button>
    <div id="login-err" style="color: #f87171; text-align:center; margin-top: 16px; font-size:14px; display:none;">Parola hatalı</div>
  </div>

  <div id="app-view">
    <div class="glass" style="padding: 24px; text-align: center; margin-bottom: 24px;">
      <label class="btn" id="upload-btn">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="17 8 12 3 7 8"></polyline><line x1="12" y1="3" x2="12" y2="15"></line></svg>
        Şu Anki Klasöre Gönder (Foto/Dosya)
        <input type="file" id="filePicker" multiple>
      </label>
      <div id="upload-status" class="upload-status"></div>
    </div>
    
    <div class="glass" style="padding: 20px;">
      <div id="pathBar" class="path-bar"></div>
      <div id="fileList" class="file-grid"></div>
    </div>
  </div>
</div>

<script>
  let password = localStorage.getItem('pl_pwd') || '';
  let currentDir = ''; 
  
  async function api(path, options = {}) {
    const url = new URL(path, window.location.origin);
    url.searchParams.append('pwd', password);
    const res = await fetch(url, options);
    if (res.status === 401) {
      showLogin();
      throw new Error('Unauthorized');
    }
    return res;
  }

  function showLogin() {
    document.getElementById('app-view').classList.remove('active-view');
    document.getElementById('login-view').classList.add('active-view');
    document.getElementById('subtitle').innerText = 'Erişim için parola gerekli';
  }

  function showApp() {
    document.getElementById('login-view').classList.remove('active-view');
    document.getElementById('app-view').classList.add('active-view');
    document.getElementById('subtitle').innerText = 'Bağlantı Aktif';
    reportDevice();
    loadDirectory();
  }

  async function login() {
    password = document.getElementById('pwd').value;
    try {
      await api('/directories');
      localStorage.setItem('pl_pwd', password);
      document.getElementById('login-err').style.display = 'none';
      showApp();
    } catch (e) {
      document.getElementById('login-err').style.display = 'block';
    }
  }
  
  async function reportDevice() {
    let battery = 'Bilinmiyor';
    try {
      if (navigator.getBattery) {
        const bat = await navigator.getBattery();
        battery = Math.round(bat.level * 100) + '%';
      }
    } catch(e) {}
    
    const ua = navigator.userAgent;
    let deviceName = 'Akıllı Cihaz';
    if (/iPhone/i.test(ua)) deviceName = 'Apple iPhone';
    else if (/iPad/i.test(ua)) deviceName = 'Apple iPad';
    else if (/Android/i.test(ua)) {
      const match = ua.match(/Android.*?; (.*?) Build/i);
      deviceName = match ? match[1] : 'Android Cihaz';
    }
    
    api('/connect', {
      method: 'POST',
      body: JSON.stringify({ device: deviceName, battery: battery, os: ua.includes('Mac') ? 'iOS' : 'Android' })
    }).catch(()=>{});
  }

  api('/directories').then(() => showApp()).catch(() => showLogin());

  document.getElementById('filePicker').addEventListener('change', async (e) => {
    const files = e.target.files;
    if (files.length === 0) return;
    if (currentDir === '') {
      alert('Lütfen önce bir klasör seçin!');
      return;
    }
    const status = document.getElementById('upload-status');
    let successCount = 0;
    
    for (let i=0; i<files.length; i++) {
      const file = files[i];
      status.innerText = `${i+1}/${files.length}: ${file.name} yükleniyor...`;
      try {
        const res = await api(`/upload?dir=${encodeURIComponent(currentDir)}&name=${encodeURIComponent(file.name)}`, { method: 'POST', body: file });
        if (res.ok) successCount++;
      } catch(err) {}
    }
    
    status.innerText = successCount > 0 ? `${successCount} dosya aktarıldı!` : 'Aktarım başarısız.';
    document.getElementById('filePicker').value = '';
    setTimeout(() => { status.innerText = ''; }, 3000);
    loadDirectory();
  });
  
  function getFileIcon(filename) {
    const ext = filename.split('.').pop().toLowerCase();
    if(['exe', 'msi'].includes(ext)) return { bg: 'linear-gradient(135deg, #ef4444, #b91c1c)', icon: 'EXE' };
    if(['apk'].includes(ext)) return { bg: 'linear-gradient(135deg, #22c55e, #15803d)', icon: 'APK' };
    if(['jpg','jpeg','png','gif','webp'].includes(ext)) return { bg: 'linear-gradient(135deg, #a855f7, #7e22ce)', icon: 'IMG' };
    if(['mp4','mov','avi','mkv'].includes(ext)) return { bg: 'linear-gradient(135deg, #ec4899, #be185d)', icon: 'VID' };
    if(['mp3','wav','ogg'].includes(ext)) return { bg: 'linear-gradient(135deg, #f59e0b, #b45309)', icon: 'MUS' };
    if(['pdf'].includes(ext)) return { bg: 'linear-gradient(135deg, #ef4444, #991b1b)', icon: 'PDF' };
    if(['zip','rar','7z'].includes(ext)) return { bg: 'linear-gradient(135deg, #64748b, #334155)', icon: 'ZIP' };
    return { bg: 'linear-gradient(135deg, #3b82f6, #1d4ed8)', icon: 'FILE' };
  }
  
  function formatSize(bytes) {
    if(bytes === undefined || bytes === null || bytes === 0) return '';
    const k = 1024, sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
  }

  function renderPathBar() {
    const bar = document.getElementById('pathBar');
    if (currentDir === '') {
      bar.innerHTML = `<span class="path-item" style="color:white;font-weight:bold;">🏠 PC Klasörleri</span>`;
      return;
    }
    
    let parts = currentDir.split('/');
    let html = `<span class="path-item" onclick="navTo('')">🏠</span>`;
    let currentPath = '';
    
    for (let i = 0; i < parts.length; i++) {
       html += ` <span class="path-sep">/</span> `;
       currentPath += (i === 0 ? '' : '/') + parts[i];
       const isLast = i === parts.length - 1;
       if (isLast) {
         html += `<span style="color:white;font-weight:bold;">${parts[i]}</span>`;
       } else {
         const p = currentPath;
         html += `<span class="path-item" onclick="navTo('${p}')">${parts[i]}</span>`;
       }
    }
    bar.innerHTML = html;
  }

  function navTo(path) {
    currentDir = path;
    loadDirectory();
  }
  
  function upDir() {
    if (currentDir === '') return;
    let parts = currentDir.split('/');
    parts.pop();
    currentDir = parts.join('/');
    loadDirectory();
  }

  async function loadDirectory() {
    renderPathBar();
    try {
      const url = currentDir === '' ? '/directories' : `/files?dir=${encodeURIComponent(currentDir)}`;
      const res = await api(url);
      const items = await res.json();
      
      const list = document.getElementById('fileList');
      if (items.length === 0) { 
        list.innerHTML = `<div style="grid-column: 1 / -1; text-align:center; padding: 40px; color:#64748b;">Klasör boş.</div>`; 
      } else {
        let html = '';
        if (currentDir !== '') {
           html += `
             <div class="file-card" onclick="upDir()" style="padding:12px; justify-content:center;">
               <div class="file-icon-large" style="background:rgba(255,255,255,0.05); color:#94a3b8; font-size:32px;">↰</div>
               <div class="file-name">Geri Git</div>
             </div>
           `;
        }
        
        items.forEach(f => {
          if (currentDir === '') {
            html += `
             <div class="file-card" onclick="navTo('${f.name}')" style="padding:12px;">
               <div class="file-icon-large" style="background:linear-gradient(135deg, #f59e0b, #d97706);">📁</div>
               <div class="file-name" title="${f.name}">${f.name}</div>
             </div>
            `;
          } else {
            if (f.isDir) {
               html += `
                 <div class="file-card" onclick="navTo('${currentDir}/${f.name}')" style="padding:12px;">
                   <div class="file-icon-large" style="background:linear-gradient(135deg, #f59e0b, #d97706);">📁</div>
                   <div class="file-name" title="${f.name}">${f.name}</div>
                 </div>
               `;
            } else {
               const ext = f.name.split('.').pop().toLowerCase();
               const isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].includes(ext);
               const style = getFileIcon(f.name);
               const isFromPC = f.origin === 'PC';
               const iconSvg = isFromPC 
                 ? `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#22c55e" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>`
                 : `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#3b82f6" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="17 8 12 3 7 8"></polyline><line x1="12" y1="3" x2="12" y2="15"></line></svg>`;
               const bg = isFromPC ? 'rgba(34,197,94,0.2)' : 'rgba(59,130,246,0.2)';
               
               const fileUrl = `/download/${encodeURIComponent(f.name)}?pwd=${encodeURIComponent(password)}&dir=${encodeURIComponent(currentDir)}`;
               const preview = isImage 
                 ? `<img src="${fileUrl}" style="width:100%; height:100%; object-fit:cover; border-radius:12px;">` 
                 : `${style.icon}`;
      
               html += `
               <a class="file-card" href="${fileUrl}" download style="padding:12px;">
                 <div style="position:absolute; top:8px; right:8px; background:${bg}; border-radius:50%; padding:6px; display:flex; z-index:10; box-shadow: 0 2px 4px rgba(0,0,0,0.2);">
                   ${iconSvg}
                 </div>
                 <div class="file-icon-large" style="background: ${isImage ? 'transparent' : style.bg}; width: 100%; height: 80px; margin-bottom: 8px;">
                   ${preview}
                 </div>
                 <div class="file-name" title="${f.name}">${f.name}</div>
                 <div class="file-size">${formatSize(f.size)}</div>
               </a>
               `;
            }
          }
        });
        list.innerHTML = html;
      }
    } catch(e) {}
  }
  
  setInterval(() => {
    if(document.getElementById('app-view').classList.contains('active-view')) loadDirectory();
  }, 3500);
</script>
</body>
</html>
    ''';
  }"""

content = re.sub(r"  String _getHtmlContent\(\) \{[\s\S]*?    ''';\n  \}", new_html, content)

with open('lib/phone_link_app.dart', 'w', encoding='utf-8') as f:
    f.write(content)
