import 'package:flutter/widgets.dart';
import 'package:screen_retriever/screen_retriever.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var d = await screenRetriever.getAllDisplays();
  for (var i in d) print('${i.id} ${i.name} X: ${i.visiblePosition?.dx} Y: ${i.visiblePosition?.dy} W: ${i.size.width} H: ${i.size.height}');
}
