import 'dart:typed_data';

Future<void> downloadFileImpl(
  Uint8List bytes,
  String fileName,
) async {
  throw UnsupportedError('File download not supported on this platform');
}
