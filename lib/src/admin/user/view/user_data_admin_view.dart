import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textField.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/src/admin/user/view/create_data_buyer_admin_view.dart';
import 'package:mspeed/src/admin/user/view/create_data_finance_admin_view.dart';
import 'package:mspeed/src/admin/user/view/create_data_penerima_admin_view.dart';
import 'package:mspeed/src/admin/user/view/create_data_seller_admin_view.dart';
import 'package:mspeed/utils/Utils.dart';
import 'package:provider/provider.dart';

class UserDataAdminView extends StatefulWidget {
  const UserDataAdminView({super.key, required this.userType});

  @override
  State<UserDataAdminView> createState() => _UserDataAdminViewState();
  final UserDataType userType;
}

class _UserDataAdminViewState extends BaseState<UserDataAdminView> {
  @override
  void initState() {
    getData();
    final p = context.read<AdminUserProvider>();
    p.searchC.clear();

    super.initState();
  }

  Future<void> getData({String q = ''}) async {
    Utils.showLoading();
    final p = context.read<AdminUserProvider>();
    if (widget.userType == UserDataType.BUYER) {
      await p.fetchBuyers(withLoading: false, search: q);
    } else if (widget.userType == UserDataType.SELLER) {
      await p.fetchSellers(withLoading: false, search: q);
    } else if (widget.userType == UserDataType.FINANCE) {
      await p.fetchKeuangan(withLoading: false, search: q);
    } else {
      await p.fetchPenerima(withLoading: false, search: q);
    }
    Utils.dismissLoading();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AdminUserProvider>().userData;
    final searchC = context.read<AdminUserProvider>().searchC;
    final p = context.read<AdminUserProvider>();
    Widget search() => Container(
          color: Colors.white,
          padding: EdgeInsets.only(top: 8, bottom: 16, left: 20, right: 20),
          child: CustomTextField.borderTextField(
            controller: searchC,
            onEditingComplete: () {
              getData(q: searchC.text);
            },
            required: false,
            hintText: "Cari",
            hintColor: Color(0xff6D7588),
            borderColor: Color(0xffDBDFE9),
            prefix: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/icons/ic-search.png',
                width: 5,
                height: 5,
                color: Color(0xff6D7588),
              ),
            ),
            onChanged: (val) {
              // if (p.searchOnStoppedTyping != null) {
              //   p.searchOnStoppedTyping!.cancel();
              // }
              // p.searchOnStoppedTyping = Timer(p.duration, () async {});
            },
          ),
        );

    PreferredSizeWidget appBar() {
      return CustomAppBar.appBar(
        context,
        widget.userType.title,
        color: Colors.white,
        isCenter: true,
        titleSpacing: 24,
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        action: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () {
                if (widget.userType == UserDataType.BUYER) {
                  CusNav.nPush(context, CreateDataBuyerAdminView());
                } else if (widget.userType == UserDataType.SELLER) {
                  CusNav.nPush(context, CreateDataSellerAdminView());
                } else if (widget.userType == UserDataType.FINANCE) {
                  CusNav.nPush(context, CreateDataFinanceAdminView());
                } else if (widget.userType == UserDataType.PENERIMA) {
                  CusNav.nPush(context, CreateDataPenerimaAdminView());
                }
              },
              child: CircleAvatar(
                radius: 14,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffED1C24),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 27,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      );
    }

    Widget produkItem(int i) {
      final isSeller = widget.userType == UserDataType.SELLER;

      return Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Visibility(
              visible: isSeller,
              child: Row(
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xff6D7588),
                    ),
                  ),
                  Constant.xSizedBox12,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: model[i].status == 'Aktif'
                            ? Color(0xff28C76F).withOpacity(0.15)
                            : Color(0xffED1C24).withOpacity(0.15)),
                    child: Text(
                      model[i].status ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: model[i].status == 'Aktif'
                            ? Color(0xff28C76F)
                            : Color(0xffED1C24),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isSeller ? 'Nama' : 'First Name',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      SizedBox(
                        height: 4,
                      ),
                      Text(model[i].name1 ?? '-')
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isSeller ? 'Nama Pemilik' : 'Last Name',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      SizedBox(
                        height: 4,
                      ),
                      Text(model[i].name2 ?? '-')
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      SizedBox(
                        height: 4,
                      ),
                      Text(model[i].email ?? '-')
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alamat',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                SizedBox(
                  height: 4,
                ),
                Text(model[i].alamat ?? '-')
              ],
            ),
            Constant.xSizedBox12,
            Row(
              children: [
                Expanded(
                  child: CustomButton.secondaryButtonWithicon(
                    Image.asset(Assets.iconsIcAdminUbah),
                    'Ubah',
                    () {
                      if (widget.userType == UserDataType.BUYER) {
                        CusNav.nPush(
                            context,
                            CreateDataBuyerAdminView(
                                buyer: p.buyerAdminModel.data![i]));
                      }
                      if (widget.userType == UserDataType.SELLER) {
                        CusNav.nPush(
                            context,
                            CreateDataSellerAdminView(
                                seller: p.sellerAdminModel.data![i]));
                      }
                      if (widget.userType == UserDataType.FINANCE) {
                        CusNav.nPush(
                            context,
                            CreateDataFinanceAdminView(
                                keuangan: p.keuanganAdminModel.data![i]));
                      }
                      if (widget.userType == UserDataType.PENERIMA) {
                        CusNav.nPush(
                            context,
                            CreateDataPenerimaAdminView(
                                penerima: p.penerimaAdminModel.data![i]));
                      }
                    },
                    mainAxisAlignment: MainAxisAlignment.center,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    color: Color(0xff1ABC62),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Constant.xSizedBox12,
                Expanded(
                  child: CustomButton.secondaryButtonWithicon(
                    Image.asset(Assets.iconsIcAdminGantiSesi),
                    'Ganti Sesi',
                    () async {
                      if (widget.userType == UserDataType.BUYER) {
                        await p.changeSession(
                            context, p.buyerAdminModel.data?[i]?.ID ?? '');
                      }
                      if (widget.userType == UserDataType.SELLER) {
                        await p.changeSession(
                            context, p.sellerAdminModel.data?[i]?.ID ?? '');
                      }
                      if (widget.userType == UserDataType.FINANCE) {
                        await p.changeSession(
                            context, p.keuanganAdminModel.data?[i]?.ID ?? '');
                      }
                      if (widget.userType == UserDataType.PENERIMA) {
                        await p.changeSession(
                            context, p.penerimaAdminModel.data?[i]?.ID ?? '');
                      }
                    },
                    mainAxisAlignment: MainAxisAlignment.center,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    color: Color(0xffF58B2B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Constant.xSizedBox12,
                Expanded(
                  child: CustomButton.secondaryButtonWithicon(
                    Image.asset(Assets.iconsIcAdminHapus),
                    'Hapus',
                    () async {
                      await Utils.showYesNoDialog(
                        context: context,
                        title: 'Konfirmasi Hapus Data',
                        desc: 'Apakah Anda yakin ingin hapus data ini?',
                        yesCallback: () async {
                          CusNav.nPop(context);
                          p.deleteSeller(id: model[i].id ?? '');
                        },
                        noCallback: () {
                          CusNav.nPop(context);
                        },
                      );
                    },
                    mainAxisAlignment: MainAxisAlignment.center,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    color: Color(0xffED1C24),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await getData();
        },
        child: SafeArea(
          child: Container(
            color: Color(0xffF6F6F6),
            child: Column(
              children: [
                search(),
                Constant.xSizedBox8,
                Expanded(
                  child: ListView.separated(
                    itemCount: model.length,
                    itemBuilder: (c, i) {
                      return produkItem(i);
                    },
                    separatorBuilder: (_, __) => Constant.xSizedBox8,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum UserDataType {
  BUYER('Data Buyer'),
  SELLER('Data Seller'),
  FINANCE('Data Finance'),
  PENERIMA('Data Penerima');

  final String title;

  const UserDataType(this.title);
}

class UserData {
  final String? name1, name2, email, alamat, id, status;

  UserData(
      {this.name1, this.name2, this.email, this.alamat, this.id, this.status});
}
