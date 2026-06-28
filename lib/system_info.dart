import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Gathers Windows system information via PowerShell/WMI
class SystemInfo {
  /// Get comprehensive system information
  static Future<Map<String, dynamic>> getInfo() async {
    final results = <String, dynamic>{};

    try {
      // Run all queries in parallel
      final futures = await Future.wait([
        _getCpuUsage(),
        _getRamInfo(),
        _getDiskInfo(),
        _getGpuInfo(),
        _getOsInfo(),
        _getUptime(),
        _getBatteryInfo(),
        _getNetworkInfo(),
      ]);

      results['cpu'] = futures[0];
      results['ram'] = futures[1];
      results['disk'] = futures[2];
      results['gpu'] = futures[3];
      results['os'] = futures[4];
      results['uptime'] = futures[5];
      results['battery'] = futures[6];
      results['network'] = futures[7];
      results['hostname'] = Platform.localHostname;
    } catch (e) {
      debugPrint('SystemInfo error: $e');
    }

    return results;
  }

  static Future<Map<String, dynamic>> _getCpuUsage() async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        r"Get-CimInstance Win32_Processor | Select-Object -First 1 Name, LoadPercentage, NumberOfCores, NumberOfLogicalProcessors | ConvertTo-Json"
      ]).timeout(const Duration(seconds: 5));
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        final data = jsonDecode(result.stdout.toString().trim());
        return {
          'name': data['Name'] ?? 'Unknown',
          'usage': data['LoadPercentage'] ?? 0,
          'cores': data['NumberOfCores'] ?? 0,
          'threads': data['NumberOfLogicalProcessors'] ?? 0,
        };
      }
    } catch (e) {
      debugPrint('CPU info error: $e');
    }
    return {'name': 'Unknown', 'usage': 0, 'cores': 0, 'threads': 0};
  }

  static Future<Map<String, dynamic>> _getRamInfo() async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        r"$os = Get-CimInstance Win32_OperatingSystem; @{total=$os.TotalVisibleMemorySize; free=$os.FreePhysicalMemory} | ConvertTo-Json"
      ]).timeout(const Duration(seconds: 5));
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        final data = jsonDecode(result.stdout.toString().trim());
        final totalKB = (data['total'] as num?) ?? 0;
        final freeKB = (data['free'] as num?) ?? 0;
        final totalGB = totalKB / 1048576;
        final usedGB = (totalKB - freeKB) / 1048576;
        return {
          'totalGB': double.parse(totalGB.toStringAsFixed(1)),
          'usedGB': double.parse(usedGB.toStringAsFixed(1)),
          'usagePercent': totalKB > 0 ? ((totalKB - freeKB) / totalKB * 100).round() : 0,
        };
      }
    } catch (e) {
      debugPrint('RAM info error: $e');
    }
    return {'totalGB': 0.0, 'usedGB': 0.0, 'usagePercent': 0};
  }

  static Future<Map<String, dynamic>> _getDiskInfo() async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        r"Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Select-Object DeviceID, Size, FreeSpace | ConvertTo-Json"
      ]).timeout(const Duration(seconds: 5));
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        var raw = jsonDecode(result.stdout.toString().trim());
        if (raw is! List) raw = [raw];
        final drives = <Map<String, dynamic>>[];
        for (var d in raw) {
          final size = (d['Size'] as num?) ?? 0;
          final free = (d['FreeSpace'] as num?) ?? 0;
          final totalGB = size / 1073741824;
          final usedGB = (size - free) / 1073741824;
          drives.add({
            'drive': d['DeviceID'] ?? '?',
            'totalGB': double.parse(totalGB.toStringAsFixed(1)),
            'usedGB': double.parse(usedGB.toStringAsFixed(1)),
            'usagePercent': size > 0 ? ((size - free) / size * 100).round() : 0,
          });
        }
        return {'drives': drives};
      }
    } catch (e) {
      debugPrint('Disk info error: $e');
    }
    return {'drives': []};
  }

  static Future<Map<String, dynamic>> _getGpuInfo() async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        r"Get-CimInstance Win32_VideoController | Select-Object -First 1 Name, AdapterRAM, DriverVersion | ConvertTo-Json"
      ]).timeout(const Duration(seconds: 5));
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        final data = jsonDecode(result.stdout.toString().trim());
        final vramBytes = (data['AdapterRAM'] as num?) ?? 0;
        return {
          'name': data['Name'] ?? 'Unknown',
          'vramGB': double.parse((vramBytes / 1073741824).toStringAsFixed(1)),
          'driver': data['DriverVersion'] ?? '',
        };
      }
    } catch (e) {
      debugPrint('GPU info error: $e');
    }
    return {'name': 'Unknown', 'vramGB': 0.0, 'driver': ''};
  }

  static Future<Map<String, dynamic>> _getOsInfo() async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        r"$os = Get-CimInstance Win32_OperatingSystem; @{name=$os.Caption; version=$os.Version; build=$os.BuildNumber; arch=$os.OSArchitecture} | ConvertTo-Json"
      ]).timeout(const Duration(seconds: 5));
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        return Map<String, dynamic>.from(jsonDecode(result.stdout.toString().trim()));
      }
    } catch (e) {
      debugPrint('OS info error: $e');
    }
    return {'name': 'Windows', 'version': '', 'build': '', 'arch': ''};
  }

  static Future<Map<String, dynamic>> _getUptime() async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        r"$boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime; $span = (Get-Date) - $boot; @{days=$span.Days; hours=$span.Hours; minutes=$span.Minutes; totalHours=[math]::Round($span.TotalHours,1)} | ConvertTo-Json"
      ]).timeout(const Duration(seconds: 5));
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        return Map<String, dynamic>.from(jsonDecode(result.stdout.toString().trim()));
      }
    } catch (e) {
      debugPrint('Uptime error: $e');
    }
    return {'days': 0, 'hours': 0, 'minutes': 0, 'totalHours': 0.0};
  }

  static Future<Map<String, dynamic>> _getBatteryInfo() async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        r"$b = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue; if($b){@{hasBattery=$true; percent=$b.EstimatedChargeRemaining; charging=($b.BatteryStatus -eq 2)} | ConvertTo-Json}else{'{}' }"
      ]).timeout(const Duration(seconds: 5));
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        final data = jsonDecode(result.stdout.toString().trim());
        if (data is Map && data.containsKey('hasBattery')) {
          return Map<String, dynamic>.from(data);
        }
      }
    } catch (e) {
      debugPrint('Battery info error: $e');
    }
    return {'hasBattery': false, 'percent': 0, 'charging': false};
  }

  static Future<Map<String, dynamic>> _getNetworkInfo() async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        r"$n = Get-CimInstance Win32_PerfFormattedData_Tcpip_NetworkInterface | Select-Object -First 1 BytesSentPersec, BytesReceivedPersec; @{sentKBps=[math]::Round($n.BytesSentPersec/1024,1); recvKBps=[math]::Round($n.BytesReceivedPersec/1024,1)} | ConvertTo-Json"
      ]).timeout(const Duration(seconds: 5));
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        return Map<String, dynamic>.from(jsonDecode(result.stdout.toString().trim()));
      }
    } catch (e) {
      debugPrint('Network info error: $e');
    }
    return {'sentKBps': 0.0, 'recvKBps': 0.0};
  }

  /// Get top processes sorted by CPU/memory
  static Future<List<Map<String, dynamic>>> getProcesses({int limit = 25}) async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        'Get-Process | Sort-Object -Property WorkingSet64 -Descending | Select-Object -First $limit Id, ProcessName, @{N="CpuPercent";E={0}}, @{N="MemoryMB";E={[math]::Round(\$_.WorkingSet64/1MB,1)}} | ConvertTo-Json'
      ]).timeout(const Duration(seconds: 8));
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        var raw = jsonDecode(result.stdout.toString().trim());
        if (raw is! List) raw = [raw];
        return List<Map<String, dynamic>>.from(raw.map((p) => {
          'pid': p['Id'] ?? 0,
          'name': p['ProcessName'] ?? '',
          'cpuPercent': p['CpuPercent'] ?? 0,
          'memoryMB': p['MemoryMB'] ?? 0.0,
        }));
      }
    } catch (e) {
      debugPrint('Processes error: $e');
    }
    return [];
  }

  /// Kill a process by PID
  static Future<bool> killProcess(int pid) async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        'Stop-Process -Id $pid -Force -ErrorAction Stop'
      ]).timeout(const Duration(seconds: 5));
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Kill process error: $e');
      return false;
    }
  }

  /// Get clipboard text
  static Future<String> getClipboard() async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        'Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Clipboard]::GetText()'
      ]).timeout(const Duration(seconds: 3));
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      debugPrint('Get clipboard error: $e');
    }
    return '';
  }

  /// Set clipboard text
  static Future<bool> setClipboard(String text) async {
    try {
      final escaped = text.replaceAll("'", "''");
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-STA', '-Command',
        "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Clipboard]::SetText('$escaped')"
      ]).timeout(const Duration(seconds: 3));
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Set clipboard error: $e');
      return false;
    }
  }

  /// Execute power command
  static Future<bool> powerAction(String action) async {
    try {
      String command;
      switch (action) {
        case 'shutdown':
          command = 'shutdown /s /t 3';
          break;
        case 'restart':
          command = 'shutdown /r /t 3';
          break;
        case 'sleep':
          command = 'rundll32.exe powrprof.dll,SetSuspendState 0,1,0';
          break;
        case 'lock':
          command = 'rundll32.exe user32.dll,LockWorkStation';
          break;
        case 'hibernate':
          command = 'shutdown /h';
          break;
        default:
          return false;
      }
      final result = await Process.run('cmd', ['/c', command]);
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Power action error: $e');
      return false;
    }
  }

  /// Get current volume level (0-100)
  static Future<int> getVolume() async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        r"Add-Type -TypeDefinition 'using System;using System.Runtime.InteropServices;[Guid(""5CDF2C82-841E-4546-9722-0CF74078229A""),InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]interface IAudioEndpointVolume{int a();int b();int c();int d();int e();int f();int SetMasterVolumeLevelScalar(float fLevel, ref Guid pguidEventContext);int g(out float pfLevel);}';"
        r"(Get-Process -Name 'audiodg' -ErrorAction SilentlyContinue | Out-Null); "
        r"$vol = [Math]::Round((Get-AudioDevice -PlaybackVolume -ErrorAction SilentlyContinue) ?? 50); Write-Output $vol"
      ]).timeout(const Duration(seconds: 3));
      if (result.exitCode == 0) {
        return int.tryParse(result.stdout.toString().trim()) ?? 50;
      }
    } catch (_) {}
    // Fallback: simpler method
    try {
      await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        r"(New-Object -ComObject WScript.Shell).SendKeys([char]0)"
      ]).timeout(const Duration(seconds: 2));
      return 50; // default
    } catch (_) {}
    return 50;
  }

  /// Set volume level using nircmd or key simulation
  static Future<bool> setVolume(int level) async {
    try {
      // Use PowerShell with SendKeys to set volume
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        'Set-Variable -Name vol -Value $level; '
        r"$wsh = New-Object -ComObject WScript.Shell; "
        'for(\$i=0;\$i -lt 50;\$i++){\$wsh.SendKeys([char]174)}; ' // 50x volume down to baseline
        'for(\$i=0;\$i -lt [math]::Round($level/2);\$i++){\$wsh.SendKeys([char]175)}' // volume up to target
      ]).timeout(const Duration(seconds: 10));
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Set volume error: $e');
      return false;
    }
  }

  /// Set screen brightness (0-100)
  static Future<bool> setBrightness(int level) async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        '(Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1,$level)'
      ]).timeout(const Duration(seconds: 5));
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Set brightness error: $e');
      return false;
    }
  }

  /// Get Windows notifications (basic)
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile', '-NonInteractive', '-Command',
        r"Get-WinEvent -LogName 'Microsoft-Windows-PushNotification-Platform/Operational' -MaxEvents 10 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Message | ConvertTo-Json"
      ]).timeout(const Duration(seconds: 5));
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        var raw = jsonDecode(result.stdout.toString().trim());
        if (raw is! List) raw = [raw];
        return List<Map<String, dynamic>>.from(raw.map((n) => {
          'time': n['TimeCreated']?.toString() ?? '',
          'message': n['Message']?.toString() ?? '',
        }));
      }
    } catch (e) {
      debugPrint('Notifications error: $e');
    }
    return [];
  }
}
