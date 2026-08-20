import 'package:http/http.dart' as http;

void main() async {
  try {
    var response = await http.get(Uri.parse('http://10.0.2.2:8000/storage/seller/signatures/ukBzsrMQlz821Wt37H8Pt0ESQfpAJdiQnQmMe1SH.png'));
    print('Status: ${response.statusCode}');
    print('Length: ${response.bodyBytes.length}');
  } catch (e) {
    print('Error: $e');
  }
}
