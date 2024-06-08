import 'package:flutter/material.dart';

class BbtmLogo extends StatelessWidget {
  const BbtmLogo({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return isPortrait
        ? Image.asset('assets/images/logos/BBTM-Cover-Photo-Thick.png')
        : Image.asset('assets/images/logos/BBTM-Cover-Photo.png');
  }
}
