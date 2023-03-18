import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:flutter/material.dart';
import 'package:bbnaf/models/coach.dart';

enum Fields {
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

  final List<Fields> fields;

  RankingCoachPage({Key? key, required this.tournament, required this.fields})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RankingCoachPage();
  }
}

class _RankingCoachPage extends State<RankingCoachPage> {
  late int _sortColumnIndex = widget.tournament.useSquads ? 4 : 3;
  bool _sortAscending = false;

  List<Coach> _items = [];

  @override
  void initState() {
    super.initState();

    widget.tournament.reProcessAllRounds();

    _items = List.from(widget.tournament.getCoaches());
  }

  void _sort<T>(
      Comparable<T> getField(Coach d), int columnIndex, bool ascending) {
    _items.sort((Coach a, Coach b) {
      if (!ascending) {
        final Coach c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
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

    if (widget.tournament.useSquads) {
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
          case Fields.Pts:
            // Take into account tie breakers
            sorter = (columnIndex, ascending) => _sort<num>(
                (Coach c) => c.pointsWithTieBreakersBuiltIn(),
                columnIndex,
                ascending);
            break;
          case Fields.W_T_L:
            sorter = null;
            break;
          default:
            sorter = (columnIndex, ascending) => _sort<num>(
                (Coach c) => _getSortingValue(c, f), columnIndex, ascending);
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

    // sort by field
    Fields field = widget.fields.first;
    _sort<num>((Coach c) => _getSortingValue(c, field), _sortColumnIndex,
        _sortAscending);

    int rank = 1;
    _items.forEach((coach) {
      List<DataCell> cells = [];

      cells.add(DataCell(Text(rank.toString())));

      cells.add(DataCell(Text('${coach.nafName}')));

      if (widget.tournament.useSquads) {
        cells.add(DataCell(Text('${coach.squadName}')));
      }

      cells.add(DataCell(Text('${coach.raceName()}')));

      widget.fields.forEach((f) {
        String name = _getColumnName(f);

        if (name.isNotEmpty) {
          cells.add(DataCell(_getCellValue(coach, f)));
        }
      });

      rows.add(DataRow(cells: cells));

      rank++;
    });

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
//          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            Expanded(
              child: Container(
                child: dataBody(),
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
          ),
        ));
  }

  String _getColumnName(Fields f) {
    switch (f) {
      case Fields.Pts:
        return "Pts";
      case Fields.W:
        return "W";
      case Fields.T:
        return "T";
      case Fields.L:
        return "L";
      case Fields.W_T_L:
        return "W/T/L";
      case Fields.W_Percent:
        return "%";
      case Fields.Td:
        return "Td+";
      case Fields.Cas:
        return "Cas+";
      case Fields.OppTd:
        return "Td-";
      case Fields.OppCas:
        return "Cas-";
      case Fields.DeltaTd:
        return "Td\u0394";
      case Fields.DeltaCas:
        return "Cas\u0394";
      case Fields.OppScore:
        return "OppScore";
      case Fields.BestSport:
        return "Sport";
      default:
        return "";
    }
  }

  Text _getCellValue(Coach c, Fields f) {
    switch (f) {
      case Fields.W_T_L:
        return Text(c.wins().toString() +
            "/" +
            c.ties().toString() +
            "/" +
            c.losses().toString());
      default:
        return Text(_getViewValue(c, f).toString());
    }
  }

  double _getSortingValue(Coach c, Fields f) {
    switch (f) {
      case Fields.Pts:
        return c.pointsWithTieBreakersBuiltIn();
      default:
        return _getViewValue(c, f);
    }
  }

  double _getViewValue(Coach c, Fields f) {
    switch (f) {
      case Fields.Pts:
        return c.points();
      case Fields.W:
        return c.wins().toDouble();
      case Fields.T:
        return c.ties().toDouble();
      case Fields.L:
        return c.losses().toDouble();
      case Fields.W_Percent:
        return c.winPercent();
      case Fields.Td:
        return c.tds.toDouble();
      case Fields.Cas:
        return c.cas.toDouble();
      case Fields.OppTd:
        return c.oppTds.toDouble();
      case Fields.OppCas:
        return c.oppCas.toDouble();
      case Fields.DeltaTd:
        return (c.tds - c.oppTds).toDouble();
      case Fields.DeltaCas:
        return c.cas - c.oppCas.toDouble();
      case Fields.OppScore:
        return c.oppPoints.toDouble();
      case Fields.BestSport:
        return c.bestSportPoints.toDouble();
      default:
        return 0.0;
    }
  }
}
