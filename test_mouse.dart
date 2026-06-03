import 'dart:ffi';

typedef MouseEventC = Void Function(Int32 dwFlags, Int32 dx, Int32 dy, Int32 dwData, Int32 dwExtraInfo);
typedef MouseEventDart = void Function(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);

const int MOUSEEVENTF_MOVE = 0x0001;

void main() {
  final user32 = DynamicLibrary.open('user32.dll');
  final MouseEventDart mouseEvent = user32.lookupFunction<MouseEventC, MouseEventDart>('mouse_event');
  
  mouseEvent(MOUSEEVENTF_MOVE, 100, 100, 0, 0);
  print('Mouse moved');
}
