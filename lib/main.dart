

// import 'package:flutter/foundation.dart';
// import "package:flutter/material.dart";
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:provider/provider.dart';
// import "package:supply_chain/core/routes/app_route.dart";
// import 'package:supply_chain/core/theme/theme_provider.dart';
// import 'package:supply_chain/presentation/auth/session_screen.dart';
// import 'package:workmanager/workmanager.dart';
// import 'core/services/notification.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//  final FlutterLocalNotificationsPlugin notifications =
//       FlutterLocalNotificationsPlugin();
//   /// Initialize Local Notifications
//   const AndroidInitializationSettings androidSettings =
//       AndroidInitializationSettings('@mipmap/ic_launcher');

//   const InitializationSettings settings =
//       InitializationSettings(android: androidSettings);

//   // await notifications.initialize(settings);
//   await notifications.initialize(settings: settings);

//   /// Initialize Workmanager
//   if (!kIsWeb) {
//     await Workmanager().initialize(
//       callbackDispatcher,
//     );

//     /// Register task
//     await Workmanager().registerPeriodicTask(
//       "checkCases",
//       "fetchCasesTask",
//       frequency: const Duration(minutes: 15),
//     );
//   }
// runApp(
//   ChangeNotifierProvider(
//     create: (_) => ThemeProvider(),
//     child: const SupplyChain(),
//   ),
// );
//   // runApp(const SupplyChain());
   
// }


// class SupplyChain extends StatelessWidget {
//   const SupplyChain({super.key});

//   @override
//   Widget build(BuildContext context) {
  

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
      
//       home: const SessionCheckScreen(), // ✅ IMPORTANT
//       routes: AppRoutes.routes,
//     );
//   }
// }
import "package:flutter/material.dart";
import "package:supply_chain/core/routes/app_route.dart";
import "package:supply_chain/presentation/auth/session_screen.dart";


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 

  runApp(const supplychain());
}
class supplychain extends StatelessWidget {
  const supplychain({super.key});


  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SessionCheckScreen(), 
      routes: AppRoutes.routes,
    );
  }
 
}


// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:supply_chain/core/routes/app_route.dart';
// import 'package:supply_chain/presentation/auth/session_screen.dart';
// import 'package:supply_chain/core/services/notification_service.dart'; // 🔥 ADD THIS

// ///  Background handler (must be top-level)
// Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("📩 Background message: ${message.notification?.title}");
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   /// ✅ Initialize Firebase
//   await Firebase.initializeApp();

//   /// ✅ Background handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

//   ///  INIT NOTIFICATION SERVICE (VERY IMPORTANT)
//   await NotificationService.initialize();

//   runApp(const SupplyChain());
// }

// class SupplyChain extends StatelessWidget {
//   const SupplyChain({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,

//       ///  REQUIRED FOR NOTIFICATION CLICK NAVIGATION
//       navigatorKey: NotificationService.navigatorKey,

//       home: const SessionCheckScreen(),
//       routes: AppRoutes.routes,
//     );
//   }
// }