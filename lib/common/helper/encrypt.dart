import 'dart:convert';

class Encrypt {
  // String encode = encode64("543");
  // inspect("Encode ${encode}");

  // String decode = decode64("QmltYXlpaTI1NDM=");
  // log("Decode => "+decode);

  String encode64(String n) {
    String key = "Bimayii2";
    String id = key + n;
    String bs64 = base64.encode(id.codeUnits);

    return bs64;
  }

  String decode64(String n) {
    List<int> decodedint1 = base64Url.decode(n);
    String decodedstring1 = utf8.decode(decodedint1);
    final splitted = decodedstring1.split('yii2');

    return splitted[1];
  }
}
