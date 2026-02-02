import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

Future<void> downloadFileImpl(
  Uint8List bytes,
  String fileName,
) async {
  final status = await Permission.storage.request();
  if (!status.isGranted) {
    throw Exception("Storage permission denied");
  }

  final downloadsDir = Directory('/storage/emulated/0/Download');
  if (!downloadsDir.existsSync()) {
    downloadsDir.createSync(recursive: true);
  }

  final file = File('${downloadsDir.path}/$fileName');
  await file.writeAsBytes(bytes);

  await OpenFile.open(file.path);
}
