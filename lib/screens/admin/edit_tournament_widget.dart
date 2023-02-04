import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class EditTournamentWidget extends StatefulWidget {
  Tournament tournament;

  EditTournamentWidget({Key? key, required this.tournament}) : super(key: key);

  @override
  State<EditTournamentWidget> createState() {
    return _EditTournamentWidget();
  }
}

enum EditTournamentSections {
  None,
  Info,
  Coaches,
  Squads,
  Rounds,
}

enum ViewState {
  Expanded,
  Compressed,
}

class _EditTournamentWidget extends State<EditTournamentWidget> {
  EditTournamentSections expandedState = EditTournamentSections.None;

  late String name;
  late String location;

  @override
  void initState() {
    super.initState();

    name = widget.tournament.info.name;
    location = widget.tournament.info.location;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text("Tournament Details"),
      subtitle: Text("Edit information/details, coaches, squads, etc."),
      children: [
        ExpansionTile(title: Text("Info"), children: _viewInfos()),
        ExpansionTile(title: Text("Coaches"), children: [_viewCoaches()]),
      ],
    );
  }

  List<Widget> _viewInfos() {
    return [
      CustomTextFormField(
        initialValue: name,
        title: 'Tournament Name',
        callback: (value) => name = value,
      ),
      CustomTextFormField(
        initialValue: location,
        title: 'Tournament Location (City, Province)',
        callback: (value) => location = value,
      ),
      // CustomDateFormField(
      //   initialValue: PickerDateRange(
      //       widget.tournament.info.dateTimeStart,
      //       widget.tournament.info.dateTimeEnd),
      //   callback: (arg) => _onDatePickerSelectionChanged,
      // ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                name = widget.tournament.info.name;
                location = widget.tournament.info.location;
              });
            },
            child: const Text('Discard'),
          ),
          SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              widget.tournament.info.name = name;
              widget.tournament.info.location = location;
            },
            child: const Text('Update'),
          )
        ],
      )
    ];

    // return Scaffold(
    //   body: SafeArea(
    //     child: Form(
    //       key: _formKey,
    //       child: Column(
    //         children: [
    //           CustomTextFormField(
    //             hintText: 'Tournament Name',
    //             callback: (value) => widget.tournament.info.name = value,
    //           ),
    //           CustomTextFormField(
    //             hintText: 'Location',
    //             callback: (value) => widget.tournament.info.location = value,
    //           ),
    //           // CustomDateFormField(
    //           //   initialValue: PickerDateRange(
    //           //       widget.tournament.info.dateTimeStart,
    //           //       widget.tournament.info.dateTimeEnd),
    //           //   callback: (arg) => _onDatePickerSelectionChanged,
    //           // ),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               ElevatedButton(
    //                 onPressed: () {},
    //                 child: const Text('Discard'),
    //               ),
    //               ElevatedButton(
    //                 onPressed: () {},
    //                 child: const Text('Update'),
    //               )
    //             ],
    //           )
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  // void _onDatePickerSelectionChanged(DateRangePickerSelectionChangedArgs arg) {
  //   if (arg.value is PickerDateRange) {
  //     widget.tournament.info.dateTimeStart = arg.value.startDate;
  //     widget.tournament.info.dateTimeEnd = arg.value.endDate;
  //   } else if (arg.value is DateTime) {
  //     widget.tournament.info.dateTimeStart = arg.value;
  //     widget.tournament.info.dateTimeEnd = arg.value;
  //   }
  // }

  Widget _viewCoaches() {
    return Text("Coaches!");
  }
}
