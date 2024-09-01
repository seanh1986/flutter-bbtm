import 'package:bbnaf/tournament_repository/src/models/coach.dart';
import 'package:bbnaf/tournament_repository/src/models/races.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class CoachImportExport {
  final String _coachName = "Coach Name";
  final String _nafName = "Naf Name";
  final String _nafNumber = "Naf Number";
  final String _race = "Race";
  final String _teamName = "Team Name";
  final String _squadName = "Squad Name";

  late final int _idxCoachName;
  late final int _idxNafName;
  late final int _idxNafNumber;
  late final int _idxRace;
  late final int _idxTeamName;
  late final int _idxSquadName;

  // Columns for excel import/export
  late List<String> _columns;

  CoachImportExport() {
    _columns = [
      _coachName,
      _nafName,
      _nafNumber,
      _race,
      _teamName,
      _squadName,
    ];

    _idxCoachName = _columns.indexOf(_coachName);
    _idxNafName = _columns.indexOf(_nafName);
    _idxNafNumber = _columns.indexOf(_nafNumber);
    _idxRace = _columns.indexOf(_race);
    _idxTeamName = _columns.indexOf(_teamName);
    _idxSquadName = _columns.indexOf(_squadName);
  }

  Future<List<Coach>> import() async {
    List<Coach> coaches = [];

    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    if (pickedFile == null) {
      return [];
    }

    var bytes = pickedFile.files.single.bytes;
    if (bytes == null) {
      return [];
    }

    var excel = Excel.decodeBytes(bytes);
    for (String sheetName in excel.tables.keys) {
      Sheet? sheet = excel.tables[sheetName];
      if (sheet == null) {
        continue;
      }

      int numRows = sheet.maxRows;
      int numCols = sheet.maxColumns;

      if (numCols < 4) {
        continue;
      }

      for (int r = 1; r < numRows; r++) {
        List<Data?> row = sheet.rows[r];

        String nafName = "";
        String squadName = "";
        String coachName = "";
        Race race = Race.Unknown;
        String teamName = "";
        int nafNumber = 0;

        for (int c = 0; c < numCols; c++) {
          Data? cell = row[c];
          if (cell == null) {
            continue;
          }

          final value = cell.value;

          switch (value) {
            case TextCellValue():
              String text = value.value.text!;

              if (c == _idxCoachName) {
                coachName = text;
              } else if (c == _idxNafName) {
                nafName = text;
              } else if (c == _idxRace) {
                race = RaceUtils.getRaceOrFindSimilar(text);
              } else if (c == _idxTeamName) {
                teamName = text;
              } else if (c == _idxSquadName) {
                squadName = text;
              }
              break;
            case IntCellValue():
              if (c == _idxNafNumber) {
                nafNumber = value.value;
              }
              break;
            default:
              break;
          }
        }

        if (nafName.isEmpty && coachName.isEmpty) {
          continue;
        }

        coaches.add(Coach(
            nafName, squadName, coachName, race, teamName, nafNumber, true));
      }
    }

    return coaches;
  }
}
