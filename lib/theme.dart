import 'package:flutter/material.dart';

int idx = 0;

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
        thumbColor: WidgetStateProperty.all(
            isDarkTheme ? Colors.blue : Colors.lightBlue),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: TextStyle(
            color: isDarkTheme ? Colors.white : Colors.black, fontSize: 22),
        iconColor: isDarkTheme ? Colors.grey : Colors.grey,
        tileColor: isDarkTheme
            ? const Color.fromARGB(255, 106, 101, 101)
            : Colors.grey,
        selectedTileColor: isDarkTheme
            ? Colors.black
            : const Color.fromARGB(255, 106, 101, 101),
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
            WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) return Colors.red;
          return Colors.blue; // Defer to the widget's default.
        }),
        foregroundColor:
            WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) return Colors.white;
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
      dataTableTheme: DataTableThemeData(headingRowColor:
          WidgetStateColor.resolveWith((states) {
        return isDarkTheme ? Colors.grey[850]! : Colors.grey;
      }), dataRowColor:
          WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if ((idx++)
            .isEven) //Change Color if Row is Even, this is for Stripped Table
          return isDarkTheme ? Colors.grey[600]! : Colors.grey;
        else
          return isDarkTheme ? Colors.grey : Colors.grey[600]!;
      })));
}
