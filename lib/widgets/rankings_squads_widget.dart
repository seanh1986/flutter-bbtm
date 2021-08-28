import 'package:amorical_cup/models/tournament.dart';
import 'package:flutter/material.dart';
import 'package:amorical_cup/models/squad.dart';
// import 'package:flutter/paginated_data_table.dart';

class RankingSquadsPage extends StatefulWidget {
  final Tournament tournament;

  RankingSquadsPage({Key? key, required this.tournament}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RankingSquadsPage();
  }
}

class _RankingSquadsPage extends State<RankingSquadsPage> {
  // int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex = 2;
  bool _sortAscending = false;

  List<Squad> _items = [];
  // int _rowsOffset = 0;

  @override
  void initState() {
    _items = widget.tournament.squads;
    super.initState();
  }

  void _sort<T>(
      Comparable<T> getField(Squad d), int columnIndex, bool ascending) {
    _items.sort((Squad a, Squad b) {
      if (!ascending) {
        final Squad c = a;
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
        label: Text('Squad'),
        onSort: (columnIndex, ascending) =>
            _sort<String>((Squad s) => s.name(), columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Coaches'),
      ),
      DataColumn(
        label: Text('Points'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            _sort<num>((Squad s) => s.points(), columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Wins'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            _sort<num>((Squad s) => s.wins(), columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Ties'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            _sort<num>((Squad s) => s.ties(), columnIndex, ascending),
      ),
      DataColumn(
        label: Text('Losses'),
        numeric: true,
        onSort: (columnIndex, ascending) =>
            _sort<num>((Squad s) => s.losses(), columnIndex, ascending),
      ),
    ];
  }

  List<DataRow> _getRows() {
    List<DataRow> rows = [];

    // sort by points ascending
    _sort<num>((Squad c) => c.points(), _sortColumnIndex, _sortAscending);

    _items.forEach((s) {
      rows.add(DataRow(cells: <DataCell>[
        DataCell(Text('${s.name()}')),
        DataCell(Text('${s.coaches.toString()}')),
        DataCell(Text('${s.points().toString()}')),
        DataCell(Text('${s.wins().toString()}')),
        DataCell(Text('${s.ties().toString()}')),
        DataCell(Text('${s.losses().toString()}')),
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
