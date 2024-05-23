import 'dart:math';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/rankings/rankings.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/widgets/screenshot_util/screenshot_util.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  BestSport,
}

class RankingCoachPage extends StatefulWidget {
  final String title;
  final CoachRankingFilter? filter;
  final List<CoachRankingFields> fields;

  RankingCoachPage(
      {Key? key, required this.title, this.filter, required this.fields})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RankingCoachPage();
  }
}

class _RankingCoachPage extends State<RankingCoachPage> {
  late Tournament _tournament;
  late User _user;

  late String _title;

  CoachRankingFields? _sortField;

  bool _sortAscending = false;

  bool _reset = true;

  List<Coach> _items = [];

  String _searchValue = "";

  ScreenshotUtil _screenshot = ScreenshotUtil();

  @override
  void initState() {
    super.initState();
    _reset = true;
    _sortAscending = false;
  }

  void _sort<T>(CoachRankingFields field, bool ascending) {
    setState(() {
      _reset = false;
      _sortField = field;
      _sortAscending = ascending;
    });
  }

  List<DataColumn2> _getColumns() {
    List<DataColumn2> columns = [];

    columns.add(DataColumn2(label: Center(child: Text('#')), fixedWidth: 35));

    columns
        .add(DataColumn2(label: Center(child: Text('Coach')), fixedWidth: 200));

    widget.fields.forEach((f) {
      String name = _getColumnName(f);

      if (name.isNotEmpty) {
        DataColumnSortCallback? sorter;
        switch (f) {
          case CoachRankingFields.W_T_L:
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

  double? _getColumnWidth(CoachRankingFields f) {
    switch (f) {
      case CoachRankingFields.OppScore:
        return 110;
      case CoachRankingFields.W_T_L:
      case CoachRankingFields.BestSport:
        return 90;
      case CoachRankingFields.Pts:
      case CoachRankingFields.Td:
      case CoachRankingFields.Cas:
      case CoachRankingFields.OppTd:
      case CoachRankingFields.OppCas:
      case CoachRankingFields.DeltaTd:
      case CoachRankingFields.DeltaCas:
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
      Coach coach = _items[i];

      if (_searchValue.isNotEmpty && !coach.matchSearch(_searchValue)) {
        continue;
      }

      int rank = i + 1;

      String nafname = _user.getNafName();

      bool primaryHighlight = allowHighlights &&
          coach.nafName.toLowerCase() == nafname.toLowerCase();

      // Check if coach is on squad of the logged-in user
      Squad? userSquad = _tournament.getCoachSquad(nafname);

      String coachSquadName =
          _tournament.useSquadVsSquad() ? coach.squadName : "";

      bool secondaryHighlight = allowHighlights &&
          userSquad != null &&
          userSquad.hasCoach(coach.nafName);

      double highlightOpacity = 0.5;
      Color? cellColor = primaryHighlight
          ? Colors.red.withOpacity(highlightOpacity)
          : (secondaryHighlight
              ? Colors.lightBlue.withOpacity(highlightOpacity)
              : null);

      if (cellColor == null) {
        cellColor = i % 2 == 0 ? even : odd;
      }

      List<DataCell> cells = [];

      cells.add(_createDataCell(rank.toString()));
      cells.add(_createCoachDataCell(coach, coachSquadName));

      widget.fields.forEach((f) {
        String name = _getColumnName(f);

        if (name.isNotEmpty) {
          cells.add(_createDataCell(_getCellValue(coach, f)));
        }
      });

      double? sizeNafName = theme.textTheme.bodyMedium?.fontSize;
      double? sizeSquadName =
          coachSquadName.isNotEmpty ? theme.textTheme.bodySmall?.fontSize : 0;
      double? sizeRace = theme.textTheme.bodySmall?.fontSize;

      int buffers = 10 * (coachSquadName.isNotEmpty ? 3 : 2);

      double? sizeRowHeight =
          (sizeNafName != null && sizeSquadName != null && sizeRace != null)
              ? sizeNafName + sizeRace + sizeSquadName + buffers
              : null;

      rows.add(DataRow2(
          cells: cells,
          specificRowHeight: sizeRowHeight,
          color: MaterialStatePropertyAll(cellColor)));
    }

    return rows;
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

    bool Function(Coach) selectedFilter = (c) {
      return widget.filter == null || widget.filter!.isActive(c);
    };

    _items = List.from(_tournament.getCoaches().where((a) =>
        selectedFilter(a) && // Check filters
        (a.isActive(_tournament) || a.gamesPlayed() > 0))); // "active"

    _items.sort((Coach a, Coach b) {
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
                child: Text('No data yet', style: theme.textTheme.bodyLarge))),
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
      case CoachRankingFields.Td:
        return 1000.0 * c.tds + c.deltaTd();
      case CoachRankingFields.Cas:
        return 1000.0 * c.cas + c.deltaCas();
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

  DataCell _createCoachDataCell(Coach coach, String coachSquadName) {
    final theme = Theme.of(context);

    TextStyle? nafNameStyle = theme.textTheme.bodyMedium;
    TextStyle? squadRaceStyle = theme.textTheme.bodySmall;

    List<Widget> cellWidgets = [
      Text(coach.nafName, overflow: TextOverflow.ellipsis, style: nafNameStyle),
    ];

    if (coachSquadName.isNotEmpty) {
      cellWidgets.add(Text("    " + coachSquadName,
          overflow: TextOverflow.ellipsis, style: squadRaceStyle));
    }

    cellWidgets.add(Text("    " + coach.raceName(),
        overflow: TextOverflow.ellipsis, style: squadRaceStyle));

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

  void _createImage(BuildContext context) {
    List<DataRow2> allRows = _getAllRows(allowHighlights: false);
    List<DataColumn2> columns = _getColumns();

    String tournyName = _tournament.info.name;
    int roundNumber = _tournament.curRoundNumber();

    String headerTitle = tournyName;
    String headerSubTitle = _title + " - Round " + roundNumber.toString();

    // Number of coaches
    int numRows = allRows.length;

    // Total lines available for coach rows
    int totalLinesPerPage = 36;

    // Total lines per coach row
    int numLinesPerRow = _tournament.useSquadVsSquad() ? 3 : 2;

    // Total number of coaches per page
    int rowsPerPage = ((totalLinesPerPage as double) / numLinesPerRow).floor();

    // Number of pages required
    int numPages = ((numRows as double) / rowsPerPage).ceil();

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
