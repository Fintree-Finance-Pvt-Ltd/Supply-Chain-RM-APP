// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
 
// class AadhaarKycService {
//   static const String _endpoint = "https://sandbox.fintreelms.com/aadhaar/generate-Kyc-Link";
//   static const String _apiKey = "Fintree@2026";
 
//   static Future<String> generateKycLink({
//     required String firstName,
//     required String lastName,
//     required String uid,
//     required String mobile,
//     required String email,
//     required String redirectUrl,
//   }) async {
//     final uri = Uri.parse(_endpoint);
 
//     final response = await http.post(
//       uri,
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'x-api-key': _apiKey,
//       },
//       body: jsonEncode({
//         "firstName": firstName,
//         "lastName": lastName,
//         "uid": uid,
//         "mobile": mobile,
//         "emailId": email,
//         "redirectionUrl": redirectUrl,
//       }),
//     );
 
//     debugPrint("AADHAAR KYC STATUS => ${response.statusCode}");
//     debugPrint("AADHAAR KYC RESPONSE => ${response.body}");
 
//     if (response.statusCode != 200 && response.statusCode != 201) {
//       throw "Aadhaar KYC failed (${response.statusCode})";
//     }
 
//     final decoded = jsonDecode(response.body);
 
//     if (decoded['success'] != true) {
//       throw decoded['message'] ?? "Aadhaar KYC failed";
//     }
 
//     // 🔑 backend usually returns link like this
//     final kycLink =
//         decoded['data']?['kycLink'] ??
//         decoded['data']?['url'];
 
//     if (kycLink == null) {
//       throw "KYC link not received";
//     }
 
//     return kycLink;
//   }
// }
 

 import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
 
class AadhaarKycService {
 
  // ---------------------------------------------------
  // 🔍 VERIFY / INITIATE AADHAAR KYC
  // ---------------------------------------------------
  static Future<Map<String, dynamic>> verifyAadhaar({
    required int customerId,
    required String ownerType, // APPLICANT | CO_APPLICANT | COMPANY
    int? applicantId,
    int? coApplicantId,
  }) async {
    final token = await AuthService().getToken();
 
    final response = await http.post(
      Uri.parse(
        ApiEndpoints.baseUrl + ApiEndpoints.aadharkyc,
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "customerId": customerId,
        "ownerType": ownerType,
        "applicantId": ?applicantId,
        "coApplicantId": ?coApplicantId,
      }),
    );
 
    final decoded = jsonDecode(response.body);
 
    if (response.statusCode != 200 || decoded["success"] != true) {
      throw decoded["message"] ?? "Aadhaar verification failed";
    }
 
    return decoded["data"];
  }
 
  // ---------------------------------------------------
  // 🔄 GET VERIFICATION STATUSES
  // ---------------------------------------------------
static Future<List<dynamic>> getVerificationStatuses(int customerId) async {
  final token = await AuthService().getToken();
 
  final response = await http.get(
    Uri.parse("${ApiEndpoints.baseUrl}/onboarding/kyc/status/$customerId"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );
 
  final decoded = jsonDecode(response.body);
 
  if (response.statusCode != 200) {
    throw decoded["message"] ?? "Failed to fetch verification status";
  }
 
  // 🔥 Normalize response
  if (decoded is List) {
    return decoded;
  }
 
  if (decoded["data"] is List) {
    return decoded["data"];
  }
 
  throw "Unexpected KYC status response format";
}
}
 