import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// final lightTheme = ThemeData(
//     brightness: Brightness.light,
//     textTheme: GoogleFonts.openSansTextTheme(),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Colors.purpleAccent,
//       elevation: 4,
//     ),
//     colorScheme: const ColorScheme.light(
//       primary: Colors.blue,
//       secondary: Colors.red,
//       background: Color(0xFFE0F2F1),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blue,
//             textStyle: TextStyle(color: Colors.white),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ))));

// final darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     textTheme: GoogleFonts.openSansTextTheme(),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Colors.deepPurpleAccent,
//       elevation: 4,
//     ),
//     colorScheme: const ColorScheme.dark(
//       primary: Colors.blueGrey,
//       secondary: Colors.white,
//       background: Colors.black,
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blueGrey,
//             textStyle: TextStyle(color: Colors.black),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ))));

ThemeData getAppTheme(BuildContext context, bool isDarkTheme) {
  return ThemeData(
    brightness: isDarkTheme ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: isDarkTheme ? Colors.black : Colors.white,
    textTheme: Theme.of(context)
        .textTheme
        .copyWith(
          titleSmall:
              Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 11),
        )
        .apply(
          bodyColor: isDarkTheme ? Colors.white : Colors.black,
          displayColor: Colors.grey,
        ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(
          isDarkTheme ? Colors.orange : Colors.purple),
    ),
    listTileTheme: ListTileThemeData(
        iconColor: isDarkTheme ? Colors.orange : Colors.purple),
    appBarTheme: AppBarTheme(
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        iconTheme:
            IconThemeData(color: isDarkTheme ? Colors.white : Colors.black54)),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: isDarkTheme ? Colors.orange : Colors.purple,
            textStyle:
                TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ))),
  );
}
