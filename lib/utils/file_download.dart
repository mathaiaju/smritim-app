import 'dart:typed_data';

// ✅ CONDITIONAL IMPORTS (compile-time)
import 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart'
    if (dart.library.io) 'file_download_mobile.dart';

/// Public API used by ApiClient
Future<void> downloadFile(
  Uint8List bytes,
  String fileName,
) {
  return downloadFileImpl(bytes, fileName);
}
