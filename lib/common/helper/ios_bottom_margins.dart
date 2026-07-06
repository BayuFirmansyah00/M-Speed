import 'dart:io';

import 'package:flutter/cupertino.dart';

class IosBottomMargin extends StatelessWidget {
  final double margin;

  IosBottomMargin({this.margin = 42});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      final height = MediaQuery.of(context).size.height;
      return SizedBox(
        height: height > 750 ? margin : 48,
      );
    } else {
      return SizedBox(
        height: 48,
      );
    }
  }
}
