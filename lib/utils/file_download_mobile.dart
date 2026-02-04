import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> downloadFileImpl(Uint8List bytes, String fileName) async {
  try {
    // 📂 User-visible Downloads directory (Android-safe)
    final directory = await getDownloadsDirectory();

    if (directory == null) {
      throw Exception('Downloads directory not available');
    }

    final file = File('${directory.path}/$fileName');

    // 💾 Write file
    await file.writeAsBytes(bytes, flush: true);

    // 📂 Open file after saving (optional but UX-friendly)
    await OpenFile.open(file.path);
  } catch (e) {
    print('Download error: $e');
    rethrow;
  }
}
