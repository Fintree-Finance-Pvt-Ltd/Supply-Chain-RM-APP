import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/routes/app_route.dart';

class SessionCheckScreen extends StatefulWidget {
  const SessionCheckScreen({super.key});

  @override
  State<SessionCheckScreen> createState() => _SessionCheckScreenState();
}

class _SessionCheckScreenState extends State<SessionCheckScreen> {

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");
    final role = prefs.getString("role");
    final isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

    print("TOKEN: $token");
    print("ROLE: $role");
    print("LOGIN: $isLoggedIn");

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (token != null && role != null && isLoggedIn) {
      String r = role.toLowerCase();

      if (r == "ceo") {
        Navigator.pushReplacementNamed(context, AppRoutes.ceo);
      } else if (r == "md") {
        Navigator.pushReplacementNamed(context, AppRoutes.md);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.rm);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}