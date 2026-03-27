import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
 import 'package:file_picker/file_picker.dart';
/// ===============================
/// PAN OCR RESULT MODEL
/// ===============================
class PanOcrResult {
  final String? panNumber;
  final String? name;
 
  PanOcrResult({
    this.panNumber,
    this.name,
  });
}
 
/// ===============================
/// PAN OCR SERVICE
/// ===============================
class PanOcrService {
  static const String _endpoint =
      "https://sandbox.fintreelms.com/ocr/v1/pan";
  static const String _apiKey = "Fintree@2026";
 
  /// MAIN OCR METHOD  
  static Future<PanOcrResult?> scanPan(PlatformFile file) async {
  final uri = Uri.parse(_endpoint);
  final request = http.MultipartRequest('POST', uri);

  request.headers.addAll({
    'x-api-key': _apiKey,
    'Accept': 'application/json',
  });

  request.fields['clientRefId'] =
      DateTime.now().millisecondsSinceEpoch.toString();

  // ✅ Web + Mobile Compatible
  if (file.bytes != null) {
    request.files.add(
      http.MultipartFile.fromBytes(
        'imageUrl',
        file.bytes!,
        filename: file.name,
        contentType: MediaType(
          'image',
          _detectImageType(file.name),
        ),
      ),
    );
  } else if (file.path != null) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'imageUrl',
        file.path!,
        contentType: MediaType(
          'image',
          _detectImageType(file.path!),
        ),
      ),
    );
  } else {
    throw Exception("Unable to read PAN file");
  }

  final response = await request.send();
  final body = await response.stream.bytesToString();

  debugPrint("PAN OCR STATUS => ${response.statusCode}");
  debugPrint("PAN OCR RESPONSE => $body");

  if (response.statusCode != 200 &&
      response.statusCode != 201) {
    throw Exception(
      "PAN OCR API failed (${response.statusCode}): $body",
    );
  }

  final decoded = jsonDecode(body);

  if (decoded['success'] != true ||
      decoded['data'] == null) {
    throw Exception("PAN OCR failed: ${decoded['message']}");
  }

  final panData = decoded['data'];

  return PanOcrResult(
    panNumber: panData['pan_number'],
    name: panData['name'],
  );
}
//   static Future<PanOcrResult?> scanPan(XFile image) async {
//     final uri = Uri.parse(_endpoint);
//     final request = http.MultipartRequest('POST', uri);
 
//     /// HEADERS (do NOT set content-type manually)
//     request.headers.addAll({
//       'x-api-key': _apiKey,
//       'Accept': 'application/json',
//     });
 
//     /// OPTIONAL TRACKING ID (allowed by API)
//     request.fields['clientRefId'] =
//         DateTime.now().millisecondsSinceEpoch.toString();
 
//     /// ADD IMAGE FILE (EXACT KEY REQUIRED BY API)
//     if (kIsWeb) {
//       final bytes = await image.readAsBytes();
 
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           'imageUrl', // 🔑 MUST MATCH API
//           bytes,
//           filename: image.name,
//           contentType: MediaType(
//             'image',
//             _detectImageType(image.name),
//           ),
//         ),
//       );
//     } else {
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'imageUrl', // 🔑 MUST MATCH API
//           image.path,
//           contentType: MediaType(
//             'image',
//             _detectImageType(image.path),
//           ),
//         ),
//       );
//     }
 
//     /// SEND REQUEST
//     final response = await request.send();
//     final body = await response.stream.bytesToString();
 
//     debugPrint("PAN OCR STATUS => ${response.statusCode}");
//     debugPrint("PAN OCR RESPONSE => $body");
 
//     /// HANDLE ERROR
//     if (response.statusCode != 200 && response.statusCode != 201) {
//       throw Exception(
//         "PAN OCR API failed (${response.statusCode}): $body",
//       );
//     }
 
//     /// PARSE RESPONSE
//     final decoded = jsonDecode(body);
 
 
 
// if (decoded['success'] != true || decoded['data'] == null) {
//   throw Exception("PAN OCR failed: ${decoded['message']}");
// }
 
// final panData = decoded['data'];
 
// return PanOcrResult(
//   panNumber: panData['pan_number'],
//   name: panData['name'],
// );
 
   
//   }
 
  /// ===============================
  /// IMAGE TYPE DETECTOR
  /// ===============================
  static String _detectImageType(String path) {
    final lower = path.toLowerCase();
 
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    return 'jpeg'; // default for jpg / jpeg
  }
}
 