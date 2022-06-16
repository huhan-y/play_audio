import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

final _nid = calloc<NOTIFYICONDATA>()..ref.cbSize = sizeOf<NOTIFYICONDATA>();


void addIcon({required int hWndParent}) {
  final nid = _nid.ref
    ..hWnd = hWndParent
    ..uFlags = NIF_ICON | NIF_TIP | NIF_MESSAGE | NIF_SHOWTIP | NIF_GUID
    ..szTip = '5G哨兵报警'
    ..hIcon = _loadDartIcon();

  Shell_NotifyIcon(NIM_ADD, _nid);

  nid.uVersion = 4;
  Shell_NotifyIcon(NIM_SETVERSION, _nid);
}

void removeIcon() {
  Shell_NotifyIcon(NIM_DELETE, _nid);
  free(_nid);
}

int _loadDartIcon() {
  final dartIconPath = _thisPath('logo.ico');
  return LoadImage(0, TEXT(dartIconPath), IMAGE_ICON, 0, 0,
      LR_LOADFROMFILE | LR_DEFAULTSIZE | LR_SHARED);
}

String _thisPath(String fileName) =>
    Platform.script.toFilePath().replaceFirst(RegExp(r'[^\\]+$'), 'data\\flutter_assets\\assets\\$fileName');