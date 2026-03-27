// import 'package:flutter/foundation.dart';
// import "package:flutter/material.dart";
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import "package:supply_chain/core/routes/app_route.dart";
// import 'package:workmanager/workmanager.dart';
// // import 'services/notification.dart';
// import 'core/services/notification.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();


//   /// Initialize Local Notifications
// const AndroidInitializationSettings androidSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');

// const InitializationSettings settings =
//     InitializationSettings(android: androidSettings);

// await notifications.initialize(
//   settings: settings,
// );

//   /// 2️⃣ Initialize Workmanager
//     if (!kIsWeb) {
//     Workmanager().initialize(
//       callbackDispatcher,
//     );

//      Workmanager().registerPeriodicTask(
//       "checkCases",
//       "fetchCasesTask",
//       frequency: const Duration(minutes: 15),
//     );
//   }

//   runApp(const supplychain());
// }
// class supplychain extends StatelessWidget {
//   const supplychain({super.key});


//   @override
//   Widget build(BuildContext context) {
//      return MaterialApp(
//       debugShowCheckedModeBanner: false,
//   initialRoute: AppRoutes.login,
//   routes: AppRoutes.routes, 
    
//     );
//   }
// }


import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import "package:supply_chain/core/routes/app_route.dart";
import 'package:supply_chain/core/theme/theme_provider.dart';
import 'package:supply_chain/presentation/auth/session_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'core/services/notification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

 final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();
  /// Initialize Local Notifications
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings =
      InitializationSettings(android: androidSettings);

  // await notifications.initialize(settings);
  await notifications.initialize(settings: settings);

  /// Initialize Workmanager
  if (!kIsWeb) {
    await Workmanager().initialize(
      callbackDispatcher,
    );

    /// Register task
    await Workmanager().registerPeriodicTask(
      "checkCases",
      "fetchCasesTask",
      frequency: const Duration(minutes: 15),
    );
  }
runApp(
  ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: const SupplyChain(),
  ),
);
  // runApp(const SupplyChain());
   
}

// class SupplyChain extends StatelessWidget {
//   const SupplyChain({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       initialRoute: AppRoutes.login,
//       routes: AppRoutes.routes,
//     );
//   }
// }
class SupplyChain extends StatelessWidget {
  const SupplyChain({super.key});

  @override
  Widget build(BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      home: const SessionCheckScreen(), // ✅ IMPORTANT
      routes: AppRoutes.routes,
    );
  }
}

// class SupplyChain extends StatelessWidget {
//   final String? token;
//   final String? role;

//   const SupplyChain({super.key, this.token, this.role});

//   @override
//   Widget build(BuildContext context) {

//     String startRoute = AppRoutes.login;

//     if (token != null) {

//       if (role == "rm") {
//         startRoute = AppRoutes.rm;
//       } 
//       else if (role == "ceo") {
//         startRoute = AppRoutes.ceo;
//       } 
//       // else if (role == "CREDIT") {
//       //   startRoute = AppRoutes.creditDashboard;
//       // } 
//       // else if (role == "ADMIN") {
//       //   startRoute = AppRoutes.adminDashboard;
//       // }

//     }

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       initialRoute: startRoute,
//       routes: AppRoutes.routes,
//     );
//   }
// }