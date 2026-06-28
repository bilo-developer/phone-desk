// Generate the HTML content string for the web UI.
String getWebHtmlContent() {
  return r'''<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover"/>
    <meta name="apple-mobile-web-app-capable" content="yes">
    <title>Phone Desk</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Round" rel="stylesheet">
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: "#ADC6FF",
                        surface: "#111318",
                        onSurface: "#E1E2E8",
                        onSurfaceVariant: "#C4C6D0",
                        inputGlass: "rgba(255, 255, 255, 0.05)",
                        outlineGlow: "rgba(255, 255, 255, 0.1)",
                        glassGradientStart: "rgba(255, 255, 255, 0.08)",
                        glassGradientEnd: "rgba(255, 255, 255, 0.02)",
                    },
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                    }
                }
            }
        }
    </script>
    <style>
        body {
            background-color: #070414;
            color: #E1E2E8;
            user-select: none;
            -webkit-user-select: none;
            -webkit-tap-highlight-color: transparent;
            touch-action: pan-x pan-y;
            overscroll-behavior: none;
            font-family: 'Inter', sans-serif;
            margin: 0;
            padding: 0;
        }

        .glass-card {
            background-color: rgba(17, 19, 24, 0.6);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 16px;
        }

        .glass-button {
            background: linear-gradient(135deg, rgba(255,255,255,0.08) 0%, rgba(255,255,255,0.02) 100%);
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.2s ease-in-out;
        }
        .glass-button:active {
            transform: scale(0.96);
            background: rgba(255,255,255,0.15);
        }

        .nav-btn.active {
            background-color: rgba(173, 198, 255, 0.2); /* primary with opacity */
            color: #ADC6FF;
        }
        .nav-btn {
            color: #C4C6D0;
            transition: all 0.3s ease;
        }

        .hide-scroll::-webkit-scrollbar { display: none; }
        .hide-scroll { -ms-overflow-style: none; scrollbar-width: none; }

        .touch-surface {
            background: radial-gradient(circle at 50% 50%, rgba(255,255,255,0.05) 0%, rgba(255,255,255,0.01) 100%);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 24px;
            box-shadow: inset 0 0 40px rgba(0,0,0,0.5);
            touch-action: none;
        }
    </style>
</head>
<body class="h-screen w-screen overflow-hidden relative">

    <!-- Blurred Background Shapes -->
    <div class="fixed inset-0 pointer-events-none z-0 overflow-hidden">
        <div class="absolute top-[-20%] left-[-10%] w-[60%] h-[50%] bg-[#B517FF] opacity-20 blur-[100px] rounded-full"></div>
        <div class="absolute bottom-[-10%] right-[-10%] w-[70%] h-[60%] bg-[#00F0FF] opacity-10 blur-[120px] rounded-full"></div>
    </div>

    <!-- Main Content -->
    <div class="relative z-10 h-full flex flex-col pb-[90px] overflow-y-auto hide-scroll" id="main-content">
        
        <!-- TOUCHPAD TAB -->
        <div id="tab-touchpad" class="tab-pane hidden flex-1 flex flex-col p-5">
            <div class="flex items-center mb-6 mt-4">
                <span class="material-icons-round text-primary text-3xl mr-3">touch_app</span>
                <h1 class="text-2xl font-bold text-white">Touchpad</h1>
            </div>
            
            <div class="flex-1 touch-surface relative mb-4" id="touchpad-area">
                <div class="absolute inset-0 flex items-center justify-center opacity-10 pointer-events-none">
                    <span class="material-icons-round text-8xl">mouse</span>
                </div>
            </div>

            <div class="flex gap-4 mb-4">
                <button id="btn-left-click" class="glass-button flex-1 py-4 rounded-2xl flex justify-center items-center">
                    <span class="material-icons-round text-onSurfaceVariant">mouse</span>
                    <span class="ml-2 font-medium">Sol Tık</span>
                </button>
                <button id="btn-right-click" class="glass-button flex-1 py-4 rounded-2xl flex justify-center items-center">
                    <span class="material-icons-round text-onSurfaceVariant">mouse</span>
                    <span class="ml-2 font-medium">Sağ Tık</span>
                </button>
            </div>
            
            <div class="flex gap-4">
                <input type="text" id="keyboard-input" placeholder="Metin yaz ve gönder..." class="glass-card flex-1 px-4 py-3 outline-none text-white placeholder-gray-500 focus:border-primary">
                <button id="btn-send-text" class="glass-button w-14 rounded-2xl flex justify-center items-center bg-primary/20 text-primary border-primary/30">
                    <span class="material-icons-round">send</span>
                </button>
            </div>
        </div>

        <!-- FILES TAB -->
        <div id="tab-files" class="tab-pane hidden p-5">
            <div class="flex items-center mb-6 mt-4">
                <span class="material-icons-round text-primary text-3xl mr-3">folder</span>
                <h1 class="text-2xl font-bold text-white" id="files-title">Dosyalar</h1>
            </div>
            
            <div class="glass-card p-2 mb-6 flex overflow-x-auto hide-scroll" id="dir-chips">
                <!-- Directory chips will be populated here -->
            </div>

            <div id="files-list" class="flex flex-col gap-3">
                <!-- Files will be populated here -->
                <div class="text-center text-onSurfaceVariant mt-10">Yükleniyor...</div>
            </div>
        </div>

        <!-- DECK TAB -->
        <div id="tab-deck" class="tab-pane hidden p-5">
            <div class="flex items-center justify-between mb-6 mt-4">
                <div class="flex items-center">
                    <span class="material-icons-round text-primary text-3xl mr-3">grid_view</span>
                    <h1 class="text-2xl font-bold text-white">Deck</h1>
                </div>
                <select id="profile-select" class="glass-card px-4 py-2 text-sm outline-none text-white border-outlineGlow appearance-none pr-8">
                    <option value="">Profil Seç</option>
                </select>
            </div>

            <div id="deck-grid" class="grid grid-cols-3 sm:grid-cols-4 gap-4">
                <!-- Deck buttons will be populated here -->
                <div class="col-span-3 text-center text-onSurfaceVariant mt-10">Profil yükleniyor...</div>
            </div>
        </div>

        <!-- SYSTEM TAB -->
        <div id="tab-system" class="tab-pane hidden p-5">
            <div class="flex items-center justify-between mb-6 mt-4">
                <div class="flex items-center">
                    <span class="material-icons-round text-primary text-3xl mr-3">monitor_heart</span>
                    <h1 class="text-2xl font-bold text-white">Sistem</h1>
                </div>
                <button id="btn-power" class="glass-button w-10 h-10 rounded-xl flex items-center justify-center border-red-500/30 bg-red-500/10 text-red-400">
                    <span class="material-icons-round">power_settings_new</span>
                </button>
            </div>

            <div class="glass-card p-4 flex items-center gap-4 mb-4">
                <div class="w-12 h-12 rounded-xl bg-blue-500/20 flex items-center justify-center border border-blue-500/30 text-blue-400">
                    <span class="material-icons-round text-2xl">computer</span>
                </div>
                <div>
                    <div id="sys-hostname" class="text-white font-bold text-lg">Yükleniyor...</div>
                    <div id="sys-os" class="text-onSurfaceVariant text-xs mt-1">...</div>
                </div>
            </div>

            <div class="grid grid-cols-2 gap-4 mb-4">
                <div class="glass-card p-5 flex flex-col items-center">
                    <div class="relative w-20 h-20 flex items-center justify-center mb-3">
                        <svg class="w-full h-full transform -rotate-90 absolute inset-0">
                            <circle cx="40" cy="40" r="36" stroke="rgba(255,255,255,0.05)" stroke-width="8" fill="none"></circle>
                            <circle id="cpu-circle" cx="40" cy="40" r="36" stroke="#ADC6FF" stroke-width="8" fill="none" stroke-dasharray="226" stroke-dashoffset="226" class="transition-all duration-500"></circle>
                        </svg>
                        <span id="cpu-val" class="font-bold text-lg text-white">0%</span>
                    </div>
                    <span class="text-onSurfaceVariant text-xs font-semibold tracking-wider">CPU</span>
                </div>
                
                <div class="glass-card p-5 flex flex-col items-center">
                    <div class="relative w-20 h-20 flex items-center justify-center mb-3">
                        <svg class="w-full h-full transform -rotate-90 absolute inset-0">
                            <circle cx="40" cy="40" r="36" stroke="rgba(255,255,255,0.05)" stroke-width="8" fill="none"></circle>
                            <circle id="ram-circle" cx="40" cy="40" r="36" stroke="#F1D4FF" stroke-width="8" fill="none" stroke-dasharray="226" stroke-dashoffset="226" class="transition-all duration-500"></circle>
                        </svg>
                        <span id="ram-val" class="font-bold text-lg text-white">0%</span>
                    </div>
                    <span class="text-onSurfaceVariant text-xs font-semibold tracking-wider">RAM</span>
                    <span id="ram-text" class="text-[10px] text-gray-500 mt-1">0/0 GB</span>
                </div>
            </div>

            <div class="glass-card p-4">
                <div class="flex justify-between items-center mb-2">
                    <span class="text-onSurfaceVariant text-sm flex items-center gap-2"><span class="material-icons-round text-sm">battery_full</span> Pil Durumu</span>
                    <span id="batt-val" class="text-white font-bold">-%</span>
                </div>
                <div class="w-full bg-white/5 h-3 rounded-full overflow-hidden">
                    <div id="batt-bar" class="h-full bg-green-400 rounded-full w-0 transition-all duration-500"></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bottom Navigation Bar -->
    <div class="fixed bottom-6 left-4 right-4 z-50 flex justify-center">
        <div class="glass-card rounded-[32px] p-2 flex items-center justify-between w-full max-w-[450px] shadow-2xl bg-[#111318]/80">
            <button class="nav-btn active w-1/5 flex flex-col items-center py-2 rounded-[24px]" onclick="switchTab('touchpad', this)">
                <span class="material-icons-round text-[26px]">touch_app</span>
                <span class="text-[9px] mt-1 font-semibold">Touchpad</span>
            </button>
            <button class="nav-btn w-1/5 flex flex-col items-center py-2 rounded-[24px]" onclick="switchTab('files', this)">
                <span class="material-icons-round text-[26px]">folder</span>
                <span class="text-[9px] mt-1 font-semibold">Files</span>
            </button>
            <button class="nav-btn w-1/5 flex flex-col items-center py-2 rounded-[24px]" onclick="switchTab('deck', this)">
                <span class="material-icons-round text-[26px]">grid_view</span>
                <span class="text-[9px] mt-1 font-semibold">Deck</span>
            </button>
            <button class="nav-btn w-1/5 flex flex-col items-center py-2 rounded-[24px]" onclick="switchTab('system', this)">
                <span class="material-icons-round text-[26px]">monitor_heart</span>
                <span class="text-[9px] mt-1 font-semibold">System</span>
            </button>
            <button class="nav-btn w-1/5 flex flex-col items-center py-2 rounded-[24px]" onclick="switchTab('download', this)">
                <span class="material-icons-round text-[26px]">get_app</span>
                <span class="text-[9px] mt-1 font-semibold">App</span>
            </button>
        </div>
    </div>

    <!-- APP DOWNLOAD TAB -->
    <div id="tab-download" class="tab-pane hidden p-5 relative z-20">
        <div class="flex items-center mb-6 mt-4">
            <span class="material-icons-round text-primary text-3xl mr-3">get_app</span>
            <h1 class="text-2xl font-bold text-white">Uygulamayı İndir</h1>
        </div>
        
        <div class="glass-card p-6 flex flex-col items-center text-center">
            <span class="material-icons-round text-6xl text-primary mb-4">smartphone</span>
            <h2 class="text-xl font-bold text-white mb-2">Phone Desk Mobil</h2>
            <p class="text-sm text-onSurfaceVariant mb-6">Daha iyi bir deneyim, daha yüksek performans ve tüm özellikler için mobil uygulamamızı indirin.</p>
            
            <a href="#" class="glass-button w-full py-4 rounded-xl flex items-center justify-center mb-4 bg-primary/10 border-primary/20">
                <span class="material-icons-round text-primary mr-3 text-2xl">android</span>
                <span class="text-white font-semibold">Android için İndir (APK)</span>
            </a>
            
            <a href="#" class="glass-button w-full py-4 rounded-xl flex items-center justify-center bg-white/5 border-white/10">
                <span class="material-icons-round text-onSurface mr-3 text-2xl">apple</span>
                <span class="text-white font-semibold">iOS için İndir</span>
            </a>
        </div>
    </div>

    <script>
        const pwd = new URLSearchParams(window.location.search).get('pwd') || '';
        
        // Navigation Logic
        function switchTab(tabId, btnElement) {
            document.querySelectorAll('.tab-pane').forEach(el => el.classList.add('hidden'));
            
            // tab element may be inside #main-content or direct child
            let tabContent = document.getElementById('tab-' + tabId);
            if(tabContent) {
                tabContent.classList.remove('hidden');
                // Move tab to top level inside #main-content if it's not
                if(tabContent.parentElement.id !== 'main-content') {
                     document.getElementById('main-content').appendChild(tabContent);
                }
            }
            
            document.querySelectorAll('.nav-btn').forEach(el => el.classList.remove('active'));
            if(btnElement) btnElement.classList.add('active');

            if(tabId === 'files' && !filesLoaded) loadDirectories();
            if(tabId === 'deck' && !deckLoaded) loadProfiles();
            if(tabId === 'system' && !sysInterval) startSystemMonitor();
            else if (tabId !== 'system' && sysInterval) {
                clearInterval(sysInterval);
                sysInterval = null;
            }
        }
        
        // Initial Tab
        document.getElementById('tab-touchpad').classList.remove('hidden');

        // ======== Touchpad Logic ========
        const touchArea = document.getElementById('touchpad-area');
        let lastX = 0, lastY = 0, isTouching = false;
        
        touchArea.addEventListener('touchstart', e => {
            if (e.touches.length === 1) {
                lastX = e.touches[0].clientX;
                lastY = e.touches[0].clientY;
                isTouching = true;
            }
        }, {passive: false});

        touchArea.addEventListener('touchmove', e => {
            if (!isTouching || e.touches.length !== 1) return;
            e.preventDefault();
            const x = e.touches[0].clientX;
            const y = e.touches[0].clientY;
            const dx = Math.round((x - lastX) * 1.5);
            const dy = Math.round((y - lastY) * 1.5);
            lastX = x;
            lastY = y;
            fetch('/mouse', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ pwd: pwd, action: 'relative', dx: dx, dy: dy })
            });
        }, {passive: false});

        touchArea.addEventListener('touchend', e => { isTouching = false; });
        touchArea.addEventListener('click', () => sendClick('left'));

        document.getElementById('btn-left-click').addEventListener('click', () => sendClick('left'));
        document.getElementById('btn-right-click').addEventListener('click', () => sendClick('right'));
        
        function sendClick(btn) {
            fetch('/mouse', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ pwd: pwd, action: btn })
            });
        }

        document.getElementById('btn-send-text').addEventListener('click', () => {
            const input = document.getElementById('keyboard-input');
            if(input.value) {
                fetch('/keyboard', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({ pwd: pwd, type: 'text', text: input.value })
                });
                input.value = '';
            }
        });

        // ======== Files Logic ========
        let filesLoaded = false;
        let currentPath = [];
        
        async function loadDirectories() {
            try {
                const res = await fetch(`/directories?pwd=${pwd}`);
                const data = await res.json();
                const chips = document.getElementById('dir-chips');
                chips.innerHTML = '';
                if(data && data.length > 0) {
                    currentPath = [data[0].name];
                    data.forEach(d => {
                        const btn = document.createElement('button');
                        btn.className = `px-4 py-2 rounded-full text-sm font-medium mr-2 whitespace-nowrap transition-all ${d.name === currentPath[0] ? 'bg-primary text-surface' : 'glass-button text-onSurface'}`;
                        btn.innerText = d.name;
                        btn.onclick = () => {
                            currentPath = [d.name];
                            loadDirectories(); // to refresh active state
                        };
                        chips.appendChild(btn);
                    });
                    loadFiles();
                }
                filesLoaded = true;
            } catch(e) { console.error(e); }
        }

        async function loadFiles() {
            const pathStr = encodeURIComponent(currentPath.join('/'));
            document.getElementById('files-title').innerText = currentPath.length > 1 ? currentPath[currentPath.length-1] : 'Dosyalar';
            document.getElementById('files-list').innerHTML = '<div class="text-center text-onSurfaceVariant mt-10"><span class="material-icons-round animate-spin">refresh</span></div>';
            
            try {
                const res = await fetch(`/files?dir=${pathStr}&pwd=${pwd}`);
                const data = await res.json();
                
                let html = '';
                // Up button
                if(currentPath.length > 1) {
                    html += `
                    <div class="glass-button p-3 rounded-2xl flex items-center" onclick="goUp()">
                        <div class="w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center mr-4">
                            <span class="material-icons-round text-onSurfaceVariant">arrow_upward</span>
                        </div>
                        <div class="font-medium">Bir Üst Klasör</div>
                    </div>`;
                }

                data.forEach(f => {
                    const isDir = f.isDir;
                    const icon = isDir ? 'folder' : 'insert_drive_file';
                    const color = isDir ? 'text-primary' : 'text-onSurfaceVariant';
                    const bg = isDir ? 'bg-primary/10' : 'bg-white/5';
                    
                    let sizeStr = f.size + ' B';
                    if(f.size > 1024*1024) sizeStr = (f.size/(1024*1024)).toFixed(1) + ' MB';
                    else if(f.size > 1024) sizeStr = (f.size/1024).toFixed(1) + ' KB';
                    
                    const action = isDir ? `goDown('${f.name}')` : `downloadFile('${f.name}')`;

                    html += `
                    <div class="glass-button p-3 rounded-2xl flex items-center justify-between" onclick="${action}">
                        <div class="flex items-center overflow-hidden">
                            <div class="w-10 h-10 min-w-[40px] rounded-xl ${bg} flex items-center justify-center mr-4">
                                <span class="material-icons-round ${color}">${icon}</span>
                            </div>
                            <div class="overflow-hidden">
                                <div class="font-medium text-white truncate text-sm">${f.name}</div>
                                <div class="text-xs text-onSurfaceVariant mt-0.5">${isDir ? 'Klasör' : sizeStr}</div>
                            </div>
                        </div>
                        ${!isDir ? '<span class="material-icons-round text-primary ml-2">download</span>' : '<span class="material-icons-round text-onSurfaceVariant ml-2">chevron_right</span>'}
                    </div>`;
                });
                document.getElementById('files-list').innerHTML = html;
            } catch(e) { console.error(e); }
        }

        function goDown(folder) { currentPath.push(folder); loadFiles(); }
        function goUp() { currentPath.pop(); loadFiles(); }
        function downloadFile(name) {
            const p = encodeURIComponent(currentPath.join('/'));
            const n = encodeURIComponent(name);
            window.location.href = `/download/${n}?dir=${p}&pwd=${pwd}`;
        }

        // ======== Deck Logic ========
        let deckLoaded = false;
        async function loadProfiles() {
            try {
                const res = await fetch(`/deck/profiles?pwd=${pwd}`);
                const data = await res.json();
                const sel = document.getElementById('profile-select');
                sel.innerHTML = '';
                
                let activeId = data.activeProfileId;
                if(data.profiles) {
                    data.profiles.forEach(p => {
                        const opt = document.createElement('option');
                        opt.value = p.id;
                        opt.innerText = p.name;
                        opt.className = 'text-black';
                        if(p.id === activeId) opt.selected = true;
                        sel.appendChild(opt);
                    });
                }
                sel.onchange = (e) => loadDeckButtons(e.target.value);
                if(activeId) loadDeckButtons(activeId);
                deckLoaded = true;
            } catch(e) { console.error(e); }
        }

        async function loadDeckButtons(profileId) {
            document.getElementById('deck-grid').innerHTML = '<div class="col-span-3 text-center text-onSurfaceVariant"><span class="material-icons-round animate-spin">refresh</span></div>';
            try {
                const res = await fetch(`/deck/buttons?profileId=${profileId}&pwd=${pwd}`);
                const data = await res.json();
                let html = '';
                data.forEach(btn => {
                    const label = btn.label || '';
                    let icon = 'bolt';
                    const l = label.toLowerCase();
                    if(l.includes('ses')) icon = 'volume_up';
                    if(l.includes('kapat') || l.includes('power')) icon = 'power_settings_new';
                    if(l.includes('klasör') || l.includes('dosya')) icon = 'folder';
                    if(l.includes('ekran')) icon = 'screenshot';
                    if(l.includes('oynat')) icon = 'play_arrow';
                    if(l.includes('tarayıcı')) icon = 'public';

                    html += `
                    <button class="glass-button aspect-square rounded-2xl flex flex-col items-center justify-center p-2" onclick="triggerBtn('${profileId}', '${btn.id}')">
                        <span class="material-icons-round text-primary text-3xl mb-2">${icon}</span>
                        <span class="text-[10px] font-medium text-center text-onSurface leading-tight line-clamp-2">${label}</span>
                    </button>`;
                });
                html += `
                    <div class="glass-card aspect-square rounded-2xl flex flex-col items-center justify-center p-2 border-dashed border-white/20 opacity-50">
                        <span class="material-icons-round text-onSurfaceVariant text-2xl mb-1">add</span>
                        <span class="text-[10px] font-medium text-onSurfaceVariant">Ekle (PC)</span>
                    </div>`;
                document.getElementById('deck-grid').innerHTML = html;
            } catch(e) { console.error(e); }
        }

        function triggerBtn(pId, bId) {
            fetch('/deck/execute', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ pwd: pwd, profileId: pId, buttonId: bId })
            });
        }

        // ======== System Logic ========
        let sysInterval = null;
        function startSystemMonitor() {
            fetchSystemInfo();
            sysInterval = setInterval(fetchSystemInfo, 2000);
        }

        async function fetchSystemInfo() {
            try {
                const res = await fetch(`/system/info?pwd=${pwd}`);
                const data = await res.json();
                
                if(data.os) {
                    document.getElementById('sys-hostname').innerText = data.os.hostname || 'PC';
                    document.getElementById('sys-os').innerText = data.os.name || 'Windows';
                }
                
                if(data.cpu && data.cpu.usage != null) {
                    const usage = data.cpu.usage;
                    document.getElementById('cpu-val').innerText = usage.toFixed(0) + '%';
                    const dashoffset = 226 - (226 * usage / 100);
                    document.getElementById('cpu-circle').style.strokeDashoffset = dashoffset;
                }
                
                if(data.ram && data.ram.totalGB) {
                    const pct = data.ram.usagePercent;
                    document.getElementById('ram-val').innerText = pct.toFixed(0) + '%';
                    const dashoffset = 226 - (226 * pct / 100);
                    document.getElementById('ram-circle').style.strokeDashoffset = dashoffset;
                    document.getElementById('ram-text').innerText = data.ram.usedGB.toFixed(1) + '/' + data.ram.totalGB.toFixed(1) + ' GB';
                }
                
                if(data.battery && data.battery.level != null) {
                    const level = data.battery.level;
                    document.getElementById('batt-val').innerText = level.toFixed(0) + '%';
                    document.getElementById('batt-bar').style.width = level + '%';
                    if(level < 20) document.getElementById('batt-bar').className = 'h-full bg-red-500 rounded-full transition-all duration-500';
                    else document.getElementById('batt-bar').className = 'h-full bg-green-400 rounded-full transition-all duration-500';
                }
            } catch(e) {}
        }
        
        document.getElementById('btn-power').addEventListener('click', () => {
            if(confirm('Bilgisayarı Kapatmak İstediğinize Emin Misiniz?')) {
                fetch('/system/power', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({ pwd: pwd, action: 'shutdown' })
                });
            }
        });
    </script>
</body>
</html>''';
}
