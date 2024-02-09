import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final List<SquadRankingFields> fields;

  RankingSquadsPage({Key? key, required this.fields}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RankingSquadsPage();
  }
}

class _RankingSquadsPage extends State<RankingSquadsPage> {
  late Tournament _tournament;
  late User _user;

  SquadRankingFields? _sortField;
  bool _sortAscending = false;

  bool _reset = true;

  List<Squad> _items = [];

  @override
  void initState() {
    super.initState();
    _reset = true;
    _sortAscending = false;
  }

  void _sort<T>(SquadRankingFields field, bool ascending) {
    setState(() {
      _reset = false;
      _sortField = field;
      _sortAscending = ascending;
    });
  }

  List<DataColumn2> _getColumns() {
    List<DataColumn2> columns = [];

    columns.add(DataColumn2(label: Text('#'), fixedWidth: 25));

    columns.add(DataColumn2(
        label: Center(child: Text('Squad  |  Coaches')), fixedWidth: 200));

    widget.fields.forEach((f) {
      String name = _getColumnName(f);

      if (name.isNotEmpty) {
        DataColumnSortCallback? sorter;
        switch (f) {
          case SquadRankingFields.W_T_L:
            sorter = null;
            break;
          default:
            sorter = (columnIndex, ascending) {
              bool shouldAscend = f != _sortField ? false : ascending;
              return _sort<num>(f, shouldAscend);
            };
            break;
        }

        columns.add(DataColumn2(
            label: Center(child: Text(name)),
            numeric: true,
            onSort: sorter,
            fixedWidth: _getColumnWidth(f)));
      }
    });

    return columns;
  }

  double? _getColumnWidth(SquadRankingFields f) {
    switch (f) {
      case SquadRankingFields.OppScore:
        return 100;
      case SquadRankingFields.SumIndividualScore:
      case SquadRankingFields.W_T_L:
        return 90;
      case SquadRankingFields.Pts:
        return 70;
      default:
        return null;
    }
  }

  List<DataRow2> _getRows() {
    final theme = Theme.of(context);

    List<DataRow2> rows = [];

    int rank = 1;
    _items.forEach((squad) {
      String nafName = _user.getNafName();

      bool highlight = squad.hasCoach(nafName);

      TextStyle? textStyle = highlight ? TextStyle(color: Colors.red) : null;

      List<DataCell> cells = [];

      cells.add(_createDataCell(rank.toString(), textStyle));

      cells.add(_createSquadCoachesDataCell(squad, textStyle?.color));

      widget.fields.forEach((f) {
        String name = _getColumnName(f);

        if (name.isNotEmpty) {
          cells.add(_createDataCell(_getCellValue(squad, f), textStyle));
        }
      });

      double? sizeSquadName = theme.textTheme.bodyMedium?.fontSize;
      double? sizeCoachName = theme.textTheme.bodySmall?.fontSize;
      int buffer = 10;
      double? sizeRowHeight = (sizeSquadName != null && sizeCoachName != null)
          ? sizeSquadName +
              buffer +
              (sizeCoachName + buffer) * squad.getCoaches().length
          : null;

      rows.add(DataRow2(cells: cells, specificRowHeight: sizeRowHeight));

      rank++;
    });

    return rows;
  }

  DataCell _createSquadCoachesDataCell(Squad squad, Color? c) {
    final theme = Theme.of(context);

    TextStyle squadStyle =
        TextStyle(color: c, fontSize: theme.textTheme.bodyMedium?.fontSize);

    TextStyle coachStyle =
        TextStyle(color: c, fontSize: theme.textTheme.bodySmall?.fontSize);

    List<Widget> cellWidgets = [
      Text(squad.name(), overflow: TextOverflow.ellipsis, style: squadStyle),
    ];

    squad.getCoaches().forEach((c) {
      cellWidgets.add(
          Text("    " + c, overflow: TextOverflow.ellipsis, style: coachStyle));
    });

    return DataCell(ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cellWidgets,
        )));
  }

  DataCell _createDataCell(String text, TextStyle? textStyle) {
    Text textWidget =
        Text(text, overflow: TextOverflow.ellipsis, style: textStyle);

    return DataCell(ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 200),
        child: Center(child: textWidget)));
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    _tournament = appState.tournamentState.tournament;
    _user = appState.authenticationState.user;

    if (_reset || _sortField == null) {
      _sortField = widget.fields.first;
      _sortAscending = false;
    }

    // so that when it reloads, it will reset
    // This will get reset if setState is called again
    _reset = true;

    _items = List.from(_tournament
        .getSquads()
        .where((a) => a.isActive(_tournament) || a.gamesPlayed() > 0));

    _items.sort((Squad a, Squad b) {
      final double aValue = _getSortingValue(a, _sortField!);
      final double bValue = _getSortingValue(b, _sortField!);

      int multiplier = _sortAscending ? 1 : -1;

      return multiplier * Comparable.compare(aValue, bValue);
    });

    return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        child: getDataTable());
  }

  Widget getDataTable() {
    // final theme = Theme.of(context);

    return DataTable2(
        // headingRowColor:
        //     MaterialStateColor.resolveWith((states) => Colors.grey[850]!),
        // headingTextStyle: const TextStyle(color: Colors.white),
        headingCheckboxTheme: const CheckboxThemeData(
            side: BorderSide(color: Colors.white, width: 2.0)),
        isHorizontalScrollBarVisible: true,
        isVerticalScrollBarVisible: true,
        columnSpacing: 12,
        horizontalMargin: 12,
        border: TableBorder.all(),
        dividerThickness:
            1, // this one will be ignored if [border] is set above
        fixedTopRows: 1,
        bottomMargin: 10,
        minWidth: 900,
        empty: Center(
            child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.grey[200],
                child: const Text('No data yet'))),
        columns: _getColumns(),
        rows: _getRows(),
        sortAscending: _sortAscending,
        sortColumnIndex: _getSortColumnIndex());
  }

  int _getSortColumnIndex() {
    int idx = widget.fields.indexOf(_sortField!);
    if (idx < 0) {
      idx = 0;
    }

    int skipIndices = 2;

    return skipIndices + idx;
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
        return "CoachPts";
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

  String _getCellValue(Squad s, SquadRankingFields f) {
    switch (f) {
      case SquadRankingFields.W_T_L:
        return s.wins().toString() +
            "/" +
            s.ties().toString() +
            "/" +
            s.losses().toString();
      default:
        return _getViewValue(s, f).toString();
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
        return s.sumIndividualScores(_tournament);
      case SquadRankingFields.W_Percent:
        return s.winPercent();
      case SquadRankingFields.SumTd:
        return s.sumTds(_tournament).toDouble();
      case SquadRankingFields.SumCas:
        return s.sumCas(_tournament).toDouble();
      case SquadRankingFields.SumOppTd:
        return s.sumOppTds(_tournament).toDouble();
      case SquadRankingFields.SumOppCas:
        return s.sumOppCas(_tournament).toDouble();
      case SquadRankingFields.SumDeltaTd:
        return s.sumDeltaTds(_tournament).toDouble();
      case SquadRankingFields.SumDeltaCas:
        return s.sumDeltaCas(_tournament).toDouble();
      case SquadRankingFields.OppScore:
        return s.oppPoints.toDouble();
      default:
        return 0.0;
    }
  }
}
