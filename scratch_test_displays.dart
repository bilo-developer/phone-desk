import 'package:flutter/widgets.dart';
import 'package:screen_retriever/screen_retriever.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final displays = await screenRetriever.getAllDisplays();
  for (var d in displays) {
    print('Display: ${d.id}, ${d.name}, ${d.visiblePosition}, ${d.size}');
  }
}
