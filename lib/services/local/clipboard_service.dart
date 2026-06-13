import 'package:flutter/services.dart';

class ClipboardService {
  Future<String?> readText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  Future<({String base64, String mime})?> readImage() async {
    return null;
  }
}
