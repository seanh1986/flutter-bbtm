import 'dart:math';

import 'package:bbnaf/utils/save_as/save_as.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

class ScreenshotUtil {
  ScreenshotController _screenshotController = ScreenshotController();

  Future<void> capture(
      BuildContext context,
      String headerTitle,
      String headerSubTitle,
      Widget mainWidget,
      String? footer,
      String fileName) {
    final theme = Theme.of(context);

    List<Widget> headingWidgets = [
      Text(headerTitle, style: theme.textTheme.displaySmall),
      SizedBox(height: 10),
      Text(headerSubTitle, style: theme.textTheme.displaySmall),
    ];

    Color? backgroundColor = theme.appBarTheme.backgroundColor;

    Widget headerCard =
        Card(child: Column(children: headingWidgets), color: backgroundColor);

    List<Widget> childrenWidgets = [
      headerCard,
      mainWidget,
    ];

    if (footer != null) {
      Widget footerCard = Card(
          child: Text(footer, style: theme.textTheme.bodySmall),
          color: backgroundColor);

      childrenWidgets.add(footerCard);
    }

    Widget widget = Column(
      children: childrenWidgets,
      mainAxisAlignment: MainAxisAlignment.center,
    );

    double pixelRatio = max(MediaQuery.of(context).devicePixelRatio, 1.5);

    return _screenshotController
        .captureFromWidget(
            // InheritedTheme.captureAll(
            //   context,
            //   widget,
            // ),
            widget,
            delay: Duration(milliseconds: 100),
            pixelRatio: pixelRatio,
            context: context

            /// Additionally you can define constraint for your image.
            ///
            // targetSize: Size(1000, 1000)
            )
        .then((capturedImage) {
      // Handle captured image
      saveAsBytes(capturedImage, fileName);
    }).onError((error, stackTrace) {
      print(error);
      ToastUtils.show(context, error.toString());
    });

    // return Future.delayed(const Duration(milliseconds: 10), () {

    // });
  }
}
