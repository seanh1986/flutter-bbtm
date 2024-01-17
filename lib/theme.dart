import 'package:flutter/material.dart';

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
          displayColor: isDarkTheme ? Colors.white : Colors.black,
        ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(
          isDarkTheme ? Colors.blue : Colors.lightBlue),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black, fontSize: 22),
      iconColor: isDarkTheme ? Colors.grey : Colors.grey,
      tileColor: isDarkTheme ? Colors.black : Colors.white,
      textColor: isDarkTheme ? Colors.white : Colors.black,
    ),
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
            backgroundColor: isDarkTheme ? Colors.blue : Colors.lightBlue,
            textStyle:
                TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ))),
  );
}
