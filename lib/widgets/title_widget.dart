import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  final String title;
  // final String? subTitle;

  TitleBar({
    Key? key,
    required this.title,
    // this.subTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return //Column(children: [
        Row(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8.0),
            bottomRight: Radius.circular(8.0),
          ),
          child: Container(
            width: 10.0,
            height: 50.0,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).primaryColor,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
    //])
  }
}
