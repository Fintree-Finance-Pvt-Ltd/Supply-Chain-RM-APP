import 'package:flutter/material.dart';
import 'package:supply_chain/presentation/auth/login_screen.dart';
import 'package:supply_chain/presentation/role/ceo/dashboard_screen.dart';
import 'package:supply_chain/presentation/role/md/dashboard_screen.dart';
import 'package:supply_chain/presentation/role/rm/dashboard_screen.dart';


class AppRoutes {

  static const login = "/login";
  static const rm = "/rm";
  static const md = "/md";
  static const ceo = "/ceo";


  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        rm: (context) => const RmDashboard(),
        md: (context) => const MdDashboard(),
        ceo: (context) => const CeoDashboard(),
      };
}
