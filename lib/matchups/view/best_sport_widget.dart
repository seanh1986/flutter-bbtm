import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BestSportWidget extends StatefulWidget {
  final ReportedMatchResult result;
  final Coach opponent;

  BestSportWidget({Key? key, required this.result, required this.opponent})
      : super(key: key);

  @override
  State<BestSportWidget> createState() {
    return _BestSportWidget();
  }
}

class _BestSportWidget extends State<BestSportWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
          _header(),
          SizedBox(height: 20),
          _guide(),
          SizedBox(height: 10),
          _basicRatings(context),
        ]));
  }

  Widget _header() {
    return Text("Rate your opponent\'s sportsmanship",
        style: TextStyle(fontSize: 20));
  }

  Widget _guide() {
    return DataTable(
        headingRowHeight: 0,
        dividerThickness: double.minPositive,
        columns: [
          DataColumn(label: Container()),
          DataColumn(label: Container()),
          DataColumn(label: Container()),
        ],
        rows: [
          DataRow(cells: [
            DataCell(Row(children: [
              Text("5"),
              Icon(Icons.star_rounded, color: Colors.yellow, size: 20)
            ])),
            DataCell(Text("Very Positive",
                style: TextStyle(decoration: TextDecoration.underline))),
            DataCell(Text(
                "Your opponent really made this a match to remember based on their actions or attitude."))
          ]),
          DataRow(cells: [
            DataCell(Row(children: [
              Text("4"),
              Icon(Icons.star_rounded, color: Colors.yellow, size: 20)
            ])),
            DataCell(Text("Positive",
                style: TextStyle(decoration: TextDecoration.underline))),
            DataCell(Text(
                "Your opponent had a great attitude and really enhanced your bloodbowl experience!"))
          ]),
          DataRow(cells: [
            DataCell(Row(children: [
              Text("3"),
              Icon(Icons.star_rounded, color: Colors.yellow, size: 20)
            ])),
            DataCell(Text("Standard",
                style: TextStyle(decoration: TextDecoration.underline))),
            DataCell(Text(
                "A fun enjoyable game of bloodbowl! Nothing extremely positive or negative."))
          ]),
          DataRow(cells: [
            DataCell(Row(children: [
              Text("2"),
              Icon(Icons.star_rounded, color: Colors.yellow, size: 20)
            ])),
            DataCell(Text("Negative",
                style: TextStyle(decoration: TextDecoration.underline))),
            DataCell(Text(
                "Your opponent complained about dice a bit too much. Room for improvement."))
          ]),
          DataRow(cells: [
            DataCell(Row(children: [
              Text("1"),
              Icon(Icons.star_rounded, color: Colors.yellow, size: 20)
            ])),
            DataCell(Text("Very Negative",
                style: TextStyle(decoration: TextDecoration.underline))),
            DataCell(Text(
                "The match was not enjoyable due to your opponent's actions or attitude."))
          ]),
        ]);
  }

  Widget _basicRatings(BuildContext context) {
    return RatingBar.builder(
      initialRating: widget.result.bestSportOppRank.toDouble(),
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        widget.result.bestSportOppRank = rating.round();
      },
    );
  }
}
