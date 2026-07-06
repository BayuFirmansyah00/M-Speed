import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/buyer/checkout/view/check_out_view.dart';
import 'package:provider/provider.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/src/buyer/address/provider/address_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mspeed/src/cart/model/shopping_cart_confirm_model.dart';

import '../../../../common/helper/constant.dart';
import '../../../../common/base/base_state.dart';
// import '../../cart/provider/shopping_cart_provider.dart';

class AddressPenerimaView extends StatefulWidget {
  AddressPenerimaView({super.key});

  @override
  State<AddressPenerimaView> createState() => _AddressPenerimaViewState();
}

class _AddressPenerimaViewState extends BaseState<AddressPenerimaView> {
  String? userId;
  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = await prefs.getString(Constant.kSetPrefId);
    context.read<AddressProvider>().fetchAddressPenerimaList(withLoading: true);
  }

  @override
  Widget build(BuildContext context) {
    final addressP =
        context.watch<AddressProvider>().alamatBuyerModel?.data ?? [];
    final p = context.watch<AddressProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        "Buku Alamat",
        color: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context
              .read<AddressProvider>()
              .fetchAddressList(withLoading: true);
        },
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.separated(
                  itemCount: (addressP ?? []).length,
                  separatorBuilder: (_, __) => SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final item = addressP[index];
                    return InkWell(
                      onTap: () async {
                        final p = context.read<AddressProvider>();
                        setState(() {
                          p.selectedAddress = item;
                          p.selectedAddressPenerima = item?.nama;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: p.selectedAddress == item
                                ? Color(0xFFFEF9F4)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1,
                                color: p.selectedAddress == item
                                    ? Constant.primaryColor
                                    : Color(0xFFEEF0F8))),
                        child: Text(
                          (item?.nama ?? "-"),
                          style: TextStyle(
                            color: Constant.grayColor,
                            fontFamily: 'Open-Sans',
                            fontSize: 12,
                            fontWeight: Constant.semibold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: CustomButton.mainButton(
          'Pilih Alamat',
          color:
              p.selectedAddress != null ? Constant.primaryColor : Colors.grey,
          borderRadius: BorderRadius.circular(12),
          () async {
            if (p.selectedAddressPenerima != null) {
              CusNav.nPop(context);
              CusNav.nPushReplace(context, CheckOutView());
              await context.read<AddressProvider>().setBuyerAddress();
            }
            if (p.selectedAddressPenerima == null) return;
          },
        ),
      ),
    );
  }
}
