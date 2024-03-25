import 'package:flutter/material.dart';

class AddMinusItem {
  String name;
  int value;
  Color? color;
  bool showFab;
  bool editable;

  AddMinusItem(
      {required this.name,
      required this.value,
      this.color,
      this.showFab = true,
      this.editable = true});
}
