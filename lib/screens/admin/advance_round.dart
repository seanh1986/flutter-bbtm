import 'package:bbnaf/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:bbnaf/models/tournament/tournament.dart';

class AdvanceRoundWidget extends StatefulWidget {
  Tournament tournament;

  AdvanceRoundWidget({Key? key, required this.tournament}) : super(key: key);

  @override
  State<AdvanceRoundWidget> createState() {
    return _AdvanceRoundWidget();
  }
}

class _AdvanceRoundWidget extends State<AdvanceRoundWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> topBar = [Text('Info'), Text('Coaches')];
    List<Widget> views = [_viewInfo(), _viewCoaches()];

    assert(topBar.length == views.length);

    int tabLength = topBar.length;

    return DefaultTabController(
        length: tabLength,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TabBar(
                    tabs: topBar,
                  )
                ],
              ),
            ),
            body: TabBarView(
              children: views,
            )));
  }

  Widget _viewInfo() {
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextFormField(
                title: 'Name',
                callback: (value) => widget.tournament.info.name = value,
              ),
              CustomTextFormField(
                title: 'Location',
                callback: (value) => widget.tournament.info.location = value,
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
                    onPressed: () {},
                    child: const Text('Discard'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Update'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
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
