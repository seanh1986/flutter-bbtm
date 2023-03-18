import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:bbnaf/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditSquadsWidget extends StatefulWidget {
  final Tournament tournament;
  final TournamentBloc tournyBloc;

  EditSquadsWidget(
      {Key? key, required this.tournament, required this.tournyBloc})
      : super(key: key);

  @override
  State<EditSquadsWidget> createState() {
    return _EditSquadsWidget();
  }
}

class _EditSquadsWidget extends State<EditSquadsWidget> {
  List<Coach> _unselected = [];

  Map<String, SquadItem> _assignedSquads = Map();

  final _unselectedListKey = GlobalKey<AnimatedListState>();

  late TournamentBloc _tournyBloc;
  late Tournament _tournament;

  late FToast fToast;

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast.init(context);

    _tournyBloc = BlocProvider.of<TournamentBloc>(context);
    _tournament = widget.tournament;
  }

  void _initFromTournament(Tournament t) {
    List<Coach> coaches = t.getCoaches();

    coaches.forEach((c) {
      if (c.squadName.trim().isEmpty) {
        _unselected.add(c);
      } else {
        List<Coach>? squadCoaches = _assignedSquads[c.squadName]?.coaches;

        if (squadCoaches == null) {
          squadCoaches = [];
        }

        squadCoaches.add(c);

        _assignedSquads.update(c.squadName, (value) => SquadItem(squadCoaches!),
            ifAbsent: () => SquadItem(squadCoaches!));
      }
    });
  }

  @override
  void dispose() {
    _tournyBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TitleBar(title: "Edit Tournament Squads"),
      SizedBox(height: 20),
      Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _viewSquads(context))
    ]);
  }

// TODO: Finish...
  List<Widget> _viewSquads(BuildContext context) {
    _initFromTournament(_tournament);

    return [
      SizedBox(height: 10),
      _createSquadHeadline(),
      SizedBox(height: 10),
      Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            // child: _coachDataTable,
          ))
    ];
  }

  Widget _createSquadHeadline() {
    return Container(
        padding: const EdgeInsets.all(15),
        child: Column(children: [
          SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Column(children: [
              Text("Squads", style: TextStyle(fontSize: 18)),
              Text(
                  "[Active/Total]: " +
                      _assignedSquads.values
                          .where((element) => _isSquadActive(element.coaches))
                          .length
                          .toString() +
                      " / " +
                      _assignedSquads.length.toString(),
                  style: TextStyle(fontSize: 14))
            ]),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                _addNewSquad();
              },
              child: const Text('Add Squad'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _tournament = widget.tournament;
                });
              },
              child: const Text('Discard'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                if (_assignedSquads.containsKey("")) {
                  _showSuccessFailToast(false);
                  return;
                }

                VoidCallback callback = () async {
                  // // Remove empty rows
                  // _coaches.removeWhere((element) =>
                  //     element.coachName.trim().isEmpty &&
                  //     element.nafName.trim().isEmpty);

                  // List<RenameNafName> renames =
                  //     _coachSource.coachIdxNafRenames.values.toList();

                  // bool success = await _tournyBloc.overwriteCoaches(
                  //     widget.tournament.info.id, _coaches, renames);

                  // _showSuccessFailToast(success);
                };

                _showDialogToConfirmOverwrite(context, callback);
              },
              child: const Text('Update'),
            )
          ]),
        ]));
  }

  void _addNewSquad() {
    setState(() {
      _assignedSquads.putIfAbsent("", () => SquadItem.emtpty());
    });
  }

  void _showDialogToConfirmOverwrite(
      BuildContext context, VoidCallback confirmedUpdateCallback) {
    StringBuffer sb = new StringBuffer();

    sb.writeln(
        "Warning this will overwrite existing tournament data. Please confirm!");
    sb.writeln("");

    sb.writeln("NumSquads: " +
        _assignedSquads.length.toString() +
        " (Active: " +
        _assignedSquads.values
            .where((element) => _isSquadActive(element.coaches))
            .length
            .toString() +
        ")");

    showOkCancelAlertDialog(
            context: context,
            title: "Update Tournament",
            message: sb.toString(),
            okLabel: "Update",
            cancelLabel: "Dismiss")
        .then((value) => {
              if (value == OkCancelResult.ok) {confirmedUpdateCallback()}
            });
  }

  void _showSuccessFailToast(bool success) {
    if (success) {
      ToastUtils.show(fToast, "Update successful.");
    } else {
      ToastUtils.show(fToast, "Update failed.");
    }
  }

  bool _isSquadActive(List<Coach> coaches) {
    int numActiveCoaches = coaches.where((element) => element.active).length;

    int requiredNumCoachesPerSquad =
        widget.tournament.info.squadDetails.requiredNumCoachesPerSquad;

    return numActiveCoaches == requiredNumCoachesPerSquad;
  }

  int _flyingCount = 0;
  _moveItem({
    required int fromIndex,
    required List fromList,
    required GlobalKey<AnimatedListState> fromKey,
    required List toList,
    required GlobalKey<AnimatedListState> toKey,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final globalKey = GlobalKey();
    final item = fromList.removeAt(fromIndex);
    fromKey.currentState!.removeItem(
      fromIndex,
      (context, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: Opacity(
            key: globalKey,
            opacity: 0.0,
            child: CoachItem(text: item),
          ),
        );
      },
      duration: duration,
    );
    _flyingCount++;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // Find the starting position of the moving item, which is exactly the
      // gap its leaving behind, in the original list.
      final box1 = globalKey.currentContext!.findRenderObject() as RenderBox;
      final pos1 = box1.localToGlobal(Offset.zero);
      // Find the destination position of the moving item, which is at the
      // end of the destination list.
      final box2 = toKey.currentContext!.findRenderObject() as RenderBox;
      final box2height = box1.size.height * (toList.length + _flyingCount - 1);
      final pos2 = box2.localToGlobal(Offset(0, box2height));
      // Insert an overlay to "fly over" the item between two lists.
      final entry = OverlayEntry(builder: (BuildContext context) {
        return TweenAnimationBuilder(
          tween: Tween<Offset>(begin: pos1, end: pos2),
          duration: duration,
          builder: (_, Offset value, child) {
            return Positioned(
              left: value.dx,
              top: value.dy,
              child: CoachItem(text: item),
            );
          },
        );
      });

      Overlay.of(context)!.insert(entry);
      await Future.delayed(duration);
      entry.remove();
      toList.add(item);
      toKey.currentState!.insertItem(toList.length - 1);
      _flyingCount--;
    });
  }
}

class SquadItem {
  List<Coach> coaches = [];
  final GlobalKey<AnimatedListState> key = GlobalKey<AnimatedListState>();
  SquadItem(this.coaches);
  SquadItem.emtpty();
}

class CoachItem extends StatelessWidget {
  final String text;
  final VoidCallback? callback;

  const CoachItem({Key? key, required this.text, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
          ),
          child: Text(text),
          onPressed: () => callback,
        ));
  }
}
