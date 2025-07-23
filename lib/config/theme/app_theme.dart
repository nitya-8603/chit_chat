import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Colors.blue;
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: const Color.fromARGB(255, 16, 12, 12),
      surface: Colors.white,
      onSurface: Colors.black,
      tertiary: Colors.amberAccent,
      onPrimary: Colors.black12,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: primaryColor.withOpacity(0.1),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: primaryColor),
      ),
      hintStyle: TextStyle(color: Colors.grey),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 7, 7, 7),
      ),
    ),

    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: const Color.fromARGB(31, 4, 4, 4),
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: TextStyle(color: Colors.black26, fontSize: 14),
      labelMedium: TextStyle(
        color: const Color.fromARGB(255, 21, 15, 15),
        fontSize: 12,
      ),
    ),

    cardTheme: CardThemeData(
      color: primaryColor.withOpacity(0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    iconTheme: IconThemeData(color: Colors.black, size: 24),
  );
}
