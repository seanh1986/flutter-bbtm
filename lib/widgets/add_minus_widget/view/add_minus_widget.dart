// ignore_for_file: must_be_immutable

import 'package:bbnaf/widgets/add_minus_widget/models/add_minus_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddMinusWidget extends StatefulWidget {
  AddMinusItem item;

  AddMinusWidget({Key? key, required this.item}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddMinusWidget();
  }
}

class _AddMinusWidget extends State<AddMinusWidget> {
  final double fabSize = kIsWeb ? 32.0 : 20.0;

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
    final theme = Theme.of(context);

    String numStr = widget.item.value.toString();

    List<Widget> widgets = [Text(numStr, style: theme.textTheme.bodyLarge)];

    if (widget.item.showFab) {
      widgets.add(_getButton(true));
    }

    widgets.add(Text(widget.item.name, style: theme.textTheme.bodyLarge));

    if (widget.item.showFab) {
      widgets.add(_getButton(false));
    }

    // Wrap width, Match height ?
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 0.5, vertical: 5.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widgets));
  }

  Widget _getButton(bool add) {
    return Wrap(
      children: [
        RawMaterialButton(
          constraints: BoxConstraints.tight(Size(fabSize, fabSize)),
          shape: CircleBorder(),
          fillColor: widget.item.color,
          elevation: 0.0,
          child: Icon(add ? Icons.add : Icons.remove,
              color: Colors.black, size: fabSize / 2.0),
          onPressed: widget.item.editable // only click-able in editing mode
              ? () {
                  if (mounted) {
                    setState(() {
                      if (add) {
                        if (widget.item.maxValue == null ||
                            widget.item.value + 1 <= widget.item.maxValue!) {
                          widget.item.value++;
                        }
                      } else {
                        if (widget.item.minValue == null ||
                            widget.item.value - 1 >= widget.item.minValue!) {
                          widget.item.value--;
                        }
                      }
                    });
                  }
                }
              : null,
        )
      ],
    );
  }
}
