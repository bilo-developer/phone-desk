import 'package:screen_retriever/screen_retriever.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final displays = await screenRetriever.getAllDisplays();
  for (var d in displays) {
    print('Display: id=${d.id}, name=${d.name}, pos=${d.visiblePosition}, size=${d.size}');
  }
}
