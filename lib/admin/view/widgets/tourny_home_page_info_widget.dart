// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:bbnaf/tournament_repository/src/models/tournament_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TournyHomePageInfoWidget extends StatefulWidget {
  late String detailsSpecialRules;
  late String detailsKickOff;
  late String detailsWeather;

  QuillController _richTextSpecialRulesController = QuillController.basic();
  QuillController _richTextWeatherController = QuillController.basic();
  QuillController _richTextKickOffController = QuillController.basic();

  TournyHomePageInfoWidget({Key? key, required TournamentInfo info})
      : super(key: key) {
    this.detailsSpecialRules = info.detailsSpecialRules;
    this.detailsKickOff = info.detailsKickOff;
    this.detailsWeather = info.detailsWeather;
  }

  @override
  State<TournyHomePageInfoWidget> createState() {
    return _TournyHomePageInfoWidget();
  }

  void updateTournamentInfo(TournamentInfo info) {
    var jsonSpecialRules =
        jsonEncode(_richTextSpecialRulesController.document.toDelta().toJson());
    var jsonKickOff =
        jsonEncode(_richTextKickOffController.document.toDelta().toJson());
    var jsonWeather =
        jsonEncode(_richTextWeatherController.document.toDelta().toJson());

    info.detailsSpecialRules = jsonSpecialRules;
    info.detailsKickOff = jsonKickOff;
    info.detailsWeather = jsonWeather;
  }
}

class _TournyHomePageInfoWidget extends State<TournyHomePageInfoWidget> {
  @override
  void initState() {
    super.initState();

    _tryReloadRichText();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _getRichTextEditor(
          "Special Rules", widget._richTextSpecialRulesController),
      Divider(),
      _getRichTextEditor("Kick-Off Rules", widget._richTextKickOffController),
      Divider(),
      _getRichTextEditor("Weather Rules", widget._richTextWeatherController),
    ]);
  }

  Widget _getRichTextEditor(String title, QuillController controller) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(title, style: theme.textTheme.bodyLarge),
        QuillToolbar.simple(
          configurations: QuillSimpleToolbarConfigurations(
            controller: controller,
            sharedConfigurations: const QuillSharedConfigurations(
              locale: Locale('en'),
            ),
          ),
        ),
        QuillEditor.basic(
          configurations: QuillEditorConfigurations(
            controller: controller,
            sharedConfigurations: const QuillSharedConfigurations(
              locale: Locale('en'),
            ),
          ),
        ),
      ],
    );
  }

  void _tryReloadRichText() {
    try {
      final json = jsonDecode(widget.detailsSpecialRules);
      final doc = Document.fromJson(json);
      widget._richTextSpecialRulesController = QuillController(
          document: doc, selection: TextSelection.collapsed(offset: 0));
    } catch (_) {}

    try {
      final json = jsonDecode(widget.detailsKickOff);
      final doc = Document.fromJson(json);
      widget._richTextKickOffController = QuillController(
          document: doc, selection: TextSelection.collapsed(offset: 0));
    } catch (_) {}

    try {
      final json = jsonDecode(widget.detailsWeather);
      final doc = Document.fromJson(json);
      widget._richTextWeatherController = QuillController(
          document: doc, selection: TextSelection.collapsed(offset: 0));
    } catch (_) {}
  }
}
