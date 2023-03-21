import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:flutter/material.dart';
import 'package:bbnaf/models/squad.dart';
// import 'package:flutter/paginated_data_table.dart';

enum SquadRankingFields {
  Pts,
  W,
  T,
  L,
  W_T_L,
  W_Percent,
  SumIndividualScore,
  SumTd,
  SumCas,
  SumOppTd,
  SumOppCas,
  SumDeltaTd,
  SumDeltaCas,
  OppScore,
}

class RankingSquadsPage extends StatefulWidget {
  final Tournament tournament;
  final AuthUser authUser;
  final List<SquadRankingFields> fields;

  RankingSquadsPage(
      {Key? key,
      required this.tournament,
      required this.authUser,
      required this.fields})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RankingSquadsPage();
  }
}

class _RankingSquadsPage extends State<RankingSquadsPage> {
  int _sortColumnIndex = 3;
  bool _sortAscending = false;

  List<Squad> _items = [];

  @override
  void initState() {
    super.initState();
    _refreshState();
  }

  void _refreshState() {
    _items = List.from(widget.tournament.getSquads());
  }

  void _sort<T>(
      Comparable<T> getField(Squad s), int columnIndex, bool ascending) {
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
    List<DataColumn> columns = [];

    columns.add(
      DataColumn(label: Text('#')),
    );

    columns.add(
      DataColumn(label: Text('Squad')),
    );

    columns.add(DataColumn(
      label: Text('Coaches'),
    ));

    widget.fields.forEach((f) {
      String name = _getColumnName(f);

      if (name.isNotEmpty) {
        DataColumnSortCallback? sorter;
        switch (f) {
          case SquadRankingFields.Pts:
            // Take into account tie breakers
            sorter = (columnIndex, ascending) => _sort<num>(
                (Squad s) => s.pointsWithTieBreakersBuiltIn(),
                columnIndex,
                ascending);
            break;
          case SquadRankingFields.W_T_L:
            sorter = null;
            break;
          default:
            sorter = (columnIndex, ascending) => _sort<num>(
                (Squad s) => _getSortingValue(s, f), columnIndex, ascending);
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
    SquadRankingFields field = widget.fields.first;
    _sort<num>((Squad s) => _getSortingValue(s, field), _sortColumnIndex,
        _sortAscending);

    int rank = 1;
    _items.forEach((squad) {
      bool highlight = widget.authUser.nafName != null &&
          squad.hasCoach(widget.authUser.nafName!);

      TextStyle? textStyle = highlight ? TextStyle(color: Colors.red) : null;

      List<DataCell> cells = [];

      cells.add(DataCell(Text(rank.toString(), style: textStyle)));

      cells.add(DataCell(Text('${squad.name()}', style: textStyle)));

      cells.add(
          DataCell(Text('${squad.getCoaches().toString()}', style: textStyle)));

      widget.fields.forEach((f) {
        String name = _getColumnName(f);

        if (name.isNotEmpty) {
          cells.add(DataCell(_getCellValue(squad, f, textStyle)));
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
          headingRowColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return Colors.greenAccent.withOpacity(0.75);
            }
            return Colors.greenAccent.withOpacity(0.6);
          }),
        ),
      ),
    );
  }

  String _getColumnName(SquadRankingFields f) {
    switch (f) {
      case SquadRankingFields.Pts:
        return "Pts";
      case SquadRankingFields.W:
        return "W";
      case SquadRankingFields.T:
        return "T";
      case SquadRankingFields.L:
        return "L";
      case SquadRankingFields.W_T_L:
        return "W/T/L";
      case SquadRankingFields.W_Percent:
        return "%";
      case SquadRankingFields.SumIndividualScore:
        return "SumCoachPts";
      case SquadRankingFields.SumTd:
        return "Td+";
      case SquadRankingFields.SumCas:
        return "Cas+";
      case SquadRankingFields.SumOppTd:
        return "Td-";
      case SquadRankingFields.SumOppCas:
        return "Cas-";
      case SquadRankingFields.SumDeltaTd:
        return "Td\u0394";
      case SquadRankingFields.SumDeltaCas:
        return "Cas\u0394";
      case SquadRankingFields.OppScore:
        return "OppScore";
      default:
        return "";
    }
  }

  Text _getCellValue(Squad s, SquadRankingFields f, TextStyle? textStyle) {
    switch (f) {
      case SquadRankingFields.W_T_L:
        return Text(
            s.wins().toString() +
                "/" +
                s.ties().toString() +
                "/" +
                s.losses().toString(),
            style: textStyle);
      default:
        return Text(_getViewValue(s, f).toString(), style: textStyle);
    }
  }

  double _getSortingValue(Squad s, SquadRankingFields f) {
    switch (f) {
      case SquadRankingFields.Pts:
        return s.pointsWithTieBreakersBuiltIn();
      default:
        return _getViewValue(s, f);
    }
  }

  double _getViewValue(Squad s, SquadRankingFields f) {
    switch (f) {
      case SquadRankingFields.Pts:
        return s.points();
      case SquadRankingFields.W:
        return s.wins().toDouble();
      case SquadRankingFields.T:
        return s.ties().toDouble();
      case SquadRankingFields.L:
        return s.losses().toDouble();
      case SquadRankingFields.SumIndividualScore:
        return s.sumIndividualScores(widget.tournament);
      case SquadRankingFields.W_Percent:
        return s.winPercent();
      case SquadRankingFields.SumTd:
        return s.sumTds(widget.tournament).toDouble();
      case SquadRankingFields.SumCas:
        return s.sumCas(widget.tournament).toDouble();
      case SquadRankingFields.SumOppTd:
        return s.sumOppTds(widget.tournament).toDouble();
      case SquadRankingFields.SumOppCas:
        return s.sumOppCas(widget.tournament).toDouble();
      case SquadRankingFields.SumDeltaTd:
        return s.sumDeltaTds(widget.tournament).toDouble();
      case SquadRankingFields.SumDeltaCas:
        return s.sumDeltaCas(widget.tournament).toDouble();
      case SquadRankingFields.OppScore:
        return s.oppPoints.toDouble();
      default:
        return 0.0;
    }
  }
}
