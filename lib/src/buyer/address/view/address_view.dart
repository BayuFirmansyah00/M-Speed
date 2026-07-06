import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/src/buyer/address/provider/address_provider.dart';
import 'package:mspeed/src/buyer/address/view/add_address_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mspeed/src/cart/model/shopping_cart_confirm_model.dart';

import '../../../../common/helper/constant.dart';
import '../../../../common/base/base_state.dart';
import '../../../../utils/utils.dart';
import '../model/address_model.dart';
// import '../../cart/provider/shopping_cart_provider.dart';

class AddressView extends StatefulWidget {
  bool selectMode;

  AddressView({super.key, this.selectMode = false});

  @override
  State<AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends BaseState<AddressView> {
  String? userId;
  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = await prefs.getString(Constant.kSetPrefId);
    context
        .read<AddressProvider>()
        .fetchAddressList(withLoading: true);
  }

  AddressModelData? selectedAddress = null;

  @override
  Widget build(BuildContext context) {
    final addressP = context.watch<AddressProvider>().addressModel.data;

    // final cartP = context.watch<ShoppingCartProvider>();
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
        action: [
          InkWell(
            onTap: () async {
              dynamic f = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return AddAddressView();
              }));
              context.read<AddressProvider>().clearAddressForm();
              if (f != null) {
                await context
                    .read<AddressProvider>()
                    .fetchAddressList(withLoading: true);
              }
            },
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AddAddressView();
                }));
              },
              child: Text(
                "Tambah Alamat",
                style: TextStyle(
                    color: Constant.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
          )
        ],
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
                    final item = addressP?[index];
                    return InkWell(
                      onTap: () async {
                        if (widget.selectMode == true) {
                          setState(() {
                            selectedAddress = item;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: selectedAddress == item
                                ? Color(0xFFFEF9F4)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1,
                                color: selectedAddress == item
                                    ? Constant.primaryColor
                                    : Color(0xFFEEF0F8))),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  (item?.namaPerusahaan ?? "Kantor Xeno"),
                                  style: TextStyle(
                                    color: Constant.grayColor,
                                    fontFamily: 'Open-Sans',
                                    fontSize: 12,
                                    fontWeight: Constant.semibold,
                                    // height: 0,
                                  ),
                                ),
                                if (item?.aktif == '1')
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF7DFDE),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Utama",
                                      style: TextStyle(
                                          color: Constant.primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  )
                              ],
                            ),
                            SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            '${item?.firstname ?? "-"} ${item?.lastname ?? "-"}',
                                            style: Constant.primaryTextStyle
                                                .copyWith(
                                                    fontWeight:
                                                        Constant.semibold),
                                          ),
                                          Text(
                                            item?.telp ?? "-",
                                            style: Constant.secondaryTextStyle,
                                          ),
                                          Text(
                                            item?.alamat ?? "-",
                                            style: Constant.secondaryTextStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (item == selectedAddress) ...[
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Icon(
                                        Icons.check,
                                        color: Constant.textPriceColor,
                                      )
                                    ]
                                  ],
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          context
                                              .read<AddressProvider>()
                                              .addressModelData = item;
                                          handleTap(() async {
                                            dynamic f = await Navigator.push(
                                                context, MaterialPageRoute(
                                                    builder: (context) {
                                              return AddAddressView(
                                                  isEdit: true);
                                            }));
                                            if (f != null) {
                                              context
                                                  .read<AddressProvider>()
                                                  .fetchAddressList(
                                                      withLoading: true);
                                            }
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16),
                                          elevation: 0,
                                          side: BorderSide(
                                              color: Color(0xFFEEF0F8)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text('Ubah Alamat'),
                                      ),
                                    ),
                                    if (item != selectedAddress) ...[
                                      SizedBox(width: 16),
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color(0xFFEEF0F8)),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white),
                                        child: IconButton(
                                          icon: Icon(Icons.more_horiz),
                                          color: Colors.black,
                                          onPressed: () {
                                            if (item != null) {
                                              _showOpsiBottomSheet(
                                                  context, item);
                                            }
                                          },
                                        ),
                                      )
                                    ]
                                  ],
                                ),
                              ],
                            ),
                          ],
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
      bottomNavigationBar: widget.selectMode
          ? BottomAppBar(
              color: Colors.white,
              child: CustomButton.mainButton(
                'Pilih Alamat',
                color: selectedAddress != null
                    ? Constant.primaryColor
                    : Colors.grey,
                borderRadius: BorderRadius.circular(12),
                () async {
                  if (selectedAddress == null) return;
                  log("INI ssele : ${selectedAddress}");
                  await context.read<AddressProvider>().setBuyerAddress();
                  // context.read<ShoppingCartProvider>().selectedAddress =
                  //     ShoppingCartConfirmModelDataAddress(
                  //         name: selectedAddress?.name ?? "",
                  //         address: selectedAddress?.address ?? "",
                  //         phone: selectedAddress?.phone ?? "");
                },
                // margin: EdgeInsets.symmetric(horizontal: 16),
              ),
            )
          : null,
    );
  }

  void _showOpsiBottomSheet(BuildContext context, AddressModelData item) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Jadikan Alamat Utama',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  // Handle 'Hapus' action
                  print('Hapus tapped');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  'Hapus',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  context.read<AddressProvider>().addressModelData = item;
                  handleTap(() async {
                    await Utils.showYesNoDialog(
                      context: context,
                      title: "Konfirmasi",
                      desc: 'Apakah Anda yakin ingin menghapus alamat ini ?',
                      yesCallback: () async {
                        await context
                            .read<AddressProvider>()
                            .deleteAddress()
                            .then((value) async {
                          await Utils.showSuccess(
                              msg: "Sukses Menghapus Alamat");
                          await Future.delayed(Duration(seconds: 2), () {
                            Navigator.pop(context);
                          });
                          await context
                              .read<AddressProvider>()
                              .fetchAddressList();
                          return true;
                        }).onError((error, stackTrace) {
                          Utils.showFailed(
                              msg: error
                                      .toString()
                                      .toLowerCase()
                                      .contains("doctype")
                                  ? "Gagal Hapus Alamat!"
                                  : "$error");
                          return false;
                        });
                      },
                      noCallback: () {
                        Navigator.pop(context);
                      },
                    );
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
