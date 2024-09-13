import 'package:flutter/material.dart';

class AddMinusItem {
  String name;
  int value;
  Color? color;
  bool showFab;
  bool editable;
  int? minValue;
  int? maxValue;

  AddMinusItem(
      {required this.name,
      required this.value,
      this.color,
      this.minValue,
      this.maxValue,
      this.showFab = true,
      this.editable = true});
}
