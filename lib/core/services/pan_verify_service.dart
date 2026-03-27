// import 'dart:convert';
// import 'package:http/http.dart' as http;
 
// class PanVerifyService {
//   static const String _endpoint = "https://sandbox.fintreelms.com/pan/verify";
//   static const String _apiKey = "Fintree@2026";
 
//  static Future<Map<String, dynamic>> verifyPan({
//   required String panNumber,
//   required String name,
// }) async {
//   final uri = Uri.parse(_endpoint);
 
//   final response = await http.post(
//     uri,
//     headers: {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       'x-api-key': _apiKey,
//     },
//     body: jsonEncode({
//       "panNumber": panNumber,
//       "name": name,
//       "source": "flutter",
//     }),
//   );
 
//   if (response.statusCode != 200 && response.statusCode != 201) {
//     throw "PAN Verify failed (${response.statusCode})";
//   }
 
//   final decoded = jsonDecode(response.body);
 
//   //  API failure
//   if (decoded['success'] != true) {
//     throw decoded['message'] ?? "PAN verification failed";
//   }
 
//   //  Always return data safely
//   return {
//     "verified": decoded['data']?['verified'] ?? false,
//     "message": decoded['data']?['message'] ?? decoded['message'],
//     "provider": decoded['data']?['provider'],
//     "mobile": decoded['data']?['mobile'],
//     "email": decoded['data']?['email'],
//   };
// }
// }
 

 import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
 
 
 
class PanVerifyService {
  static Future<Map<String, dynamic>> verifyPan({
    required int customerId,
    required String pan,
    required String name,
    required String ownerType,
    int? applicantId,
    int? coApplicantId,
  }) async {
    final token = await AuthService().getToken();
 
    final url = ApiEndpoints.baseUrl + ApiEndpoints.verifyPan;
 
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "customerId": customerId,
        "pan": pan,
        "name": name,
        "ownerType": ownerType,
        "applicantId": ?applicantId,
        "coApplicantId": ?coApplicantId,
      }),
    );
 
    // 🔐 SAFETY
    if (response.body.isEmpty) {
      throw "PAN verification failed (empty response from server)";
    }
 
    final decoded = jsonDecode(response.body);
 
    if (response.statusCode != 200 || decoded["success"] != true) {
      throw decoded["message"] ?? "PAN verification failed";
    }
 
    return decoded["data"];
  }
}
 