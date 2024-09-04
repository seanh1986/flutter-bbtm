// ignore_for_file: must_be_immutable

import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class TournyBasicInfoWidget extends StatefulWidget {
  late String name;
  late String location;
  late DateTime? startDate;
  late DateTime? endDate;

  TournyBasicInfoWidget({Key? key, required TournamentInfo info})
      : super(key: key) {
    this.name = info.name;
    this.location = info.location;
    this.startDate = info.dateTimeStart;
    this.endDate = info.dateTimeEnd;
  }

  @override
  State<TournyBasicInfoWidget> createState() {
    return _TournyBasicInfoWidget();
  }

  void updateTournamentInfo(TournamentInfo info) {
    info.name = name;
    info.location = location;

    if (startDate != null) {
      info.dateTimeStart = startDate!;
    }
    if (endDate != null) {
      info.dateTimeEnd = endDate!;
    } else if (startDate != null) {
      info.dateTimeEnd = startDate!;
    }
  }
}

class _TournyBasicInfoWidget extends State<TournyBasicInfoWidget> {
  bool editDates = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CustomTextFormField(
        initialValue: widget.name,
        title: 'Tournament Name',
        callback: (value) {
          widget.name = value;
        },
      ),
      CustomTextFormField(
        initialValue: widget.location,
        title: 'Tournament Location (City, Province)',
        callback: (value) {
          widget.location = value;
        },
      ),
      Divider(),
      _createStartEndDateUi(),
    ]);
  }

  Widget _createStartEndDateUi() {
    bool hasStart = widget.startDate != null;

    if (editDates || !hasStart) {
      return _dateSelector();
    }

    final theme = Theme.of(context);

    bool hasEnd = widget.endDate != null || widget.endDate == widget.startDate;

    DateFormat dateFormat = DateFormat("yyyy-MM-dd");

    return Row(
      children: [
        IconButton(
            onPressed: () {
              setState(() {
                editDates = true;
              });
            },
            icon: const Icon(Icons.edit)),
        Text(hasEnd ? "Dates: " : "Date: ", style: theme.textTheme.bodyMedium),
        Text(dateFormat.format(widget.startDate!),
            style: theme.textTheme.bodyMedium),
        Text(hasEnd ? " - " + dateFormat.format(widget.endDate!) : "",
            style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _dateSelector() {
    return Column(
      children: [
        CustomDateFormField(
          initialValue: PickerDateRange(widget.startDate, widget.endDate),
          callback: (arg) {
            _onDatePickerSelectionChanged(arg);
          },
        ),
        TextButton(
            onPressed: () {
              setState(() {
                editDates = false;
              });
            },
            child: Text(
              "Ok",
              style: Theme.of(context).textTheme.displaySmall,
            ))
      ],
    );
  }

  void _onDatePickerSelectionChanged(DateRangePickerSelectionChangedArgs arg) {
    if (arg.value is PickerDateRange) {
      widget.startDate = arg.value.startDate;
      widget.endDate = arg.value.endDate;

      setState(() {});
    } else if (arg.value is DateTime) {
      widget.startDate = arg.value;
      widget.endDate = arg.value;

      setState(() {});
    }
  }
}
