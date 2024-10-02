import 'dart:math';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/rankings/models/models.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/widgets/screenshot_util/screenshot_util.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RankingSquadsPage extends StatefulWidget {
  final String title;
  final SquadRankingFilter? filter;
  final List<SquadRankingField> fields;

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

  SquadRankingField? _sortField;
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

  void _sort<T>(SquadRankingField field, bool ascending) {
    setState(() {
      _reset = false;
      _sortField = field;
      _sortAscending = ascending;
    });
  }

  List<DataColumn2> _getColumns() {
    List<DataColumn2> columns = [];

    if (widget.fields.isEmpty) {
      return columns;
    }

    columns.add(DataColumn2(label: Text('#'), fixedWidth: 35));

    columns.add(DataColumn2(
        label: Center(child: Text('Squad  |  Coaches')), fixedWidth: 200));

    widget.fields.forEach((f) {
      String name = f.label;

      if (name.isNotEmpty) {
        DataColumnSortCallback? sorter;
        switch (f.type) {
          case SquadRankingFieldType.W_T_L:
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

  double? _getColumnWidth(SquadRankingField f) {
    switch (f.type) {
      case SquadRankingFieldType.OppScore:
      case SquadRankingFieldType.Bonus: // Perhaps based on length of label?
        return 100;
      case SquadRankingFieldType.SumIndividualScore:
      case SquadRankingFieldType.W_T_L:
      case SquadRankingFieldType.SumBestSport:
      case SquadRankingFieldType.W_Percent:
        return 90;
      case SquadRankingFieldType.Pts:
      case SquadRankingFieldType.SumTd:
      case SquadRankingFieldType.SumCas:
      case SquadRankingFieldType.SumOppTd:
      case SquadRankingFieldType.SumOppCas:
      case SquadRankingFieldType.SumDeltaTd:
      case SquadRankingFieldType.SumDeltaCas:
      case SquadRankingFieldType.W:
      case SquadRankingFieldType.T:
      case SquadRankingFieldType.L:
        return 70;
      default:
        return null;
    }
  }

  List<DataRow2> _getAllRows({bool allowHighlights = true}) {
    final theme = Theme.of(context);

    List<DataRow2> rows = [];

    if (widget.fields.isEmpty) {
      return rows;
    }

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
        String name = f.label;

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
        color: WidgetStatePropertyAll(cellColor),
      ));
    }

    return rows;
  }

  DataCell _createSquadCoachesDataCell(Squad squad) {
    final theme = Theme.of(context);

    TextStyle? squadStyle = theme.textTheme.bodyMedium;
    TextStyle? coachStyle = theme.textTheme.bodySmall;

    List<Widget> cellWidgets = [
      Text(squad.displayName(_tournament.info),
          overflow: TextOverflow.ellipsis, style: squadStyle),
    ];

    List<Coach> coaches = [];
    squad.getCoaches().forEach((c) {
      Coach? coach = _tournament.getCoach(c);
      if (coach != null) {
        coaches.add(coach);
      }
    });

    // Sort in descending order
    coaches.sort((c1, c2) {
      return -1 *
          c1
              .pointsWithTieBreakersBuiltIn()
              .compareTo(c2.pointsWithTieBreakersBuiltIn());
    });

    coaches.forEach((c) {
      cellWidgets.add(Text(
          "    " +
              c.displayName(_tournament.info) +
              " (" +
              c.wins().toString() +
              "/" +
              c.ties().toString() +
              "/" +
              c.losses().toString() +
              ")",
          overflow: TextOverflow.ellipsis,
          style: coachStyle));
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
        (a.isActive(_tournament) || a.gamesPlayed() > 0))); // "active"

    _items.sort((Squad a, Squad b) {
      final double aValue =
          _sortField != null ? _getSortingValue(a, _sortField!) : 0.0;
      final double bValue =
          _sortField != null ? _getSortingValue(b, _sortField!) : 0.0;

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

    widgets.add(SizedBox(height: 5));

    widgets.add(Container(
        height: MediaQuery.of(context).size.height * 0.75,
        child: widget.fields.isNotEmpty
            ? getDataTable(context, rows, columns)
            : Column(
                children: [
                  SizedBox(height: 30),
                  Text("No results available at this time."),
                ],
              )));

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

  String _getCellValue(Squad s, SquadRankingField f) {
    switch (f.type) {
      case SquadRankingFieldType.W_T_L:
        return s.wins().toString() +
            "/" +
            s.ties().toString() +
            "/" +
            s.losses().toString();
      default:
        return _getViewValue(s, f).toString();
    }
  }

  double _getSortingValue(Squad s, SquadRankingField f) {
    switch (f.type) {
      case SquadRankingFieldType.Pts:
        return s.pointsWithTieBreakersBuiltIn();
      default:
        return _getViewValue(s, f);
    }
  }

  double _getViewValue(Squad s, SquadRankingField f) {
    switch (f.type) {
      case SquadRankingFieldType.Pts:
        return s.points();
      case SquadRankingFieldType.W:
        return s.wins().toDouble();
      case SquadRankingFieldType.T:
        return s.ties().toDouble();
      case SquadRankingFieldType.L:
        return s.losses().toDouble();
      case SquadRankingFieldType.SumIndividualScore:
        return s.sumIndividualScores(_tournament);
      case SquadRankingFieldType.W_Percent:
        return s.winPercent();
      case SquadRankingFieldType.SumTd:
        return s.sumTds(_tournament).toDouble();
      case SquadRankingFieldType.SumCas:
        return s.sumCas(_tournament).toDouble();
      case SquadRankingFieldType.SumOppTd:
        return s.sumOppTds(_tournament).toDouble();
      case SquadRankingFieldType.SumOppCas:
        return s.sumOppCas(_tournament).toDouble();
      case SquadRankingFieldType.SumDeltaTd:
        return s.sumDeltaTds(_tournament).toDouble();
      case SquadRankingFieldType.SumDeltaCas:
        return s.sumDeltaCas(_tournament).toDouble();
      case SquadRankingFieldType.OppScore:
        return s.oppPoints.toDouble();
      case SquadRankingFieldType.SumBestSport:
        return s.sumBestSport(_tournament).toDouble();
      case SquadRankingFieldType.Bonus:
        {
          if (f.bonusIdx < 0 || f.bonusIdx >= s.bonusPts.length) {
            return 0.0;
          }

          return s.bonusPts[f.bonusIdx];
        }
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

    // Number of squads
    int numRows = allRows.length;

    // Total lines available for squad rows
    int totalLinesPerPage = 36;

    // Total lines per squad row
    int numLinesPerRow =
        _tournament.info.squadDetails.maxNumCoachesPerSquad + 1;

    // Total number of squads per page
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
