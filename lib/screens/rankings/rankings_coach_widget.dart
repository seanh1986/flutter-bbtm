import 'package:bbnaf/models/squad.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bbnaf/models/coach.dart';

enum CoachRankingFields {
  Pts,
  W,
  T,
  L,
  W_T_L,
  W_Percent,
  Td,
  Cas,
  OppTd,
  OppCas,
  OppScore,
  DeltaTd,
  DeltaCas,
  BestSport
}

class RankingCoachPage extends StatefulWidget {
  final Tournament tournament;
  final AuthUser authUser;
  final List<CoachRankingFields> fields;

  RankingCoachPage(
      {Key? key,
      required this.tournament,
      required this.authUser,
      required this.fields})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RankingCoachPage();
  }
}

class _RankingCoachPage extends State<RankingCoachPage> {
  late int _sortColumnIndex = widget.tournament.useSquads() ? 4 : 3;
  late CoachRankingFields _sortField = widget.fields.first;
  bool _sortAscending = false;

  List<Coach> _items = [];

  @override
  void initState() {
    super.initState();
    _refreshState();
  }

  void _refreshState() {
    _items = List.from(widget.tournament
        .getCoaches()
        .where((a) => a.isActive(widget.tournament) || a.gamesPlayed() > 0));

    _items.sort((Coach a, Coach b) {
      final double aValue = _getSortingValue(a, _sortField);
      final double bValue = _getSortingValue(b, _sortField);

      int multiplier = _sortAscending ? 1 : -1;

      return multiplier * Comparable.compare(aValue, bValue);
    });
  }

  void _sort<T>(CoachRankingFields field, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortField = field;
      _sortAscending = ascending;
    });
  }

  List<DataColumn> _getColumns() {
    List<DataColumn> columns = [];

    columns.add(
      DataColumn(label: Text('#')),
    );

    columns.add(
      DataColumn(label: Text('Naf Name')),
    );

    if (widget.tournament.useSquads()) {
      columns.add(DataColumn(
        label: Text('Squad'),
      ));
    }

    columns.add(DataColumn(
      label: Text('Race'),
    ));

    widget.fields.forEach((f) {
      String name = _getColumnName(f);

      if (name.isNotEmpty) {
        DataColumnSortCallback? sorter;
        switch (f) {
          case CoachRankingFields.W_T_L:
            sorter = null;
            break;
          default:
            sorter = (columnIndex, ascending) =>
                _sort<num>(f, columnIndex, ascending);
            break;
        }

        columns.add(DataColumn(
          label: Text(name),
          numeric: true,
          onSort: sorter,
        ));
      }
    });

    return columns;
  }

  List<DataRow> _getRows() {
    List<DataRow> rows = [];

    int rank = 1;
    _items.forEach((coach) {
      String nafname = widget.authUser.getNafName();

      bool primaryHighlight =
          coach.nafName.toLowerCase() == nafname.toLowerCase();

      // Check if coach is on squad of the logged-in user
      Squad? squad = !primaryHighlight && widget.tournament.useSquads()
          ? widget.tournament.getCoachSquad(nafname)
          : null;
      bool secondaryHighlight = squad != null && squad.hasCoach(coach.nafName);

      TextStyle? textStyle = primaryHighlight
          ? TextStyle(color: Colors.red)
          : (secondaryHighlight ? TextStyle(color: Colors.lightBlue) : null);

      List<DataCell> cells = [];

      cells.add(_createDataCell(rank.toString(), textStyle));

      cells.add(_createDataCell(coach.nafName, textStyle));

      if (widget.tournament.useSquads()) {
        cells.add(_createDataCell(coach.squadName, textStyle));
      }

      cells.add(_createDataCell(coach.raceName(), textStyle));

      widget.fields.forEach((f) {
        String name = _getColumnName(f);

        if (name.isNotEmpty) {
          cells.add(_createDataCell(_getCellValue(coach, f), textStyle));
        }
      });

      rows.add(DataRow(cells: cells));

      rank++;
    });

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    _refreshState();

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            Expanded(
              child: Container(
                child: ScrollConfiguration(
                    behavior:
                        ScrollConfiguration.of(context).copyWith(dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    }),
                    child: dataBody()),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20.0),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView dataBody() {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: _getColumns(),
            rows: _getRows(),
            sortAscending: _sortAscending,
            sortColumnIndex: _sortColumnIndex,
            headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.greenAccent.withOpacity(0.75);
              }
              return Colors.greenAccent.withOpacity(0.6);
            }),
          ),
        ));
  }

  String _getColumnName(CoachRankingFields f) {
    switch (f) {
      case CoachRankingFields.Pts:
        return "Pts";
      case CoachRankingFields.W:
        return "W";
      case CoachRankingFields.T:
        return "T";
      case CoachRankingFields.L:
        return "L";
      case CoachRankingFields.W_T_L:
        return "W/T/L";
      case CoachRankingFields.W_Percent:
        return "%";
      case CoachRankingFields.Td:
        return "Td+";
      case CoachRankingFields.Cas:
        return "Cas+";
      case CoachRankingFields.OppTd:
        return "Td-";
      case CoachRankingFields.OppCas:
        return "Cas-";
      case CoachRankingFields.DeltaTd:
        return "Td\u0394";
      case CoachRankingFields.DeltaCas:
        return "Cas\u0394";
      case CoachRankingFields.OppScore:
        return "OppScore";
      case CoachRankingFields.BestSport:
        return "Sport";
      default:
        return "";
    }
  }

  String _getCellValue(Coach c, CoachRankingFields f) {
    switch (f) {
      case CoachRankingFields.W_T_L:
        return c.wins().toString() +
            "/" +
            c.ties().toString() +
            "/" +
            c.losses().toString();
      default:
        return _getViewValue(c, f).toString();
    }
  }

  double _getSortingValue(Coach c, CoachRankingFields f) {
    switch (f) {
      case CoachRankingFields.Pts:
        return c.pointsWithTieBreakersBuiltIn();
      default:
        return _getViewValue(c, f);
    }
  }

  double _getViewValue(Coach c, CoachRankingFields f) {
    switch (f) {
      case CoachRankingFields.Pts:
        return c.points();
      case CoachRankingFields.W:
        return c.wins().toDouble();
      case CoachRankingFields.T:
        return c.ties().toDouble();
      case CoachRankingFields.L:
        return c.losses().toDouble();
      case CoachRankingFields.W_Percent:
        return c.winPercent();
      case CoachRankingFields.Td:
        return c.tds.toDouble();
      case CoachRankingFields.Cas:
        return c.cas.toDouble();
      case CoachRankingFields.OppTd:
        return c.oppTds.toDouble();
      case CoachRankingFields.OppCas:
        return c.oppCas.toDouble();
      case CoachRankingFields.DeltaTd:
        return c.deltaTd().toDouble();
      case CoachRankingFields.DeltaCas:
        return c.deltaCas().toDouble();
      case CoachRankingFields.OppScore:
        return c.oppPoints.toDouble();
      case CoachRankingFields.BestSport:
        return c.bestSportPoints.toDouble();
      default:
        return 0.0;
    }
  }

  DataCell _createDataCell(String text, TextStyle? textStyle) {
    return DataCell(ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 200),
        child: Text(text, overflow: TextOverflow.ellipsis, style: textStyle)));
  }
}
