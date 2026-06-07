import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:image/image.dart' as img;

class MedicineOCRHelper {
  static Future<Map<String, String>> performOCR(File file) async {
    try {
      String OCR_API_KEY = dotenv.get("OCR_API_KEY");
      final Uri url = Uri.parse("https://api.ocr.space/parse/image");

      var request = http.MultipartRequest('POST', url);
      request.headers['apiKey'] = OCR_API_KEY;

      File compressed = await _compressImage(file);
      request.files
          .add(await http.MultipartFile.fromPath('file', compressed.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      Logger().d(response.statusCode);
      Logger().d(response.body);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        String parsedText = _extractParsedText(responseBody);
        return _extractMedicineFields(parsedText);
      } else {
        print("OCR API Error: ${response.statusCode}");
        return {};
      }
    } catch (e) {
      print("OCR Error: ${e.toString()}");
      return {};
    }
  }

  static String _extractParsedText(Map<String, dynamic> responseBody) {
    try {
      if (responseBody['ParsedResults'] != null &&
          responseBody['ParsedResults'].isNotEmpty) {
        var firstResult = responseBody['ParsedResults'][0];
        if (firstResult['ParsedText'] != null) {
          return firstResult['ParsedText'].toString();
        }
      }
    } catch (e) {
      print("Error extracting parsed text: $e");
    }
    return "";
  }

  static Map<String, String> _extractMedicineFields(String parsedText) {
    Map<String, String> fields = {};

    if (parsedText.isEmpty) return fields;

    String lowerText = parsedText.toLowerCase();
    List<String> lines = parsedText.split('\n');

    fields['name'] = _extractMedicineName(lines, lowerText);
    fields['type'] = _extractMedicineType(lowerText);
    fields['quantity'] = _extractQuantity(parsedText, lowerText);
    fields['manufacturer'] = _extractManufacturer(lines, lowerText);
    fields['batchNumber'] = _extractBatchNumber(parsedText, lowerText);
    fields['expiryDate'] = _extractExpiryDate(parsedText, lowerText);
    fields['purchaseDate'] = _extractManufacturingDate(parsedText, lowerText);

    return fields;
  }

  static String _extractMedicineName(List<String> lines, String lowerText) {
    List<String> skipWords = [
      'tablet',
      'capsule',
      'syrup',
      'mg',
      'ml',
      'ltd',
      'pvt',
      'inc'
    ];

    for (var line in lines) {
      String trimmed = line.trim();
      if (trimmed.length > 3 && trimmed.length < 50) {
        bool hasSkipWord =
            skipWords.any((word) => trimmed.toLowerCase().contains(word));

        if (!hasSkipWord && RegExp(r'^[A-Za-z]').hasMatch(trimmed)) {
          return trimmed;
        }
      }
    }

    return "";
  }

  static Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) return file;

    // Resize (optional)
    image = img.copyResize(image, width: 1024);

    final compressedBytes = img.encodeJpg(image, quality: 70); // 70% quality

    final compressedFile =
        File(file.path.replaceFirst('.jpg', '_compressed.jpg'));
    await compressedFile.writeAsBytes(compressedBytes);

    return compressedFile;
  }

  static String _extractMedicineType(String lowerText) {
    Map<String, String> typeKeywords = {
      'tablet': 'Tablet',
      'tablets': 'Tablet',
      'capsule': 'Capsule',
      'capsules': 'Capsule',
      'syrup': 'Syrup',
      'injection': 'Injection',
      'cream': 'Cream/Ointment',
      'ointment': 'Cream/Ointment',
      'drops': 'Drops',
      'drop': 'Drops',
      'inhaler': 'Inhaler',
      'patch': 'Patch',
      'powder': 'Powder',
      'gel': 'Gel',
      'spray': 'Spray',
      'lotion': 'Lotion',
      'suspension': 'Suspension',
      'suppository': 'Suppository',
    };

    for (var entry in typeKeywords.entries) {
      if (lowerText.contains(entry.key)) {
        return entry.value;
      }
    }

    return "";
  }

  static String _extractQuantity(String text, String lowerText) {
    RegExp quantityPattern = RegExp(
        r'(\d+)\s*(tablet|tablets|capsule|capsules|ml|mg|g|strips?|units?)',
        caseSensitive: false);

    var match = quantityPattern.firstMatch(text);
    if (match != null) {
      return match.group(0) ?? "";
    }

    RegExp numberPattern = RegExp(r'\d+\s*(mg|ml|g)\b', caseSensitive: false);
    match = numberPattern.firstMatch(text);
    if (match != null) {
      return match.group(0) ?? "";
    }

    return "";
  }

  static String _extractManufacturer(List<String> lines, String lowerText) {
    List<String> mfgKeywords = [
      'manufactured by',
      'mfg by',
      'manufactured',
      'pharma',
      'pharmaceutical',
      'laboratories',
      'ltd',
      'pvt',
      'inc'
    ];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].toLowerCase();

      if (mfgKeywords.any((keyword) => line.contains(keyword))) {
        String cleaned = lines[i]
            .replaceAll(RegExp(r'manufactured by:?', caseSensitive: false), '')
            .replaceAll(RegExp(r'mfg by:?', caseSensitive: false), '')
            .trim();

        if (cleaned.isNotEmpty) {
          return cleaned;
        }

        if (i + 1 < lines.length) {
          return lines[i + 1].trim();
        }
      }
    }

    for (var line in lines) {
      if (RegExp(r'(ltd|pvt|inc|pharma|laboratories)', caseSensitive: false)
          .hasMatch(line)) {
        return line.trim();
      }
    }

    return "";
  }

  static String _extractBatchNumber(String text, String lowerText) {
    List<RegExp> patterns = [
      RegExp(r'batch\s*(?:no|number)?[\s:]*([A-Z0-9]+)', caseSensitive: false),
      RegExp(r'b\.?\s*no\.?[\s:]*([A-Z0-9]+)', caseSensitive: false),
      RegExp(r'lot\s*(?:no|number)?[\s:]*([A-Z0-9]+)', caseSensitive: false),
      RegExp(r'batch[\s:]+([A-Z0-9]{4,})', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      var match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }

    return "";
  }

  static String _extractExpiryDate(String text, String lowerText) {
    List<RegExp> patterns = [
      RegExp(r'exp(?:iry)?[\s:]*(\d{2}[-/]\d{4})', caseSensitive: false),
      RegExp(r'exp(?:iry)?[\s:]*(\d{2}[-/]\d{2}[-/]\d{4})',
          caseSensitive: false),
      RegExp(
          r'exp(?:iry)?[\s:]*((?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s*\d{4})',
          caseSensitive: false),
      RegExp(r'valid\s*until[\s:]*(\d{2}[-/]\d{4})', caseSensitive: false),
      RegExp(r'use\s*before[\s:]*(\d{2}[-/]\d{4})', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      var match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return _formatDate(match.group(1)!);
      }
    }

    return "";
  }

  static String _extractManufacturingDate(String text, String lowerText) {
    List<RegExp> patterns = [
      RegExp(r'mfg[\s:]*(\d{2}[-/]\d{4})', caseSensitive: false),
      RegExp(r'manufactured[\s:]*(\d{2}[-/]\d{4})', caseSensitive: false),
      RegExp(
          r'mfg[\s:]*((?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s*\d{4})',
          caseSensitive: false),
      RegExp(r'dom[\s:]*(\d{2}[-/]\d{4})', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      var match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return _formatDate(match.group(1)!);
      }
    }

    return "";
  }

  static String _formatDate(String dateStr) {
    Map<String, String> months = {
      'jan': '01',
      'feb': '02',
      'mar': '03',
      'apr': '04',
      'may': '05',
      'jun': '06',
      'jul': '07',
      'aug': '08',
      'sep': '09',
      'oct': '10',
      'nov': '11',
      'dec': '12'
    };

    String lower = dateStr.toLowerCase();
    for (var entry in months.entries) {
      if (lower.contains(entry.key)) {
        var yearMatch = RegExp(r'\d{4}').firstMatch(dateStr);
        if (yearMatch != null) {
          return '${entry.value}/${yearMatch.group(0)}';
        }
      }
    }

    return dateStr;
  }

  static DateTime? parseExtractedDate(String dateStr) {
    if (dateStr.isEmpty) return null;

    try {
      if (RegExp(r'^\d{2}/\d{4}$').hasMatch(dateStr)) {
        var parts = dateStr.split('/');
        int month = int.parse(parts[0]);
        int year = int.parse(parts[1]);
        return DateTime(year, month, 1);
      }

      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(dateStr)) {
        var parts = dateStr.split('/');
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }

      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(dateStr)) {
        var parts = dateStr.split('-');
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print("Error parsing date: $e");
    }

    return null;
  }
}
