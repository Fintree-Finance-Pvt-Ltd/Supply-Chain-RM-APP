import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/presentation/role/rm/dashboard_screen.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// 🔥 Global navigator
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// 🔥 CREATE / GET FCM TOKEN (IMPORTANT)
  static Future<String?> generateFcmToken() async {
    try {
      NotificationSettings settings =
          await _messaging.requestPermission();

      print("🔐 Permission: ${settings.authorizationStatus}");

      String? token = await _messaging.getToken();

      print("📲 GENERATED FCM TOKEN: $token");

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("fcm_token", token);
      }

      return token;
    } catch (e) {
      print("❌ Token Error: $e");
      return null;
    }
  }

  /// 🔐 Initialize FCM
  static Future<void> initialize() async {
    /// ✅ Generate token
    await generateFcmToken();

    /// 🔄 TOKEN REFRESH
    _messaging.onTokenRefresh.listen((newToken) async {
      print("🔄 New Token: $newToken");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("fcm_token", newToken);

      final jwt = prefs.getString("token");
      final userId = prefs.getInt("userId");
      final role = prefs.getString("role");

      if (jwt == null || userId == null || role == null) return;

      await http.post(
        Uri.parse("${ApiEndpoints.baseUrl}/notifications/save-fcm-token"),
        headers: {
          "Authorization": "Bearer $jwt",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "id": userId,
          "type": role.toLowerCase() == "customer" ? "customer" : "user",
          "fcmToken": newToken,
        }),
      );
    });

    /// 📩 Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 Foreground: ${message.notification?.title}");
      print("📦 Data: ${message.data}");
    });

    /// 📲 Background click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(" Notification clicked (background)");
      handleNavigation(message);
    });

    /// 📲 Terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print(" Opened from terminated");
      handleNavigation(initialMessage);
    }
  }

  /// 🔥 GET TOKEN ANYTIME
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("fcm_token");
  }

  /// 🚀 NAVIGATION HANDLER
  static void handleNavigation(RemoteMessage message) {
    final referenceId = message.data['referenceId'];

    if (referenceId != null) {
      print("➡️ Open Case ID: $referenceId");

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const RmDashboard(), // replace later
        ),
      );
    }
  }
}