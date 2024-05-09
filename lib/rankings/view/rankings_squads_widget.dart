import 'dart:math';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/rankings/models/models.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/widgets/screenshot_util/screenshot_util.dart';
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
  SumBestSport,
}

class RankingSquadsPage extends StatefulWidget {
  final String title;
  final SquadRankingFilter? filter;
  final List<SquadRankingFields> fields;

  RankingSquadsPage(
      {Key? key, required this.title, this.filter, required this.fields})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RankingSquadsPage();
  }
}

class _RankingSquadsPage extends State<RankingSquadsPage> {
  late Tournament _tournament;
  late User _user;

  late String _title;

  SquadRankingFields? _sortField;
  bool _sortAscending = false;

  bool _reset = true;

  List<Squad> _items = [];

  String _searchValue = "";

  ScreenshotUtil _screenshot = ScreenshotUtil();
  // GlobalKey _screenshotKey = GlobalKey();

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

    columns.add(DataColumn2(label: Text('#'), fixedWidth: 35));

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
      case SquadRankingFields.SumBestSport:
      case SquadRankingFields.W_Percent:
        return 90;
      case SquadRankingFields.Pts:
      case SquadRankingFields.SumTd:
      case SquadRankingFields.SumCas:
      case SquadRankingFields.SumOppTd:
      case SquadRankingFields.SumOppCas:
      case SquadRankingFields.SumDeltaTd:
      case SquadRankingFields.SumDeltaCas:
      case SquadRankingFields.W:
      case SquadRankingFields.T:
      case SquadRankingFields.L:
        return 70;
      default:
        return null;
    }
  }

  List<DataRow2> _getAllRows({bool allowHighlights = true}) {
    final theme = Theme.of(context);

    List<DataRow2> rows = [];

    Color? even = theme.listTileTheme.tileColor;
    Color? odd = theme.listTileTheme.selectedTileColor;

    for (int i = 0; i < _items.length; i++) {
      Squad squad = _items[i];

      if (_searchValue.isNotEmpty && !squad.matchSearch(_searchValue)) {
        continue;
      }

      int rank = i + 1;

      String nafName = _user.getNafName();

      bool highlight = allowHighlights && squad.hasCoach(nafName);

      double highlightOpacity = 0.5;
      Color? cellColor =
          highlight ? Colors.red.withOpacity(highlightOpacity) : null;

      if (cellColor == null) {
        cellColor = i % 2 == 0 ? even : odd;
      }

      List<DataCell> cells = [];

      cells.add(_createDataCell(rank.toString()));

      cells.add(_createSquadCoachesDataCell(squad));

      widget.fields.forEach((f) {
        String name = _getColumnName(f);

        if (name.isNotEmpty) {
          cells.add(_createDataCell(_getCellValue(squad, f)));
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

      rows.add(DataRow2(
        cells: cells,
        specificRowHeight: sizeRowHeight,
        color: MaterialStatePropertyAll(cellColor),
      ));
    }

    return rows;
  }

  DataCell _createSquadCoachesDataCell(Squad squad) {
    final theme = Theme.of(context);

    TextStyle? squadStyle = theme.textTheme.bodyMedium;
    TextStyle? coachStyle = theme.textTheme.bodySmall;

    List<Widget> cellWidgets = [
      Text(squad.name(), overflow: TextOverflow.ellipsis, style: squadStyle),
    ];

    squad.getCoaches().forEach((c) {
      cellWidgets.add(
          Text("    " + c, overflow: TextOverflow.ellipsis, style: coachStyle));
    });

    return DataCell(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cellWidgets,
    ));
  }

  DataCell _createDataCell(String text) {
    return DataCell(Align(
        alignment: Alignment.center,
        child: Text(text, overflow: TextOverflow.ellipsis)));
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    _tournament = appState.tournamentState.tournament;
    _user = appState.authenticationState.user;
    _searchValue = appState.screenState.searchValue;

    if (_reset || _sortField == null) {
      _sortField = widget.fields.first;
      _sortAscending = false;
    }

    // so that when it reloads, it will reset
    // This will get reset if setState is called again
    _reset = true;

    _title = widget.title;

    _items = List.from(_tournament.getSquads().where((a) =>
        (widget.filter == null || widget.filter!.isActive(a)) && // Check filter
            a.isActive(_tournament) ||
        a.gamesPlayed() > 0)); // "active"

    _items.sort((Squad a, Squad b) {
      final double aValue = _getSortingValue(a, _sortField!);
      final double bValue = _getSortingValue(b, _sortField!);

      int multiplier = _sortAscending ? 1 : -1;

      return multiplier * Comparable.compare(aValue, bValue);
    });

    final theme = Theme.of(context);

    List<DataColumn2> columns = _getColumns();
    List<DataRow2> rows = _getAllRows();

    List<Widget> widgets = [];

    if (_tournament.isUserAdmin(_user)) {
      widgets.add(ElevatedButton(
          style: theme.elevatedButtonTheme.style,
          child: IconButton(
              icon: Icon(
                Icons.save,
                color: theme.iconTheme.color,
              ),
              onPressed: null),
          onPressed: () {
            _createImage(context);
          }));
    }

    widgets.add(Container(
        height: MediaQuery.of(context).size.height * 0.75,
        child: getDataTable(context, rows, columns)));

    return Column(
      children: widgets,
    );
  }

  DataTable2 getDataTable(
      BuildContext context, List<DataRow2> rows, List<DataColumn2> columns,
      {Key? key}) {
    final theme = Theme.of(context);

    return DataTable2(
        key: key,
        // headingCheckboxTheme: const CheckboxThemeData(
        //     side: BorderSide(color: Colors.white, width: 2.0)),
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
                child: Text(
                  'No data yet',
                  style: theme.textTheme.bodyLarge,
                ))),
        rows: rows,
        columns: columns,
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
      case SquadRankingFields.SumBestSport:
        return "Sport";
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
      case SquadRankingFields.SumBestSport:
        return s.sumBestSport(_tournament).toDouble();
      default:
        return 0.0;
    }
  }

  void _createImage(BuildContext context) {
    List<DataRow2> allRows = _getAllRows(allowHighlights: false);
    List<DataColumn2> columns = _getColumns();

    String tournyName = _tournament.info.name;
    int roundNumber = _tournament.curRoundNumber();

    String headerTitle = tournyName;
    String headerSubTitle = _title + " - Round " + roundNumber.toString();

    int numRows = allRows.length;
    int rowsPerPage = 10;

    int numPages = (numRows / rowsPerPage).ceil();

    for (int i = 0; i < numPages; i++) {
      int pageNumber = i + 1;
      String fileName = tournyName.toString() +
          "_" +
          _title +
          "_Round_" +
          roundNumber.toString() +
          "_Page_" +
          pageNumber.toString() +
          "_of_" +
          numPages.toString() +
          ".jpg";

      int startIdx = i * rowsPerPage;
      int endIdx = min((i + 1) * rowsPerPage, allRows.length);

      List<DataRow2> iRow = allRows.getRange(startIdx, endIdx).toList();
      DataTable2 iTable =
          getDataTable(context, iRow, columns); //, key: _screenshotKey);

      String footer =
          "Page " + pageNumber.toString() + "/" + numPages.toString();

      _screenshot.capture(
          context, headerTitle, headerSubTitle, iTable, footer, fileName);
    }
  }
}
