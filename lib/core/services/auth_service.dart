// class AuthService {

//   final Map<String, Map<String, String>> users = {
//     "ceo@company.com": {
//       "password": "1234",
//       "role": "CEO",
//     },
//     "md@company.com": {
//       "password": "1234",
//       "role": "MD",
//     },
//     "rm@company.com": {
//       "password": "1234",
//       "role": "RM",
//     },
//   };

//   Future<String?> login(String email, String password) async {

//     if (users.containsKey(email)) {
//       if (users[email]!["password"] == password) {
//       return users[email]!["role"]!.toLowerCase();
//       }
//     }

//     return null; // invalid
//   }

// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';

class AuthService {
  /// 🔐 LOGIN
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.login);

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      final responseData = jsonDecode(response.body);
      print("Full Response: ${response.body}");

      if (response.statusCode == 200 && responseData["success"] == true) {
        final data = responseData["data"];

        print("Token from backend: ${data["token"]}");

        // Save token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        print("Stored token: ${prefs.getString("token")}");

        // await prefs.setString("role", data["user"]["role"]);
        await prefs.setString(
          "role",
          data["user"]["role"].toLowerCase(), // 🔥 FIX
        );
        print("Login success");
        print("User role: ${data["user"]["role"]}");
        await prefs.setBool("isLoggedIn", true);
        await prefs.setInt("rmId", data["user"]["id"]);
  await prefs.setString("rmName", data["user"]["name"]);

        print("Stored RM ID: ${prefs.getInt("rmId")}");
        return data;
      } else {
        throw Exception(responseData["message"] ?? "Login failed");
      }
    } catch (e) {
      print("Login error: $e");
      rethrow;
    }
  }

  /// 🚪 LOGOUT
  Future<bool> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.logout);

      /// 🔐 Call API only if token exists
      if (token != null) {
        await http.post(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
      }

      /// 🧹 Clear local storage
      await prefs.clear();

      /// 🚀 Navigate to login (REMOVE ALL SCREENS)
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);

      return true;
    } catch (e) {
      print("Logout error: $e");

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      /// 🚀 Still redirect to login
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);

      return true;
    }
  }

  /// 🔎 Get Saved Role
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  /// 🔑 Get Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }
}
