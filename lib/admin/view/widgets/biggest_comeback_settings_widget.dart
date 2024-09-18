// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class BiggestComebackSettingWidget extends StatefulWidget {
  late int showBiggestComebackFromRoundNum;
  late bool showBiggestComebackInRankings;
  final TextEditingController _textController = TextEditingController();

  BiggestComebackSettingWidget(this.showBiggestComebackFromRoundNum) {
    this.showBiggestComebackFromRoundNum = showBiggestComebackFromRoundNum;
    this.showBiggestComebackInRankings = showBiggestComebackFromRoundNum > 0;
    _textController.text = showBiggestComebackFromRoundNum.toString();
  }

  @override
  _BiggestComebackSettingWidget createState() =>
      _BiggestComebackSettingWidget();
}

class _BiggestComebackSettingWidget
    extends State<BiggestComebackSettingWidget> {
  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      Text("Show Biggest Comeback in Rankings"),
      Checkbox(
        value: widget.showBiggestComebackInRankings,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              widget.showBiggestComebackInRankings = value;
              if (widget.showBiggestComebackFromRoundNum <= 0) {
                widget.showBiggestComebackFromRoundNum = 2;
              }
            });
          }
        },
      ),
    ];

    // Conditionally show the TextFormField
    if (widget.showBiggestComebackInRankings) {
      widgets.add(
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: TextFormField(
              controller: widget._textController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Biggest Comeback Since Round #',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final int? numValue = int.tryParse(value);
                if (numValue != null && numValue >= 0) {
                  setState(() {
                    widget.showBiggestComebackFromRoundNum = numValue;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a round number';
                }
                final numValue = int.tryParse(value);
                if (numValue == null || numValue <= 0) {
                  return 'Please enter a number greater than 0';
                }
                return null; // Input is valid
              },
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    );
  }
}
