import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {
  static void showSuccess(BuildContext context, String msg) {
    return show(context, msg,
        backgroundColor: Colors.greenAccent,
        textColor: Colors.black,
        icon: Icon(Icons.check, color: Colors.black));
  }

  static void showFailed(BuildContext context, String msg) {
    return show(context, msg,
        backgroundColor: Colors.redAccent,
        textColor: Colors.black,
        icon: Icon(Icons.close, color: Colors.black));
  }

  static void show(BuildContext context, String msg,
      {Color backgroundColor = Colors.white,
      Color textColor = Colors.black,
      Icon? icon}) {
    List<Widget> widgets = [];
    if (icon != null) {
      widgets.add(icon);
      widgets.add(SizedBox(width: 12.0));
    }
    widgets.add(Text(msg, style: TextStyle(color: textColor)));

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widgets,
      ),
    );

    FToast().init(context).showToast(
          child: toast,
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: 2),
        );
  }
}
