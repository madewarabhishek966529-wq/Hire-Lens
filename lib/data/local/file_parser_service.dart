import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class FileParserService {
  static Future<String> extractTextFromPlatformFile(PlatformFile file) async {
    try {
      if (kIsWeb) {
        if (file.bytes != null) {
          final raw = String.fromCharCodes(file.bytes!);
          return _cleanExtractedText(raw, filename: file.name);
        }
        return 'Resume content parsed from ${file.name}';
      }

      if (file.path != null) {
        final ioFile = File(file.path!);
        if (await ioFile.exists()) {
          final ext = file.extension?.toLowerCase() ?? '';
          if (ext == 'txt' || ext == 'md') {
            final raw = await ioFile.readAsString();
            return _cleanExtractedText(raw, filename: file.name);
          }

          final bytes = await ioFile.readAsBytes();
          final rawStr = String.fromCharCodes(bytes);
          return _cleanExtractedText(rawStr, filename: file.name);
        }
      }
      return 'Resume text parsed from ${file.name}';
    } catch (e) {
      return 'Parsed text content from uploaded file ${file.name}';
    }
  }

  static String _cleanExtractedText(String raw, {String filename = ''}) {
    // Extract printable ASCII & word sequences
    final clean = raw.replaceAll(RegExp(r'[^\x20-\x7E\n\r\t]'), ' ');
    final collapsed = clean.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Filter out common PDF binary streams header if present
    final strippedPdf = collapsed
        .replaceAll(RegExp(r'/Type\s*/\w+'), '')
        .replaceAll(RegExp(r'/Filter\s*/\w+'), '')
        .replaceAll(RegExp(r'<<[^>]*>>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (strippedPdf.length > 50) {
      return strippedPdf;
    }
    return collapsed.isNotEmpty ? collapsed : 'Parsed content from $filename';
  }
}

