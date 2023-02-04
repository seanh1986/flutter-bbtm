import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CustomTextFormField extends StatelessWidget {
  final String? initialValue;
  final String title;
  final ValueChanged<String> callback;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  CustomTextFormField({
    Key? key,
    required this.title,
    required this.callback,
    this.initialValue,
    this.inputFormatters,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          initialValue: initialValue,
          onChanged: callback,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(labelText: title),
//        decoration: InputDecoration(hintText: hintText),
        ));
  }
}

// class CustomDateFormField extends StatelessWidget {
//   final DateRangePickerSelectionChangedCallback callback;
//   final PickerDateRange? initialValue;

//   CustomDateFormField({
//     Key? key,
//     this.initialValue,
//     required this.callback,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SfDateRangePicker(
//         initialSelectedRange: initialValue,
//         selectionMode: DateRangePickerSelectionMode.range,
//         onSelectionChanged: callback,
//       ),
//     );
//   }
// }
