import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF573174); // Deep Violet
const Color kSecondaryColor = Color(0xFFFFB703); // Amber/Gold

final ThemeData salesDialTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimaryColor,
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: kPrimaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kSecondaryColor,
    foregroundColor: Colors.black,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  tabBarTheme: const TabBarTheme(
    labelColor: kSecondaryColor,
    unselectedLabelColor: Colors.white,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(width: 2.5, color: kSecondaryColor),
    ),
    labelStyle: TextStyle(fontWeight: FontWeight.bold),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: kPrimaryColor),
    ),
  ),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(fontWeight: FontWeight.bold),
  ),
);
