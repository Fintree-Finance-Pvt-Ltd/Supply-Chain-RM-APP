import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
 
/// ===============================
/// CHEQUE OCR RESULT MODEL
/// ===============================
class ChequeOcrResult {
  final String? accountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? branch;
  final String? name;

  ChequeOcrResult({
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.branch,
    this.name,
  });
}
 
/// ===============================
/// CHEQUE OCR SERVICE
/// ===============================
class ChequeOcrService {
 
  static const String _endpoint =
      "https://sandbox.fintreelms.com/ocr/v1/cheque";
 
  static const String _apiKey = "Fintree@2026";
 
  /// MAIN OCR METHOD
  static Future<ChequeOcrResult?> scanCheque(
    PlatformFile file, {
    String accountHolderName = "NA",
    bool isCompleteImage = true,
  }) async {
 
    final uri = Uri.parse(_endpoint);
    final request = http.MultipartRequest('POST', uri);
 
    /// HEADERS
    request.headers.addAll({
      'x-api-key': _apiKey,
      'Accept': 'application/json',
    });
 
    /// REQUIRED FIELDS
    request.fields['clientRefId'] =
        DateTime.now().millisecondsSinceEpoch.toString();
 
    request.fields['accountHolderName'] = accountHolderName;
 
    // request.fields['isCompleteImage'] =
    //     isCompleteImage ? "yes" : "no";
 
    /// ===============================
    /// IMAGE FILE
    /// ===============================
 
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
    }
    else if (file.path != null) {
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
    }
    else {
      throw Exception("Unable to read cheque image");
    }
 
    /// ===============================
    /// SEND REQUEST
    /// ===============================
 
    final response = await request.send();
    final body = await response.stream.bytesToString();
 
    debugPrint("CHEQUE OCR STATUS => ${response.statusCode}");
    debugPrint("CHEQUE OCR RESPONSE => $body");
 
    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        "Cheque OCR API failed (${response.statusCode}) : $body",
      );
    }
 
    final decoded = jsonDecode(body);
 
    if (decoded['success'] != true ||
        decoded['data'] == null) {
      throw Exception(
        decoded['message'] ?? "Cheque OCR failed",
      );
    }
 
final result = decoded['data']['result'][0]['details'];
 
return ChequeOcrResult(
  accountNumber: result['account_number']?['value'],
  ifscCode: result['ifsc_code']?['value'],
  bankName: result['bank_name']?['value'],
  name:result['name']?['value'],
  branch: "", // cheque OCR doesn't return branch
);
  }
 
  /// ===============================
  /// IMAGE TYPE DETECTOR
  /// ===============================
  static String _detectImageType(String path) {
    final lower = path.toLowerCase();
 
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    return 'jpeg';
  }
}
 