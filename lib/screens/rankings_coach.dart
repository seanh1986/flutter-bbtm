import 'package:amorical_cup/data/tournament.dart';
import 'package:flutter/material.dart';
import 'package:amorical_cup/data/coach.dart';
// import 'package:flutter/paginated_data_table.dart';

class RankingCoachPage extends StatefulWidget {
  final Tournament tournament;

  RankingCoachPage({Key key, @required this.tournament}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RankingCoachPage();
  }
}

class _RankingCoachPage extends State<RankingCoachPage> {
  // int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex = 3;
  bool _sortAscending = false;

  List<Coach> _items = [];
  // int _rowsOffset = 0;

  @override
  void initState() {
    _items = widget.tournament.coaches;
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
    return [
      DataColumn(
        label: Text('Naf Name'),
      ),
      DataColumn(
        label: Text('Squad'),
        onSort: (columnIndex, ascending) =>
            _sort<String>((Coach c) => c.squadName, columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Race'),
        onSort: (columnIndex, ascending) =>
            _sort<String>((Coach c) => c.raceName(), columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Points'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            _sort<num>((Coach c) => c.points(), columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Wins'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            _sort<num>((Coach c) => c.wins(), columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Ties'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            _sort<num>((Coach c) => c.ties(), columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Losses'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            _sort<num>((Coach c) => c.losses(), columnIndex, ascending),
      ),
      DataColumn(
        label: Text('TDs'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            _sort<num>((Coach c) => c.tds, columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Cas'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            _sort<num>((Coach c) => c.cas, columnIndex, ascending),
      ),
    ];
  }

  List<DataRow> _getRows() {
    List<DataRow> rows = List();

    // sort by points ascending
    _sort<num>((Coach c) => c.points(), _sortColumnIndex, _sortAscending);

    _items.forEach((coach) {
      rows.add(DataRow(cells: <DataCell>[
        DataCell(Text('${coach.nafName}')),
        DataCell(Text('${coach.squadName}')),
        DataCell(Text('${coach.raceName()}')),
        DataCell(Text('${coach.points().toString()}')),
        DataCell(Text('${coach.wins().toString()}')),
        DataCell(Text('${coach.ties().toString()}')),
        DataCell(Text('${coach.losses().toString()}')),
        DataCell(Text('${coach.tds.toString()}')),
        DataCell(Text('${coach.cas.toString()}')),
      ]));
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
}
