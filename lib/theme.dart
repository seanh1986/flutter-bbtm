import 'package:flutter/material.dart';

ThemeData getAppTheme(BuildContext context, bool isDarkTheme) {
  return ThemeData(
    brightness: isDarkTheme ? Brightness.dark : Brightness.light,
    primaryColor: isDarkTheme ? Colors.white : Colors.grey,
    // secondaryHeaderColor: isDarkTheme ? Colors.blue : Colors.lightBlue,
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
      tileColor: isDarkTheme
          ? const Color.fromARGB(255, 106, 101, 101)
          : Color.fromARGB(255, 184, 177, 177),
      textColor: isDarkTheme ? Colors.white : Colors.black,
    ),
    appBarTheme: AppBarTheme(
        backgroundColor: isDarkTheme ? Colors.grey : Colors.white,
        iconTheme:
            IconThemeData(color: isDarkTheme ? Colors.white : Colors.black)),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
      backgroundColor:
          MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) return Colors.red;
        return Colors.blue; // Defer to the widget's default.
      }),
      foregroundColor:
          MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) return Colors.white;
        return Colors.white; // Defer to the widget's default.
      }),
    )

        // style: ElevatedButton.styleFrom(
        //     backgroundColor: isDarkTheme ? Colors.blue : Colors.lightBlue,
        //     textStyle:
        //         TextStyle(color: isDarkTheme ? Colors.white : Colors.white),
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(20),
        //     ))
        ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
      selectedItemColor: Colors.red,
      unselectedItemColor: isDarkTheme ? Colors.grey : Colors.black,
    ),
  );
}
