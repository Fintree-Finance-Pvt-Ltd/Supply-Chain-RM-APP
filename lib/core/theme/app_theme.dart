import 'package:flutter/material.dart';
import 'app_colors.dart';
 
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
 
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
  ),
),
 
    //  MATERIAL 3 FIX
    cardTheme: CardThemeData(
      color: const Color.fromARGB(255, 244, 242, 242),
      elevation:3,
      shape: RoundedRectangleBorder(
       
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
 
 