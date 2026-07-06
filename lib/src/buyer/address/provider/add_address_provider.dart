import 'package:mspeed/common/base/base_controller.dart';
import 'package:flutter/material.dart';

class AddAddressProvider extends BaseController with ChangeNotifier {
  // Hapus properti dan metode yang berkaitan dengan "agen" dan "subagen"

  TextEditingController fullNameC = TextEditingController();
  TextEditingController phoneNumberC = TextEditingController();
  TextEditingController addressC = TextEditingController();
  TextEditingController addressTitleC = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  // Future<void> fetchHome({bool withLoading = false}) async {
  //   // Hapus bagian yang berkaitan dengan "agen" dan "subagen"
  //   if (withLoading) loading(true);

  //   final response = await get(Constant.BASE_API_FULL + '/home');

  //   if (response.statusCode == 201 || response.statusCode == 200) {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     setHomeModel = HomeModel.fromJson(jsonDecode(response.body));
  //     notifyListeners();

  //     if (withLoading) loading(false);
  //   } else {
  //     final message = jsonDecode(response.body)["messages"]["error"];
  //     loading(false);
  //     throw Exception(message);
  //   }
  // }
}
