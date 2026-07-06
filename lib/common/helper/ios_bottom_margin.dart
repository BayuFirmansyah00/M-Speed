
import 'dart:io';

import 'package:flutter/cupertino.dart';

class IosBottomMargin extends StatelessWidget {
  final double margin;


  IosBottomMargin({this.margin = 42});

  @override
  Widget build(BuildContext context) {
    if(Platform.isIOS) return SizedBox(height: margin,);
    else return SizedBox(height: 12,);
  }

}