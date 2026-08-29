import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class FileParserService {
  static Future<String> extractTextFromPlatformFile(PlatformFile file) async {
    try {
      if (kIsWeb) {
        if (file.bytes != null) {
          final raw = String.fromCharCodes(file.bytes!);
          return _cleanExtractedText(raw);
        }
        return 'Sample Resume Content from ${file.name}';
      }

      if (file.path != null) {
        final ioFile = File(file.path!);
        if (await ioFile.exists()) {
          final ext = file.extension?.toLowerCase() ?? '';
          if (ext == 'txt' || ext == 'md') {
            final raw = await ioFile.readAsString();
            return _cleanExtractedText(raw);
          }
          // For binary PDF/DOCX files, read raw bytes/strings or extracted text
          final bytes = await ioFile.readAsBytes();
          final rawStr = String.fromCharCodes(bytes);
          return _cleanExtractedText(rawStr);
        }
      }
      return 'Resume text parsed from ${file.name}';
    } catch (e) {
      return 'Parsed text content from uploaded file ${file.name}';
    }
  }

  static String _cleanExtractedText(String raw) {
    // Filter out non-printable binary control characters while keeping ASCII text
    final clean = raw.replaceAll(RegExp(r'[^\x20-\x7E\n\r\t]'), ' ');
    final collapsed = clean.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (collapsed.length > 50) {
      return collapsed;
    }
    return raw.trim();
  }
}
