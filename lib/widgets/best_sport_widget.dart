import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/matchup/reported_match_result.dart';
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
    return _basicRatings(context);
    // return _bbDiceRatings(context);
  }

  Widget _basicRatings(BuildContext context) {
    return RatingBar.builder(
      initialRating: 3,
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
