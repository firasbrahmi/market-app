import 'package:flutter/material.dart';

import 'constants.dart';

class AppTheme {
  static ThemeData darktTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: Color.fromARGB(15, 16, 20, 0),
      appBarTheme: AppBarTheme(
        color: Color.fromARGB(255, 15, 16, 20),
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white),
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodyText1: TextStyle(color: Colors.white70),
        bodyText2: TextStyle(color: Colors.white),
        headline6: TextStyle(color: Colors.indigo), // Used for titles
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
        enabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        border: outlineInputBorder,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      // Add other theme customizations here
    );
  }
}

const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(28)),
  borderSide: BorderSide(color: Colors.white70),
  gapPadding: 10,           
);
