import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {
  static void showSuccess(FToast fToast, String msg) {
    return show(fToast, msg,
        backgroundColor: Colors.greenAccent, icon: Icon(Icons.check));
  }

  static void showFailed(FToast fToast, String msg) {
    return show(fToast, msg,
        backgroundColor: Colors.redAccent, icon: Icon(Icons.close));
  }

  static void show(FToast fToast, String msg,
      {Color backgroundColor = Colors.white, Icon? icon}) {
    final theme = Theme.of(fToast.context!);

    List<Widget> widgets = [];
    if (icon != null) {
      widgets.add(icon);
      widgets.add(SizedBox(width: 12.0));
    }
    widgets.add(Text(msg, style: theme.textTheme.displayMedium));

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

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }
}
