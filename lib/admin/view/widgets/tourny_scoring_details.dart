// ignore_for_file: must_be_immutable

import 'package:bbnaf/tournament_repository/src/models/tournament_info.dart';
import 'package:bbnaf/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TournyScoringDetailsWidget extends StatefulWidget {
  late String title;
  late ScoringDetails details;
  // Widget? tiebreakerWidget;

  TournyScoringDetailsWidget({
    Key? key,
    required title,
    required ScoringDetails details,
    // Widget? tieBreakerWidget
  }) : super(key: key) {
    this.title = title;
    this.details = details;
    // this.tiebreakerWidget = tieBreakerWidget;
  }

  @override
  State<TournyScoringDetailsWidget> createState() {
    return _TournyScoringDetailsWidget();
  }
}

class _TournyScoringDetailsWidget extends State<TournyScoringDetailsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Row winTieLossPts =
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      SizedBox(width: 10.0),
      Text(widget.title),
      SizedBox(width: 10.0),
      Expanded(
          child: CustomTextFormField(
        initialValue: widget.details.winPts.toString(),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        title: 'Wins',
        callback: (value) => widget.details.winPts = double.parse(value),
      )),
      SizedBox(width: 10.0),
      Expanded(
          child: CustomTextFormField(
        initialValue: widget.details.tiePts.toString(),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        title: 'Ties',
        callback: (value) => widget.details.tiePts = double.parse(value),
      )),
      SizedBox(width: 10.0),
      Expanded(
          child: CustomTextFormField(
        initialValue: widget.details.lossPts.toString(),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        title: 'Losses',
        callback: (value) => widget.details.lossPts = double.parse(value),
      ))
    ]);

    List<Widget> children = [
      winTieLossPts,
      SizedBox(height: 10),
    ];

    // if (widget.tiebreakerWidget != null) {
    //   children.addAll([widget.tiebreakerWidget!, SizedBox(height: 10)]);
    // }

    children.addAll(_getBonusPtsWidgets(widget.details));

    // if (details is IndividualScoringDetails) {
    //   children.addAll(_getCoachRankingFilterWidgets(details));
    // }

    return Column(
        mainAxisAlignment: MainAxisAlignment.center, children: children);
  }

  List<Widget> _getBonusPtsWidgets(ScoringDetails details) {
    List<Widget> bonusPtsWidgets = [
      ElevatedButton(
        onPressed: () {
          setState(() {
            String bonusPtsIdx = (details.bonusPts.length + 1).toString();
            details.bonusPts.add(BonusDetails("Bonus_" + bonusPtsIdx, 1));
          });
        },
        child: const Text('Add Bonus'),
      )
    ];

    for (int i = 0; i < details.bonusPts.length; i++) {
      String bonusKey = details.bonusPts[i].name;
      double bonusVal = details.bonusPts[i].weight;

      ValueChanged<String> bonusNameCallback = ((value) {
        details.bonusPts[i] = BonusDetails(value, bonusVal);
      });

      ValueChanged<String> bonusPtsCallback = ((value) {
        details.bonusPts[i] = BonusDetails(bonusKey, double.parse(value));
      });

      bonusPtsWidgets.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(width: 10.0),
            IconButton(
                onPressed: () {
                  setState(() {
                    details.bonusPts.removeAt(i);
                  });
                },
                icon: Icon(Icons.delete)),
            SizedBox(width: 10.0),
            Expanded(
                child: CustomTextFormField(
                    initialValue: bonusKey.toString(),
                    // inputFormatters: [
                    //   FilteringTextInputFormatter.singleLineFormatter
                    // ],
                    keyboardType: TextInputType.number,
                    title: 'Bonus Name',
                    callback: (value) => bonusNameCallback(value))),
            SizedBox(width: 10.0),
            Expanded(
                child: CustomTextFormField(
                    initialValue: bonusVal.toString(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    title: 'Bonus Value',
                    callback: (value) => bonusPtsCallback(value)))
          ]));
    }

    return bonusPtsWidgets;
  }
}
