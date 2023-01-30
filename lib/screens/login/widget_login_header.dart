import 'package:bbnaf/utils/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginScreenHeader extends StatelessWidget {
  LoginScreenHeader({this.showBackButton = false, this.subTitle = ""});

  final bool showBackButton;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: <Widget>[
        _getBackButton(context),
        Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: BorderedText(
              strokeWidth: 2.0,
              strokeColor: Colors.white,
              child: Text('Bloodbowl Tournament Manager',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 40)),
            )),
        _getSubTitle(context),
      ],
    ));
  }

  Widget _getBackButton(BuildContext context) {
    if (!showBackButton) {
      return Center();
    }

    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.all(10),
      child: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          // Navigator.pop(context);
          // Navigator.of(context).pop();
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
    );
  }

  Widget _getSubTitle(BuildContext context) {
    if (subTitle.isEmpty) {
      return Center();
    }

    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: BorderedText(
          strokeWidth: 2.0,
          strokeColor: Colors.white,
          child: Text(subTitle,
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                  fontSize: 20)),
        ));
  }
}
