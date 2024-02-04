import 'package:bbnaf/widgets/toggle_widget/models/toggle_widget_item.dart';
import 'package:flutter/material.dart';

class ToggleWidget extends StatefulWidget {
  final List<ToggleWidgetItem> items;
  final int? selectedIdx;

  ToggleWidget({Key? key, required this.items, this.selectedIdx})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ToggleWidget();
  }
}

class _ToggleWidget extends State<ToggleWidget> {
  List<ToggleWidgetItem> _items = [];
  late int _selectedIdx;

  @override
  void initState() {
    super.initState();

    _items = widget.items;
    _selectedIdx = widget.selectedIdx != null ? widget.selectedIdx! : 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List<Widget> _widgets = [
    //   _toggleButtonsList(context),
    //   SizedBox(height: 20),
    // ];

    // Widget subScreenWidget = _items[_selectedIdx].builder();
    // _widgets.add(subScreenWidget);

    // return new Container(
    //     child:
    //         new SingleChildScrollView(child: new Column(children: _widgets)));

    ToggleWidgetItem item = _items[_selectedIdx];

    return Container(
      child: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: <Widget>[
            _toggleButtonsList(context),
            SizedBox(height: 20),
            item.builder(context),
          ],
        ),
      ),
    );
  }

  Widget _toggleButtonsList(BuildContext context) {
    List<Widget> toggleWidgets = [];

    final theme = Theme.of(context);

    for (int i = 0; i < _items.length; i++) {
      ToggleWidgetItem item = _items[i];

      bool clickable = _selectedIdx != i;

      toggleWidgets.add(ElevatedButton(
        style: theme.elevatedButtonTheme.style,
        child: Text(item.title),
        onPressed: clickable
            ? () {
                setState(() {
                  _selectedIdx = i;
                });
              }
            : null,
      ));

      toggleWidgets.add(SizedBox(width: 10));
    }

    return Container(
        height: 60,
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: toggleWidgets));
  }
}
