import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

import '../../core/config.dart';

class FileService {
  Future<({String path, String name, String mime, String? base64})?> pickFile({
    bool includeContent = false,
  }) async {
    final result = await FilePicker.pickFiles(withData: includeContent);
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final path = file.path;
    if (path == null) return null;

    final mime = lookupMimeType(path) ?? 'application/octet-stream';
    String? base64Content;
    if (includeContent) {
      final bytes = file.bytes ?? await File(path).readAsBytes();
      if (bytes.length > AppConfig.maxFileReadBytes) return null;
      base64Content = base64Encode(bytes);
    }

    return (
      path: path,
      name: file.name,
      mime: mime,
      base64: base64Content,
    );
  }
}
