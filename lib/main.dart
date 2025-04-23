// main.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sales_dial/helpers/dio_client.dart';
import 'package:sales_dial/screens/login_screen.dart';
import 'package:sales_dial/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final erpUrl = prefs.getString('url');
    DioClient? dioClient = await DioClient.create();
    
    if (username != null && erpUrl != null) {
      try {
        
        final response = await dioClient.get(
          '$erpUrl/api/method/frappe.auth.get_logged_user'
        );

        if (response.statusCode == 200 && response.data != null) {
          return const HomeScreen(); // User is logged in, navigate to HomeScreen
        }
      } catch (e) {
        print('Error checking login status: $e');
      }
    }

    return const LoginScreen(); // User is not logged in, navigate to LoginScreen
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()), // Show loader while checking
            ),
          );
        } else {
          return MaterialApp(
            title: 'Sales Dial',
            theme: ThemeData(
              useMaterial3: true,
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: snapshot.data, // Navigate to the appropriate screen
          );
        }
      },
    );
  }
}
