import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'deck_manager.dart';
import 'theme.dart';

/// Desktop deck management panel - shows buttons in a grid with edit capabilities
class DeckPanel extends StatefulWidget {
  final DeckManager deckManager;
  final VoidCallback onChanged;

  const DeckPanel({
    super.key,
    required this.deckManager,
    required this.onChanged,
  });

  @override
  State<DeckPanel> createState() => _DeckPanelState();
}

class _DeckPanelState extends State<DeckPanel> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  DeckManager get dm => widget.deckManager;

  void _refresh() {
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final profile = dm.activeProfile;

    return Container(
      color: context.theme.surfaceLow,
      child: Column(
        children: [
          // Profile Selector Bar
          _buildProfileBar(),
          // Deck Grid
          Expanded(
            child: profile == null || profile.buttons.isEmpty
                ? _buildEmptyState()
                : _buildButtonGrid(profile),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          // Profile chips
          Expanded(
            child: SizedBox(
              height: 36,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.trackpad}),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: dm.profiles.length + 1,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == dm.profiles.length) {
                      return _buildAddProfileChip();
                    }
                    final profile = dm.profiles[index];
                    final isActive = profile.id == dm.activeProfileId;
                    return _buildProfileChip(profile, isActive);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Add Button
          _buildAddButtonAction(),
          const SizedBox(width: 8),
          _buildImportButtonAction(),
        ],
      ),
    );
  }

  Widget _buildProfileChip(DeckProfile profile, bool isActive) {
    final color = Color(int.parse('FF${profile.color}', radix: 16));
    return GestureDetector(
      onTap: () {
        dm.activeProfileId = profile.id;
        dm.save();
        _refresh();
      },
      onSecondaryTapDown: (details) {
        _showProfileContextMenu(context, details.globalPosition, profile);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(colors: [color, color.withOpacity(0.7)])
              : null,
          color: isActive ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color.withOpacity(0.5) : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              getIconDataFromName(profile.iconName),
              size: 16,
              color: isActive ? Colors.white : Colors.white54,
            ),
            const SizedBox(width: 6),
            Text(
              profile.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? Colors.white : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProfileChip() {
    return GestureDetector(
      onTap: () => _showAddProfileDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), style: BorderStyle.solid),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: Colors.white38),
            SizedBox(width: 4),
            Text('Profil', style: TextStyle(fontSize: 13, color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButtonAction() {
    return InkWell(
      onTap: () => _showButtonEditor(null),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.theme.primaryContainer.withOpacity(0.3),
              context.theme.accentPurple.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.theme.primaryContainer.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline, size: 16, color: context.theme.primaryContainer),
            const SizedBox(width: 6),
            Text('Buton Ekle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.theme.primaryContainer)),
          ],
        ),
      ),
    );
  }

  Widget _buildImportButtonAction() {
    return InkWell(
      onTap: _importProfile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.file_download_outlined, size: 16, color: Colors.white70),
            SizedBox(width: 6),
            Text('İçe Aktar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Future<void> _exportProfile(DeckProfile profile) async {
    try {
      final jsonStr = dm.exportProfileToJson(profile.id);
      final path = await FilePicker.saveFile(
        dialogTitle: 'Profili Dışa Aktar',
        fileName: '${profile.name.replaceAll(' ', '_').toLowerCase()}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (path != null) {
        final file = File(path);
        await file.writeAsString(jsonStr);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil başarıyla dışa aktarıldı.'), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _importProfile() async {
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Profil İçe Aktar',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonStr = await file.readAsString();
        final success = dm.importProfileFromJson(jsonStr);
        if (success) {
          _refresh();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil başarıyla içe aktarıldı.'), backgroundColor: Colors.green));
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geçersiz profil dosyası.'), backgroundColor: Colors.red));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.3 + (_pulseController.value * 0.3),
                child: child,
              );
            },
            child: Icon(Icons.dashboard_customize, size: 64, color: context.theme.primaryContainer),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz buton eklenmedi',
            style: TextStyle(color: context.theme.outline, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '"Buton Ekle" ile başlayın',
            style: TextStyle(color: context.theme.outline.withOpacity(0.5), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonGrid(DeckProfile profile) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: profile.buttons.length,
      itemBuilder: (context, index) {
        return _buildDeckButton(profile.buttons[index]);
      },
    );
  }

  Widget _buildDeckButton(DeckButton button) {
    final color = Color(int.parse('FF${button.color}', radix: 16));
    final darkColor = HSLColor.fromColor(color).withLightness(0.15).toColor();
    
    return GestureDetector(
      onTap: () async {
        // Execute action with visual feedback
        setState(() {}); // trigger rebuild for feedback
        final success = await dm.executeAction(button);
        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${button.label} çalıştırılamadı'),
              backgroundColor: Colors.red.shade800,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      onSecondaryTapDown: (details) {
        _showButtonContextMenu(context, details.globalPosition, button);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              darkColor,
              color.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: color.withOpacity(0.3),
            highlightColor: color.withOpacity(0.1),
            onTap: () async {
              final success = await dm.executeAction(button);
              if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${button.label} çalıştırılamadı'),
                    backgroundColor: Colors.red.shade800,
                  ),
                );
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    getIconDataFromName(button.iconName),
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    button.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getActionLabel(button.actionType),
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getActionLabel(String type) {
    switch (type) {
      case 'hotkey': return '⌨ Kısayol';
      case 'launch': return '🚀 Uygulama';
      case 'media': return '🎵 Medya';
      case 'volume': return '🔊 Ses';
      case 'command': return '💻 Komut';
      case 'folder': return '📁 Klasör';
      case 'text': return '📝 Metin';
      case 'url': return '🌐 URL';
      default: return type;
    }
  }

  void _showProfileContextMenu(BuildContext context, Offset position, DeckProfile profile) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx + 1, position.dy + 1),
      color: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          child: const Row(children: [Icon(Icons.edit, size: 16, color: Colors.white70), SizedBox(width: 8), Text('Düzenle', style: TextStyle(color: Colors.white70))]),
          onTap: () => Future.delayed(Duration.zero, () => _showEditProfileDialog(profile)),
        ),
        PopupMenuItem(
          child: const Row(children: [Icon(Icons.download, size: 16, color: Colors.white70), SizedBox(width: 8), Text('Dışa Aktar', style: TextStyle(color: Colors.white70))]),
          onTap: () => Future.delayed(Duration.zero, () => _exportProfile(profile)),
        ),
        if (dm.profiles.length > 1)
          PopupMenuItem(
            child: const Row(children: [Icon(Icons.delete, size: 16, color: Colors.redAccent), SizedBox(width: 8), Text('Sil', style: TextStyle(color: Colors.redAccent))]),
            onTap: () {
              dm.removeProfile(profile.id);
              _refresh();
            },
          ),
      ],
    );
  }

  void _showButtonContextMenu(BuildContext context, Offset position, DeckButton button) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx + 1, position.dy + 1),
      color: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          child: const Row(children: [Icon(Icons.play_arrow, size: 16, color: Colors.greenAccent), SizedBox(width: 8), Text('Çalıştır', style: TextStyle(color: Colors.white70))]),
          onTap: () => dm.executeAction(button),
        ),
        PopupMenuItem(
          child: const Row(children: [Icon(Icons.edit, size: 16, color: Colors.white70), SizedBox(width: 8), Text('Düzenle', style: TextStyle(color: Colors.white70))]),
          onTap: () => Future.delayed(Duration.zero, () => _showButtonEditor(button)),
        ),
        PopupMenuItem(
          child: const Row(children: [Icon(Icons.delete, size: 16, color: Colors.redAccent), SizedBox(width: 8), Text('Sil', style: TextStyle(color: Colors.redAccent))]),
          onTap: () {
            dm.removeButton(button.id);
            _refresh();
          },
        ),
      ],
    );
  }

  void _showAddProfileDialog() {
    final nameController = TextEditingController();
    String selectedIcon = 'dashboard';
    String selectedColor = '3B82F6';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Yeni Profil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            content: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(nameController, 'Profil Adı', Icons.label),
                  const SizedBox(height: 16),
                  const Text('İkon', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  _buildIconSelector(selectedIcon, (icon) {
                    setDialogState(() => selectedIcon = icon);
                  }),
                  const SizedBox(height: 16),
                  const Text('Renk', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  _buildColorSelector(selectedColor, (color) {
                    setDialogState(() => selectedColor = color);
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    dm.addProfile(nameController.text, selectedIcon, selectedColor);
                    _refresh();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Oluştur', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(DeckProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    String selectedIcon = profile.iconName;
    String selectedColor = profile.color;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Profil Düzenle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            content: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(nameController, 'Profil Adı', Icons.label),
                  const SizedBox(height: 16),
                  const Text('İkon', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  _buildIconSelector(selectedIcon, (icon) {
                    setDialogState(() => selectedIcon = icon);
                  }),
                  const SizedBox(height: 16),
                  const Text('Renk', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  _buildColorSelector(selectedColor, (color) {
                    setDialogState(() => selectedColor = color);
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  profile.name = nameController.text;
                  profile.iconName = selectedIcon;
                  profile.color = selectedColor;
                  dm.save();
                  _refresh();
                  Navigator.pop(context);
                },
                child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showButtonEditor(DeckButton? existing) {
    final isNew = existing == null;
    final labelController = TextEditingController(text: existing?.label ?? '');
    final actionDataController = TextEditingController(text: existing?.actionData ?? '');
    String selectedIcon = existing?.iconName ?? 'touch_app';
    String selectedColor = existing?.color ?? '3B82F6';
    String selectedActionType = existing?.actionType ?? 'hotkey';

    final hotkeyFocusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              isNew ? 'Yeni Buton' : 'Butonu Düzenle',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(labelController, 'Buton Adı', Icons.label),
                    const SizedBox(height: 16),

                    // Action Type Selector
                    const Text('Aksiyon Türü', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    _buildActionTypeSelector(selectedActionType, (type) {
                      setDialogState(() => selectedActionType = type);
                    }),
                    const SizedBox(height: 16),

                    // Action Data
                    const Text('Aksiyon Verisi', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      _getActionHint(selectedActionType),
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    if (selectedActionType == 'media')
                      _buildMediaSelector(actionDataController.text, (val) {
                        setDialogState(() => actionDataController.text = val);
                      })
                    else if (selectedActionType == 'volume')
                      _buildVolumeSelector(actionDataController.text, (val) {
                        setDialogState(() => actionDataController.text = val);
                      })
                    else if (selectedActionType == 'hotkey')
                      GestureDetector(
                        onTap: () {
                          hotkeyFocusNode.requestFocus();
                        },
                        child: Focus(
                          focusNode: hotkeyFocusNode,
                          autofocus: true,
                          onKeyEvent: (node, event) {
                            if (event is KeyDownEvent) {
                              if (event.logicalKey == LogicalKeyboardKey.backspace || event.logicalKey == LogicalKeyboardKey.delete) {
                                setDialogState(() {
                                  actionDataController.text = '';
                                });
                                return KeyEventResult.handled;
                              }
                              
                              List<String> keys = [];
                              if (HardwareKeyboard.instance.isControlPressed) keys.add('ctrl');
                              if (HardwareKeyboard.instance.isAltPressed) keys.add('alt');
                              if (HardwareKeyboard.instance.isShiftPressed) keys.add('shift');
                              if (HardwareKeyboard.instance.isMetaPressed) keys.add('win');
                              
                              final keyLabel = event.logicalKey.keyLabel.toLowerCase();
                              if (!['control left', 'control right', 'alt left', 'alt right', 'shift left', 'shift right', 'meta left', 'meta right'].contains(keyLabel)) {
                                  keys.add(keyLabel);
                              }
                              
                              if (keys.isNotEmpty) {
                                  setDialogState(() {
                                      actionDataController.text = keys.join('+');
                                  });
                              }
                              return KeyEventResult.handled;
                            }
                            return KeyEventResult.ignored;
                          },
                          child: AnimatedBuilder(
                            animation: hotkeyFocusNode,
                            builder: (context, child) {
                              final isFocused = hotkeyFocusNode.hasFocus;
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isFocused ? Colors.blueAccent : Colors.white.withOpacity(0.1)),
                                  boxShadow: isFocused ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 8)] : null,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.keyboard, size: 18, color: Colors.white38),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        actionDataController.text.isEmpty 
                                          ? (isFocused ? 'Tuşlara basın (Silmek için Backspace)' : 'Kısayol atamak için tıklayın')
                                          : actionDataController.text,
                                        style: TextStyle(
                                          color: actionDataController.text.isEmpty ? Colors.white24 : Colors.white, 
                                          fontSize: 14
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          ),
                        ),
                      )
                    else if (selectedActionType == 'launch')
                      _buildTextField(
                        actionDataController, 
                        _getActionPlaceholder(selectedActionType), 
                        Icons.rocket_launch,
                        trailing: IconButton(
                          icon: const Icon(Icons.folder_open, color: Colors.white70),
                          onPressed: () async {
                            final result = await FilePicker.pickFiles(
                              type: FileType.any, // Store apps might be .exe or custom
                            );
                            if (result != null && result.files.single.path != null) {
                              setDialogState(() => actionDataController.text = result.files.single.path!);
                            }
                          },
                        ),
                      )
                    else if (selectedActionType == 'folder')
                      _buildTextField(
                        actionDataController, 
                        _getActionPlaceholder(selectedActionType), 
                        Icons.folder,
                        trailing: IconButton(
                          icon: const Icon(Icons.folder_open, color: Colors.white70),
                          onPressed: () async {
                            final result = await FilePicker.getDirectoryPath();
                            if (result != null) {
                              setDialogState(() => actionDataController.text = result);
                            }
                          },
                        ),
                      )
                    else
                      _buildTextField(actionDataController, _getActionPlaceholder(selectedActionType), Icons.data_object),
                    const SizedBox(height: 16),

                    // Icon Selector
                    const Text('İkon', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.trackpad}),
                      child: _buildIconSelector(selectedIcon, (icon) {
                        setDialogState(() => selectedIcon = icon);
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Color Selector
                    const Text('Renk', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.trackpad}),
                      child: _buildColorSelector(selectedColor, (color) {
                        setDialogState(() => selectedColor = color);
                      }),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(int.parse('FF$selectedColor', radix: 16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (labelController.text.isEmpty) return;
                  
                  final button = DeckButton(
                    id: existing?.id ?? 'btn_${DateTime.now().millisecondsSinceEpoch}',
                    label: labelController.text,
                    iconName: selectedIcon,
                    color: selectedColor,
                    actionType: selectedActionType,
                    actionData: actionDataController.text,
                  );

                  if (isNew) {
                    dm.addButton(button);
                  } else {
                    dm.updateButton(button);
                  }
                  _refresh();
                  Navigator.pop(context);
                },
                child: Text(isNew ? 'Ekle' : 'Kaydet', style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {Widget? trailing, FocusNode? focusNode, bool readOnly = false, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              readOnly: readOnly,
              onTap: onTap,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: Icon(icon, size: 18, color: Colors.white38),
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              ),
            ),
          ),
          if (trailing != null) ...[
            trailing,
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildActionTypeSelector(String selected, ValueChanged<String> onChanged) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: actionTypes.map((at) {
        final isSelected = at.type == selected;
        return GestureDetector(
          onTap: () => onChanged(at.type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.08),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(at.icon, size: 14, color: isSelected ? Colors.white : Colors.white38),
                const SizedBox(width: 6),
                Text(
                  at.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : Colors.white54,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMediaSelector(String selected, ValueChanged<String> onChanged) {
    final options = [
      ('play_pause', 'Oynat/Duraklat', Icons.play_circle),
      ('next', 'Sonraki', Icons.skip_next),
      ('prev', 'Önceki', Icons.skip_previous),
      ('stop', 'Durdur', Icons.stop),
    ];

    return Wrap(
      spacing: 8,
      children: options.map((o) {
        final isSelected = o.$1 == selected;
        return GestureDetector(
          onTap: () => onChanged(o.$1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.pinkAccent.withOpacity(0.2) : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? Colors.pinkAccent.withOpacity(0.5) : Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(o.$3, size: 16, color: isSelected ? Colors.pinkAccent : Colors.white38),
                const SizedBox(width: 6),
                Text(o.$2, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.white54)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVolumeSelector(String selected, ValueChanged<String> onChanged) {
    final options = [
      ('up', 'Ses Aç', Icons.volume_up),
      ('down', 'Ses Kıs', Icons.volume_down),
      ('mute', 'Sessiz', Icons.volume_off),
    ];

    return Wrap(
      spacing: 8,
      children: options.map((o) {
        final isSelected = o.$1 == selected;
        return GestureDetector(
          onTap: () => onChanged(o.$1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.cyan.withOpacity(0.2) : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? Colors.cyan.withOpacity(0.5) : Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(o.$3, size: 16, color: isSelected ? Colors.cyan : Colors.white38),
                const SizedBox(width: 6),
                Text(o.$2, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.white54)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconSelector(String selected, ValueChanged<String> onChanged) {
    return SizedBox(
      height: 80,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: availableIcons.length,
        itemBuilder: (context, index) {
          final icon = availableIcons[index];
          final isSelected = icon == selected;
          return GestureDetector(
            onTap: () => onChanged(icon),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? Colors.white.withOpacity(0.4) : Colors.transparent,
                ),
              ),
              child: Icon(
                getIconDataFromName(icon),
                size: 18,
                color: isSelected ? Colors.white : Colors.white38,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSelector(String selected, ValueChanged<String> onChanged) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: availableColors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final color = availableColors[index];
          final isSelected = color == selected;
          final c = Color(int.parse('FF$color', radix: 16));
          return GestureDetector(
            onTap: () => onChanged(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: isSelected ? 2.5 : 0,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          );
        },
      ),
    );
  }

  String _getActionHint(String type) {
    switch (type) {
      case 'hotkey': return 'Örn: ctrl+c, alt+tab, win+shift+s';
      case 'launch': return 'Tam dosya yolu. Örn: C:\\Program Files\\app.exe';
      case 'media': return 'Aşağıdan bir medya kontrolü seçin';
      case 'volume': return 'Aşağıdan bir ses kontrolü seçin';
      case 'command': return 'PowerShell komutu. Örn: Get-Process';
      case 'folder': return 'Klasör yolu. Örn: C:\\Users\\Desktop';
      case 'text': return 'Yapıştırılacak metin';
      case 'url': return 'Örn: https://youtube.com';
      default: return '';
    }
  }

  String _getActionPlaceholder(String type) {
    switch (type) {
      case 'hotkey': return 'ctrl+shift+s';
      case 'launch': return 'C:\\path\\to\\app.exe';
      case 'command': return 'komut';
      case 'folder': return 'C:\\Users\\Desktop';
      case 'text': return 'Metin girin...';
      case 'url': return 'https://...';
      default: return 'Veri girin...';
    }
  }
}
