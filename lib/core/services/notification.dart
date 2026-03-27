// import 'dart:convert';
// import 'package:workmanager/workmanager.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;

// final FlutterLocalNotificationsPlugin notifications =
//     FlutterLocalNotificationsPlugin();

// Future<void> showNotification(int count) async {

//   const AndroidNotificationDetails androidDetails =
//       AndroidNotificationDetails(
//     'cases_channel',
//     'Cases Notification',
//     importance: Importance.max,
//     priority: Priority.high,
//   );

//   const NotificationDetails details =
//       NotificationDetails(android: androidDetails);

//   await notifications.show(
//     0,
//     "Credit L2 Approved",
//     "$count new cases ready for review",
//     details,
//   );
// }

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {

//     try {

//       final response = await http.get(
//         Uri.parse("https://supplychain-prod.fintreelms.com/api/customers"),
//       );

//       final data = jsonDecode(response.body);

//       if (data["success"] == true) {

//         List customers = data["data"];

//         final creditL2Cases =
//             customers.where((c) => c["status"] == "credit_l2_approved").toList();

//         int count = creditL2Cases.length;

//         if (count > 0) {
//           await showNotification(count);
//         }
//       }

//     } catch (e) {
//       print("Background error: $e");
//     }

//     return Future.value(true);
//   });
// }

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {

    print("Workmanager task triggered");

    final FlutterLocalNotificationsPlugin notifications =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await notifications.initialize(settings: settings);

    try {

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final rmId = prefs.getInt("rmId");

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/customers?status=md_approved"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {

        List customers = data["data"];

        final mdApprovedCases = customers.where((c) {
          return c["status"] == "md_approved" &&
                 c["rmId"]?.toString() == rmId.toString();
        }).toList();

        int count = mdApprovedCases.length;

        if (count > 0) {

          const AndroidNotificationDetails androidDetails =
              AndroidNotificationDetails(
            'cases_channel',
            'Cases Notification',
            importance: Importance.max,
            priority: Priority.high,
          );

          const NotificationDetails details =
              NotificationDetails(android: androidDetails);

          await notifications.show(
            id: 0,
            title: "MD Approved Cases",
            body: "$count new cases ready for review",
            notificationDetails: details,
          );
        }
      }

    } catch (e) {
      print("Background error: $e");
    }

    return Future.value(true);
  });
}