import 'dart:io';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/foundation.dart';

typedef MouseEventC = Void Function(Int32 dwFlags, Int32 dx, Int32 dy, Int32 dwData, Int32 dwExtraInfo);
typedef MouseEventDart = void Function(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);

const int mouseEventfMove = 0x0001;
const int mouseEventfLeftdown = 0x0002;
const int mouseEventfLeftup = 0x0004;
const int mouseEventfRightdown = 0x0008;
const int mouseEventfRightup = 0x0010;
const int mouseEventfWheel = 0x0800;

/// Simulates keyboard input and system actions on Windows via PowerShell
class KeySimulator {
  /// Execute an action based on type and data
  Future<bool> execute(String actionType, String actionData) async {
    try {
      switch (actionType) {
        case 'hotkey':
          return await sendHotkey(actionData);
        case 'launch':
          return await launchApp(actionData);
        case 'media':
          return await mediaControl(actionData);
        case 'volume':
          return await volumeControl(actionData);
        case 'command':
          return await runCommand(actionData);
        case 'folder':
          return await openFolder(actionData);
        case 'text':
          return await typeText(actionData);
        case 'url':
          return await openUrl(actionData);
        case 'movie_mode':
          return await launchMovieMode(actionData);
        default:
          debugPrint('Unknown action type: $actionType');
          return false;
      }
    } catch (e) {
      debugPrint('KeySimulator error: $e');
      return false;
    }
  }

  /// Simulate mouse movement or clicks using Dart FFI (zero latency)
  void simulateMouse(String action, {int? dx, int? dy}) {
    if (!Platform.isWindows) return;
    
    try {
      final user32 = DynamicLibrary.open('user32.dll');
      final MouseEventDart mouseEvent = user32.lookupFunction<MouseEventC, MouseEventDart>('mouse_event');
      
      switch (action) {
        case 'move':
          if (dx != null && dy != null) {
            mouseEvent(mouseEventfMove, dx, dy, 0, 0);
          }
          break;
        case 'left_click':
          mouseEvent(mouseEventfLeftdown, 0, 0, 0, 0);
          mouseEvent(mouseEventfLeftup, 0, 0, 0, 0);
          break;
        case 'left_down':
          mouseEvent(mouseEventfLeftdown, 0, 0, 0, 0);
          break;
        case 'left_up':
          mouseEvent(mouseEventfLeftup, 0, 0, 0, 0);
          break;
        case 'right_click':
          mouseEvent(mouseEventfRightdown, 0, 0, 0, 0);
          mouseEvent(mouseEventfRightup, 0, 0, 0, 0);
          break;
        case 'scroll':
          if (dy != null) {
            // dy is inverted for scrolling. positive dy means scrolling down in JS, but WHEEL expects negative for down.
            mouseEvent(mouseEventfWheel, 0, 0, -dy, 0);
          }
          break;
      }
    } catch (e) {
      debugPrint('Mouse FFI error: $e');
    }
  }

  /// Simulate absolute mouse movement and optional click
  void simulateMouseAbsolute(double xPct, double yPct, {bool click = false}) {
    if (!Platform.isWindows) return;
    try {
      final user32 = DynamicLibrary.open('user32.dll');
      final MouseEventDart mouseEvent = user32.lookupFunction<MouseEventC, MouseEventDart>('mouse_event');
      
      // MOUSEEVENTF_ABSOLUTE is 0x8000
      // Coordinates must be mapped to 0-65535
      int absX = (xPct * 65535).round();
      int absY = (yPct * 65535).round();
      
      int flags = mouseEventfMove | 0x8000;
      mouseEvent(flags, absX, absY, 0, 0);
      
      if (click) {
        mouseEvent(mouseEventfLeftdown | 0x8000, absX, absY, 0, 0);
        mouseEvent(mouseEventfLeftup | 0x8000, absX, absY, 0, 0);
      }
    } catch (e) {
      debugPrint('Mouse FFI absolute error: $e');
    }
  }


  /// Send a hotkey combination (e.g., "ctrl+shift+s", "alt+tab", "win+l")
  Future<bool> sendHotkey(String combo) async {
    final parts = combo.toLowerCase().split('+').map((s) => s.trim()).toList();
    
    // Build the PowerShell script using Windows API via Add-Type
    final keyScript = _buildHotkeyScript(parts);
    if (keyScript == null) return false;

    final result = await Process.run('powershell', [
      '-NoProfile', '-NonInteractive', '-Command', keyScript,
    ]);
    
    if (result.exitCode != 0) {
      debugPrint('Hotkey error: ${result.stderr}');
      return false;
    }
    return true;
  }

  String? _buildHotkeyScript(List<String> parts) {
    // Map key names to virtual key codes
    final List<String> keysDown = [];
    final List<String> keysUp = [];

    for (final part in parts) {
      final vk = _getVirtualKeyCode(part);
      if (vk == null) {
        debugPrint('Unknown key: $part');
        return null;
      }
      keysDown.add('[VK]::keybd_event($vk, 0, 0, [UIntPtr]::Zero)');
      keysUp.insert(0, '[VK]::keybd_event($vk, 0, 2, [UIntPtr]::Zero)');
    }

    return '''
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class VK {
  [DllImport("user32.dll")]
  public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, UIntPtr dwExtraInfo);
}
"@
${keysDown.join('\n')}
Start-Sleep -Milliseconds 50
${keysUp.join('\n')}
''';
  }

  String? _getVirtualKeyCode(String key) {
    const keyMap = <String, String>{
      // Modifiers
      'ctrl': '0x11',
      'control': '0x11',
      'alt': '0x12',
      'shift': '0x10',
      'win': '0x5B',
      'windows': '0x5B',
      'tab': '0x09',
      'enter': '0x0D',
      'return': '0x0D',
      'escape': '0x1B',
      'esc': '0x1B',
      'space': '0x20',
      'backspace': '0x08',
      'delete': '0x2E',
      'del': '0x2E',
      'insert': '0x2D',
      'home': '0x24',
      'end': '0x23',
      'pageup': '0x21',
      'pagedown': '0x22',
      'up': '0x26',
      'down': '0x28',
      'left': '0x25',
      'right': '0x27',
      'printscreen': '0x2C',
      'prtsc': '0x2C',
      
      // Function keys
      'f1': '0x70', 'f2': '0x71', 'f3': '0x72', 'f4': '0x73',
      'f5': '0x74', 'f6': '0x75', 'f7': '0x76', 'f8': '0x77',
      'f9': '0x78', 'f10': '0x79', 'f11': '0x7A', 'f12': '0x7B',
      
      // Letters
      'a': '0x41', 'b': '0x42', 'c': '0x43', 'd': '0x44',
      'e': '0x45', 'f': '0x46', 'g': '0x47', 'h': '0x48',
      'i': '0x49', 'j': '0x4A', 'k': '0x4B', 'l': '0x4C',
      'm': '0x4D', 'n': '0x4E', 'o': '0x4F', 'p': '0x50',
      'q': '0x51', 'r': '0x52', 's': '0x53', 't': '0x54',
      'u': '0x55', 'v': '0x56', 'w': '0x57', 'x': '0x58',
      'y': '0x59', 'z': '0x5A',
      
      // Numbers
      '0': '0x30', '1': '0x31', '2': '0x32', '3': '0x33',
      '4': '0x34', '5': '0x35', '6': '0x36', '7': '0x37',
      '8': '0x38', '9': '0x39',
      
      // Special
      'plus': '0xBB', 'minus': '0xBD', 'equals': '0xBB',
      'comma': '0xBC', 'period': '0xBE', 'dot': '0xBE',
      'semicolon': '0xBA', 'slash': '0xBF',
      'backslash': '0xDC', 'quote': '0xDE',
      'bracket_left': '0xDB', 'bracket_right': '0xDD',
      'grave': '0xC0', 'tilde': '0xC0',
    };

    return keyMap[key];
  }

  /// Launch an application or file
  Future<bool> launchApp(String path) async {
    try {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', path]);
      }
      return true;
    } catch (e) {
      debugPrint('Launch error: $e');
      return false;
    }
  }

  /// Media control (play_pause, next, prev, stop)
  Future<bool> mediaControl(String action) async {
    String vk;
    switch (action) {
      case 'play_pause':
        vk = '0xB3'; // VK_MEDIA_PLAY_PAUSE
        break;
      case 'next':
        vk = '0xB0'; // VK_MEDIA_NEXT_TRACK
        break;
      case 'prev':
        vk = '0xB1'; // VK_MEDIA_PREV_TRACK
        break;
      case 'stop':
        vk = '0xB2'; // VK_MEDIA_STOP
        break;
      default:
        return false;
    }

    final script = '''
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class MediaKey {
  [DllImport("user32.dll")]
  public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, UIntPtr dwExtraInfo);
}
"@
[MediaKey]::keybd_event($vk, 0, 0, [UIntPtr]::Zero)
Start-Sleep -Milliseconds 50
[MediaKey]::keybd_event($vk, 0, 2, [UIntPtr]::Zero)
''';

    final result = await Process.run('powershell', [
      '-NoProfile', '-NonInteractive', '-Command', script,
    ]);
    return result.exitCode == 0;
  }

  /// Volume control (up, down, mute)
  Future<bool> volumeControl(String action) async {
    String vk;
    switch (action) {
      case 'up':
        vk = '0xAF'; // VK_VOLUME_UP
        break;
      case 'down':
        vk = '0xAE'; // VK_VOLUME_DOWN
        break;
      case 'mute':
        vk = '0xAD'; // VK_VOLUME_MUTE
        break;
      default:
        return false;
    }

    final script = '''
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class VolKey {
  [DllImport("user32.dll")]
  public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, UIntPtr dwExtraInfo);
}
"@
[VolKey]::keybd_event($vk, 0, 0, [UIntPtr]::Zero)
Start-Sleep -Milliseconds 50
[VolKey]::keybd_event($vk, 0, 2, [UIntPtr]::Zero)
''';

    final result = await Process.run('powershell', [
      '-NoProfile', '-NonInteractive', '-Command', script,
    ]);
    return result.exitCode == 0;
  }

  /// Run a command (with basic safety checks)
  Future<bool> runCommand(String command) async {
    // Basic safety: block dangerous commands
    final dangerous = ['format', 'del /f', 'rmdir', 'rd /s', 'reg delete'];
    for (final d in dangerous) {
      if (command.toLowerCase().contains(d)) {
        debugPrint('Blocked dangerous command: $command');
        return false;
      }
    }

    try {
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command', command,
      ]);
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Command error: $e');
      return false;
    }
  }

  /// Open a folder in Explorer
  Future<bool> openFolder(String path) async {
    try {
      await Process.run('explorer', [path]);
      return true;
    } catch (e) {
      debugPrint('Open folder error: $e');
      return false;
    }
  }

  /// Type text using clipboard (faster and more reliable than SendKeys)
  Future<bool> typeText(String text) async {
    final escapedText = text.replaceAll("'", "''").replaceAll('"', '`"');
    final script = '''
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Clipboard]::SetText("$escapedText")
Start-Sleep -Milliseconds 100
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class PasteKey {
  [DllImport("user32.dll")]
  public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, UIntPtr dwExtraInfo);
}
"@
[PasteKey]::keybd_event(0x11, 0, 0, [UIntPtr]::Zero)
[PasteKey]::keybd_event(0x56, 0, 0, [UIntPtr]::Zero)
Start-Sleep -Milliseconds 50
[PasteKey]::keybd_event(0x56, 0, 2, [UIntPtr]::Zero)
[PasteKey]::keybd_event(0x11, 0, 2, [UIntPtr]::Zero)
''';

    final result = await Process.run('powershell', [
      '-NoProfile', '-NonInteractive', '-Command', script,
    ]);
    return result.exitCode == 0;
  }

  /// Open a URL in the default browser
  Future<bool> openUrl(String url) async {
    try {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      await Process.run('cmd', ['/c', 'start', '', url]);
      return true;
    } catch (e) {
      debugPrint('Open URL error: $e');
      return false;
    }
  }

  /// Launch Netflix and dim the other screen using a borderless black PowerShell form
  Future<bool> launchMovieMode(String actionData) async {
    int targetScreenIndex = 0;
    String targetDeviceName = '';
    int? profileIndex;
    String? pin;

    try {
      if (actionData.startsWith('{')) {
        final data = jsonDecode(actionData);
        if (data['screen'] != null) {
           if (int.tryParse(data['screen'].toString()) != null) {
              targetScreenIndex = int.parse(data['screen'].toString());
           } else {
              targetDeviceName = data['screen'].toString();
           }
        }
        profileIndex = int.tryParse(data['profileIndex']?.toString() ?? '');
        pin = data['pin']?.toString();
      } else {
        if (int.tryParse(actionData) != null) {
          targetScreenIndex = int.parse(actionData);
        } else {
          targetDeviceName = actionData;
        }
      }
    } catch (_) {}

    // Launch Netflix directly via its Windows App AUMID to bypass broken URI schemes
    try {
      await Process.run('explorer.exe', ['shell:AppsFolder\\4DF9E0F8.Netflix_mcm4njqhnhss8!Netflix.App']);
    } catch (e) {
      debugPrint('Netflix launch error: $e');
    }

    // PowerShell script to find other screens and black them out
    final script = '''
Add-Type -AssemblyName System.Windows.Forms
\$screens = [System.Windows.Forms.Screen]::AllScreens
if (\$screens.Length -le 1) { exit 0 }
\$targetIdx = $targetScreenIndex
if ("$targetDeviceName" -ne "") {
    for (\$i = 0; \$i -lt \$screens.Length; \$i++) {
        if (\$screens[\$i].DeviceName -eq "$targetDeviceName") {
            \$targetIdx = \$i
            break
        }
    }
}
if (\$targetIdx -lt 0 -or \$targetIdx -ge \$screens.Length) { \$targetIdx = 0 }

\$forms = @()
for (\$i = 0; \$i -lt \$screens.Length; \$i++) {
    if (\$i -ne \$targetIdx) {
        \$form = New-Object System.Windows.Forms.Form
        \$form.BackColor = [System.Drawing.Color]::Black
        \$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
        \$form.Bounds = \$screens[\$i].Bounds
        \$form.TopMost = \$true
        \$form.ShowInTaskbar = \$false
        \$form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
        \$form.add_Click({ [System.Windows.Forms.Application]::Exit() })
        \$forms += \$form
    }
}
foreach (\$f in \$forms) { \$f.Show() }
[System.Windows.Forms.Application]::Run()
''';

    // Start asynchronously so we don't block
    Process.start('powershell', ['-WindowStyle', 'Hidden', '-Command', script]).catchError((e) {
       debugPrint('Black screen script error: $e');
       throw e;
    });

    // Move Netflix window to target screen asynchronously
    final moveScript = '''
Add-Type -AssemblyName System.Windows.Forms
\$screens = [System.Windows.Forms.Screen]::AllScreens
if (\$screens.Length -le 1) { exit 0 }
\$targetIdx = $targetScreenIndex
if ("$targetDeviceName" -ne "") {
    for (\$i = 0; \$i -lt \$screens.Length; \$i++) {
        if (\$screens[\$i].DeviceName -eq "$targetDeviceName") {
            \$targetIdx = \$i
            break
        }
    }
}
if (\$targetIdx -lt 0 -or \$targetIdx -ge \$screens.Length) { \$targetIdx = 0 }
\$targetScreen = \$screens[\$targetIdx]

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public class Win32Move {
    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder strText, int maxCount);
    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    public static IntPtr FindNetflixWindow() {
        IntPtr found = IntPtr.Zero;
        EnumWindows((hWnd, lParam) => {
            if (!IsWindowVisible(hWnd)) return true;
            StringBuilder sb = new StringBuilder(256);
            GetWindowText(hWnd, sb, sb.Capacity);
            if (sb.ToString().Contains("Netflix") || sb.ToString().Contains("netflix")) {
                found = hWnd;
                return false; // Stop
            }
            return true;
        }, IntPtr.Zero);
        return found;
    }
}
"@

# Wait up to 5 seconds for Netflix window to appear
\$hwnd = [IntPtr]::Zero
for (\$i = 0; \$i -lt 15; \$i++) {
    Start-Sleep -Milliseconds 500
    \$hwnd = [Win32Move]::FindNetflixWindow()
    if (\$hwnd -ne [IntPtr]::Zero) { break }
}

if (\$hwnd -ne [IntPtr]::Zero) {
    [Win32Move]::ShowWindow(\$hwnd, 1)
    [Win32Move]::MoveWindow(\$hwnd, \$targetScreen.Bounds.X, \$targetScreen.Bounds.Y, 800, 600, \$true)
    [Win32Move]::ShowWindow(\$hwnd, 3)
}
''';
    Process.start('powershell', ['-WindowStyle', 'Hidden', '-Command', moveScript]);


    // Profile Auto-Login via Keyboard
    if (profileIndex != null) {
      Future(() async {
        // Wait 6 seconds for Netflix to fully load and focus the first profile
        await Future.delayed(const Duration(seconds: 6));
        
        final List<String> scriptLines = [];
        scriptLines.add('''
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class NetflixKB {
  [DllImport("user32.dll")]
  public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, UIntPtr dwExtraInfo);
}
"@
''');

        // VK_RIGHT = 0x27, VK_RETURN = 0x0D
        for (int i = 0; i < profileIndex!; i++) {
          scriptLines.add('[NetflixKB]::keybd_event(0x27, 0, 0, [UIntPtr]::Zero)');
          scriptLines.add('Start-Sleep -Milliseconds 50');
          scriptLines.add('[NetflixKB]::keybd_event(0x27, 0, 2, [UIntPtr]::Zero)');
          scriptLines.add('Start-Sleep -Milliseconds 300');
        }

        // Press Enter
        scriptLines.add('[NetflixKB]::keybd_event(0x0D, 0, 0, [UIntPtr]::Zero)');
        scriptLines.add('Start-Sleep -Milliseconds 50');
        scriptLines.add('[NetflixKB]::keybd_event(0x0D, 0, 2, [UIntPtr]::Zero)');

        if (pin != null && pin.isNotEmpty) {
          scriptLines.add('Start-Sleep -Milliseconds 1500');
          // PIN characters (0-9 are 0x30 to 0x39)
          for (int i = 0; i < pin.length; i++) {
            final char = pin[i];
            final val = int.tryParse(char);
            if (val != null) {
              final vk = 0x30 + val;
              scriptLines.add('[NetflixKB]::keybd_event($vk, 0, 0, [UIntPtr]::Zero)');
              scriptLines.add('Start-Sleep -Milliseconds 50');
              scriptLines.add('[NetflixKB]::keybd_event($vk, 0, 2, [UIntPtr]::Zero)');
              scriptLines.add('Start-Sleep -Milliseconds 100');
            }
          }
        }

        try {
          await Process.run('powershell', ['-NoProfile', '-NonInteractive', '-Command', scriptLines.join('\n')]);
        } catch (e) {
          debugPrint('Netflix macro error: $e');
        }
      });
    }

    return true;
  }

  /// Type a single character via clipboard paste
  Future<bool> typeChar(String char) async {
    if (char.isEmpty) return false;
    return await typeText(char);
  }

  /// Send a special key (enter, tab, esc, backspace, arrow keys, etc.)
  Future<bool> sendSpecialKey(String key) async {
    final vk = _getVirtualKeyCode(key.toLowerCase());
    if (vk == null) return false;

    final script = '''
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class SpecKey {
  [DllImport("user32.dll")]
  public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, UIntPtr dwExtraInfo);
}
"@
[SpecKey]::keybd_event($vk, 0, 0, [UIntPtr]::Zero)
Start-Sleep -Milliseconds 50
[SpecKey]::keybd_event($vk, 0, 2, [UIntPtr]::Zero)
''';

    final result = await Process.run('powershell', [
      '-NoProfile', '-NonInteractive', '-Command', script,
    ]);
    return result.exitCode == 0;
  }

  /// Send a key combination from keyboard input (e.g. ctrl+c, ctrl+v)
  Future<bool> sendKeyCombination(String combo) async {
    return await sendHotkey(combo);
  }
}
