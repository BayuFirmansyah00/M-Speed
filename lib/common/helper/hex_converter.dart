import 'package:flutter/material.dart';

import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    String colorString = hexString;
    // String lastTwoChars = hexString.substring(hexString.length - 2);
    // log(lastTwoChars);
    // log("HEXSTRING : ${hexString.length}");
    final buffer = StringBuffer();
    if (hexString.length == 6) buffer.write('ff');
    if (hexString.length == 8) {
      colorString = colorString.removeLast();
      colorString = colorString.removeLast();
      buffer.write('ff');
    }
    if (hexString.length == 7) {
      colorString = colorString.removeLast();
      buffer.write('ff');
    }
    // log("COLORSTRING LENGTH : ${colorString.length}");
    // log("COLORSTRING : ${colorString}");
    buffer.write(colorString.replaceFirst('#', ''));
    // log("BUFFER : ${buffer}");
    // log(buffer.toString());
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Color fromHex8(String hexString) {
    String lastTwoChars = hexString.substring(hexString.length - 2);
    // log(lastTwoChars);
    // log("HEXSTRING 8 : $hexString");
    final buffer = StringBuffer();
    String save = hexString.substring(0, 7);

    // if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    // log("HEXSTRING 8 : $buffer");
    // log(save);
    buffer.write(save.replaceFirst('#', lastTwoChars));
    // log(buffer.toString());
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
