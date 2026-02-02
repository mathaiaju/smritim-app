import 'dart:typed_data';

Future<void> downloadFileImpl(
  Uint8List bytes,
  String fileName,
) {
  throw UnsupportedError(
    'File download is not supported on this platform',
  );
}
