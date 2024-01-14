import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final theme = ThemeData(
  textTheme: GoogleFonts.openSansTextTheme(),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 130, 113, 243),
    elevation: 4,
  ),
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 0, 11, 167),
    secondary: Color.fromARGB(255, 115, 150, 0),
    background: Color(0xFFE0F2F1),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
);
