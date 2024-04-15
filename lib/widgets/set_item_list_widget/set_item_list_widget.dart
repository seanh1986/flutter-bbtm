import 'package:flutter/material.dart';

class SetItemListWidget extends StatefulWidget {
  final String title;
  final String? itemDecorator;
  final List<String> curItems;
  final List<String> allItems;
  final Function(List<String>) onComplete;
  final bool allowAddItems;
  final bool showOkDismissBtns;

  SetItemListWidget({
    Key? key,
    required this.title,
    required this.allItems,
    required this.onComplete,
    this.itemDecorator,
    this.curItems = const [],
    this.allowAddItems = true,
    this.showOkDismissBtns = true,
  }) : super(key: key);

  @override
  State<SetItemListWidget> createState() {
    return _SetItemListWidget();
  }
}

class _SetItemListWidget extends State<SetItemListWidget> {
  List<String> _allItems = [];
  List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _allItems = List.from(widget.allItems);
    _items = List.from(widget.curItems);
  }

  // TODO: Improve this, as it's really crappy UI
  // Select which items should be used
  void _selectValidItems(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Items", style: theme.textTheme.bodyMedium),
          content: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                right: -40.0,
                top: -40.0,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: CircleAvatar(
                    child: Icon(Icons.close),
                    backgroundColor: Colors.lightBlue,
                  ),
                ),
              ),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter alertState) {
                  return Container(
                    width: 400.0,
                    height: 500.0,
                    child: ListView.builder(
                      itemCount: _allItems.length,
                      itemBuilder: (context, playerIndex) {
                        return CheckboxListTile(
                          title: Text(_allItems[playerIndex]),
                          value: _items.contains(_allItems[playerIndex]),
                          onChanged: (bool? value) {
                            if (value == null) {
                              return;
                            }

                            if (_items.contains(_allItems[playerIndex])) {
                              _items.remove(_allItems[playerIndex]);
                            } else {
                              _items.add(_allItems[playerIndex]);
                            }
                            setState(() {}); //ALSO UPDATE THE PARENT STATE
                            alertState(() {});
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    setState(() {
      final String item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<Widget> widgetItems = _items
        .map((i) => Text(i, key: Key(i), style: theme.textTheme.bodyMedium))
        .toList();

    return Column(children: [
      Row(
        children: [
          IconButton(
              onPressed: () {
                _selectValidItems(context);
              },
              icon: Icon(Icons.edit)),
          Text(
            "Select Items",
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
      SizedBox(height: 10),
      ReorderableListView(
        shrinkWrap: true,
        onReorder: _onReorder,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: widgetItems,
      ),
      SizedBox(height: 10),
      Row(children: [
        ElevatedButton(
            onPressed: () {
              setState(() {
                _items = widget.curItems;
              });
            },
            child: Text("Reset", style: theme.textTheme.bodyMedium)),
        SizedBox(width: 10),
        ElevatedButton(
            onPressed: () {
              widget.onComplete(_items);
            },
            child: Text("Ok", style: theme.textTheme.bodyMedium)),
      ])
    ]);
  }
}
