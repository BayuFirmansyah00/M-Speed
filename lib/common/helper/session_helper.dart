import 'package:shared_preferences/shared_preferences.dart';
import 'package:mspeed/common/helper/constant.dart';

class SessionHelper {
  static Future<String> getSellerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constant.kSetPrefId) ?? '';
  }
}
