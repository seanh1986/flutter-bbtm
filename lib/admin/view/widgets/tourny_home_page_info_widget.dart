// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'package:bbnaf/tournament_repository/src/models/tournament_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TournyHomePageInfoWidget extends StatefulWidget {
  late CasualtyDetails casualtyDetails;
  late String detailsSpecialRules;
  late String detailsKickOff;
  late String detailsWeather;

  QuillController _richTextSpecialRulesController = QuillController.basic();
  QuillController _richTextWeatherController = QuillController.basic();
  QuillController _richTextKickOffController = QuillController.basic();

  TournyHomePageInfoWidget({Key? key, required TournamentInfo info})
      : super(key: key) {
    this.casualtyDetails = info.casualtyDetails;
    this.detailsSpecialRules = info.detailsSpecialRules;
    this.detailsKickOff = info.detailsKickOff;
    this.detailsWeather = info.detailsWeather;
  }

  @override
  State<TournyHomePageInfoWidget> createState() {
    return _TournyHomePageInfoWidget();
  }

  void updateTournamentInfo(TournamentInfo info) {
    info.casualtyDetails = casualtyDetails;

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
      SizedBox(height: 10),
      _createCasualtyDetails(),
      Divider(),
      _getRichTextEditor(
          "Special Rules", widget._richTextSpecialRulesController),
      Divider(),
      _getRichTextEditor("Kick-Off Rules", widget._richTextKickOffController),
      Divider(),
      _getRichTextEditor("Weather Rules", widget._richTextWeatherController),
    ]);
  }

  Widget _createCasualtyDetails() {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("Casualty Details:"),
            ),
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildCasualtyDetailsCheckboxList(theme),
                  )
                : Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: _buildCasualtyDetailsCheckboxList(theme),
                  ),
          ],
        );
      },
    );
  }

  List<Widget> _buildCasualtyDetailsCheckboxList(ThemeData theme) {
    return <Widget>[
      _buildCasualtyDetailsCheckboxField(
          theme, 'Spp', widget.casualtyDetails.spp, (value) {
        widget.casualtyDetails.spp = value!;
      }),
      _buildCasualtyDetailsCheckboxField(
          theme, 'Foul', widget.casualtyDetails.foul, (value) {
        widget.casualtyDetails.foul = value!;
      }),
      _buildCasualtyDetailsCheckboxField(
          theme, 'Surf', widget.casualtyDetails.surf, (value) {
        widget.casualtyDetails.surf = value!;
      }),
      _buildCasualtyDetailsCheckboxField(
          theme, 'Weapon', widget.casualtyDetails.weapon, (value) {
        widget.casualtyDetails.weapon = value!;
      }),
      _buildCasualtyDetailsCheckboxField(
          theme, 'Dodge', widget.casualtyDetails.dodge, (value) {
        widget.casualtyDetails.dodge = value!;
      }),
    ];
  }

  Widget _buildCasualtyDetailsCheckboxField(ThemeData theme, String title,
      bool initialValue, Function(bool?) onChanged) {
    return SizedBox(
      width: 140,
      child: CheckboxListTile(
        title: Text(title, style: theme.textTheme.labelMedium),
        value: initialValue,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _getRichTextEditor(String title, QuillController controller) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(title, style: theme.textTheme.bodyLarge),
        QuillToolbar.simple(
          controller: controller,
          configurations: QuillSimpleToolbarConfigurations(
            sharedConfigurations: const QuillSharedConfigurations(
              locale: Locale('en'),
            ),
          ),
        ),
        QuillEditor.basic(
          controller: controller,
          configurations: QuillEditorConfigurations(
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
