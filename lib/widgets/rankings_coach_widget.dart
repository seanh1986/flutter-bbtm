import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:flutter/material.dart';
import 'package:bbnaf/models/coach.dart';
// import 'package:flutter/paginated_data_table.dart';

enum Fields { Pts, W, T, L, Td, Cas, BestSport }

class RankingCoachPage extends StatefulWidget {
  final Tournament tournament;

  List<Fields> fields;

  RankingCoachPage({Key? key, required this.tournament, required this.fields})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RankingCoachPage();
  }
}

class _RankingCoachPage extends State<RankingCoachPage> {
  // int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  late int _sortColumnIndex = widget.tournament.useSquads ? 4 : 3;
  bool _sortAscending = false;

  List<Coach> _items = [];
  // int _rowsOffset = 0;

  @override
  void initState() {
    _items = widget.tournament.getCoaches();
    super.initState();
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
        onSort: (columnIndex, ascending) =>
            _sort<String>((Coach c) => c.squadName, columnIndex, ascending),
      ));
    }

    columns.add(DataColumn(
      label: Text('Race'),
      onSort: (columnIndex, ascending) =>
          _sort<String>((Coach c) => c.raceName(), columnIndex, ascending),
    ));

    widget.fields.forEach((f) {
      String name = _getColumnName(f);

      if (name.isNotEmpty) {
        columns.add(DataColumn(
          label: Text(name),
          numeric: true,
          onSort: (columnIndex, ascending) =>
              _sort<num>((Coach c) => _getValue(c, f), columnIndex, ascending),
        ));
      }
    });

    return columns;
  }

  List<DataRow> _getRows() {
    List<DataRow> rows = [];

    // sort by points ascending
    _sort<num>((Coach c) => c.points(), _sortColumnIndex, _sortAscending);

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
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints:
            BoxConstraints.expand(width: MediaQuery.of(context).size.width),
        child: DataTable(
          columns: _getColumns(),
          rows: _getRows(),
          sortAscending: _sortAscending,
          sortColumnIndex: _sortColumnIndex,
        ),
      ),
    );
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
      case Fields.Td:
        return "Td";
      case Fields.Cas:
        return "Cas";
      case Fields.BestSport:
        return "Sport";
      default:
        return "";
    }
  }

  Text _getCellValue(Coach c, Fields f) {
    switch (f) {
      case Fields.Pts:
        return Text('${c.points().toString()}');
      case Fields.W:
        return Text('${c.wins().toString()}');
      case Fields.T:
        return Text('${c.ties().toString()}');
      case Fields.L:
        return Text('${c.losses().toString()}');
      case Fields.Td:
        return Text('${c.tds.toString()}');
      case Fields.Cas:
        return Text('${c.cas.toString()}');
      case Fields.BestSport:
        return Text(_getValue(c, f).toString());
      default:
        return Text('');
    }
  }

  double _getValue(Coach c, Fields f) {
    switch (f) {
      case Fields.Pts:
        return c.points();
      case Fields.W:
        return c.wins().toDouble();
      case Fields.T:
        return c.ties().toDouble();
      case Fields.L:
        return c.losses().toDouble();
      case Fields.Td:
        return c.tds.toDouble();
      case Fields.Cas:
        return c.cas.toDouble();
      case Fields.BestSport:
        return 3;
      default:
        return 0.0;
    }
  }
}
