import 'package:flutter/material.dart';

class Common {
  // Private constructor to prevent instantiation
  Common._();

  // TextField builder method
  static Widget buildTextField(
      {required TextEditingController controller,
      required String label,
      IconData? icon,
      int maxLines = 1,
      bool obscureText = false,
      bool autofocus = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      autofocus: autofocus,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon) : null,
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // You can add more utility functions here
  static Widget buildButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
      ),
      child: Text(text),
    );
  }

  // Example of another utility function
  static void showCustomSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

// Add more utility functions as needed
}
