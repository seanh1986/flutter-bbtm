import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CustomTextFormField extends StatelessWidget {
  final String? initialValue;
  final String title;
  final ValueChanged<String> callback;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextStyle? textStyle;

  CustomTextFormField(
      {Key? key,
      required this.title,
      required this.callback,
      this.initialValue,
      this.inputFormatters,
      this.validator,
      this.keyboardType,
      this.textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          initialValue: initialValue,
          onChanged: callback,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(labelText: title),
          style: textStyle,
//        decoration: InputDecoration(hintText: hintText),
        ));
  }
}

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField(
      {Widget? title,
      FormFieldSetter<bool>? onSaved,
      FormFieldValidator<bool>? validator,
      bool initialValue = false,
      bool autovalidate = false})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<bool> state) {
              return CheckboxListTile(
                dense: state.hasError,
                title: title,
                value: state.value,
                onChanged: state.didChange,
                subtitle: state.hasError && state.errorText != null
                    ? Builder(
                        builder: (BuildContext context) => Text(
                          state.errorText!,
                          style: TextStyle(color: Theme.of(context).errorColor),
                        ),
                      )
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              );
            });
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
