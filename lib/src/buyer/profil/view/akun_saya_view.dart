import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_dropdown.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/src/auth/provider/auth_provider.dart';
import 'package:mspeed/src/auth/view/login_view.dart';
import 'package:mspeed/src/buyer/cart/provider/shopping_cart_provider.dart';
import 'package:mspeed/src/buyer/cart/view/shopping_cart_view.dart';
import 'package:mspeed/src/buyer/chat/view/chat_list_view.dart';
import 'package:mspeed/src/buyer/profil/model/akun_saya_buyer_model.dart';
import 'package:mspeed/src/buyer/profil/provider/profile_provider.dart';
import 'package:mspeed/src/buyer/profil/view/settings_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/utils.dart';
import '../../transaction/view/transaction_list_view.dart';

class AkunSayaView extends StatefulWidget {
  @override
  State<AkunSayaView> createState() => _AkunSayaViewState();
}

class _AkunSayaViewState extends BaseState<AkunSayaView> {
  String userId = "", userName = "", imgUrl = "";
  AkunSayaBuyerModel userModel = AkunSayaBuyerModel();

  List<Color> statusColor = [
    Color(0xFFF58B2B).withOpacity(.05),
    Color(0xFF9AD3BC).withOpacity(.15),
    Color(0xFF5397AA).withOpacity(.1),
    Color(0xFF5397AA).withOpacity(.05),
    Color(0xFFF3EAC2).withOpacity(.4),
    Color(0xFFE43532).withOpacity(.05),
  ];

  List<String> statusName = [
    "Pesanan Baru",
    "Pesanan Diterima",
    "Pesanan Dikirim",
    "Barang Diterima",
    "Proses Pembayaran ",
    "Telah Dibayar"
  ];

  List<String> imgStatus = [
    Assets.iconsImgAkunPesananbaru,
    Assets.iconsImgAkunPesananditerima,
    Assets.iconsImgAkunPesanandikirim,
    Assets.iconsImgAkunBarangditerima,
    Assets.iconsImgAkunProsespembayaran,
    Assets.iconsImgAkunTelahdibayar,
  ];

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    getName();
    userId = await prefs.getString(Constant.kSetPrefId) ?? "";
    final akunBuyer = context.read<ProfileProvider>().akunBuyerModel;
    if (akunBuyer.data == null ||
        akunBuyer.result == null ||
        akunBuyer.result != "success") {
      context.read<ProfileProvider>().fetchBuyer(
            context,
            withLoading: true,
            idBuyer: userId,
          );
    }

    final p = context.read<ProfileProvider>();
    List<String> years =
        List.generate(2024 - 1900 + 1, (index) => (1900 + index).toString());
    for (int i = years.length - 1; i >= 0; i--) {
      p.timeList?.add(years[i]);
    }
  }

  Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    userName = await prefs.getString(Constant.kSetPrefFirstName) ?? "";
    userName += " " + (await prefs.getString(Constant.kSetPrefLastName) ?? "");
    return userName;
  }

  @override
  Widget build(BuildContext context) {
    userModel = context.watch<ProfileProvider>().akunBuyerModel;
    final p = context.watch<ProfileProvider>();
    final cartTotal = context.watch<ShoppingCartProvider>().countQtyCartItem();

    Widget _buildOption(String title, String path, GestureTapCallback? onTap) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                  width: 18,
                  height: 18,
                  child: FittedBox(child: Image.asset(path))),
              Constant.xSizedBox8,
              Text(title),
            ],
          ),
        ),
      );
    }

    void _showLogoutBottomSheet(BuildContext context) {
      showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16), // Adjust this value as needed
          ),
        ),
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        CusNav.nPop(context);
                      },
                    ),
                    Text(
                      'Opsi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildOption(
                  'Login Admin',
                  Assets.imagesIcLoginAdmin,
                  () async {
                    handleTap(() async {
                      Utils.showYesNoDialog(
                        context: context,
                        title: "Konfirmasi",
                        desc: "Apakah Anda Yakin ingin kembali ke Admin",
                        yesCallback: () async {
                          handleTap(() async {
                            await context
                                .read<AdminUserProvider>()
                                .backToAdmin(context);
                          });
                        },
                        noCallback: () => CusNav.nPop(context),
                      );
                    });
                  },
                ),
                _buildOption(
                  'Logout',
                  Assets.imagesIcLogoutToAdmin,
                  () async {
                    handleTap(() async {
                      Utils.showYesNoDialog(
                        context: context,
                        title: "Konfirmasi",
                        desc: "Apakah Anda Yakin ingin keluar",
                        yesCallback: () async {
                          handleTap(() async {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (route) => false);
                          });
                        },
                        noCallback: () => CusNav.nPop(context),
                      );
                    });
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    }

    harian() async {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (_) {
          final size = MediaQuery.of(context).size;
          return Container(
            color: Colors.white,
            height: size.height * 0.55,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Constant.grayColor.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Per Hari',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      InkWell(
                        onTap: () {
                          context.read<ProfileProvider>().fetchBuyer(
                                context,
                                withLoading: true,
                                idBuyer: userId,
                              );
                          CusNav.nPop(context);
                        },
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Constant.grayColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Constant.xSizedBox12,
                Container(
                  height: 200,
                  child: CupertinoDatePicker(
                    initialDateTime: DateTime.now(),
                    mode: CupertinoDatePickerMode.date,
                    use24hFormat: true,
                    // This is called when the user changes the time.
                    onDateTimeChanged: (DateTime newTime) {
                      p.selectedDate = newTime;
                      p.selectedMonth = newTime.month.toString();
                      p.selectedYear = newTime.year.toString();
                      setState(() {});
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomButton.mainButton('Konfirmasi',
                      borderRadius: BorderRadius.circular(10), () async {
                    handleTap(() async {
                      CusNav.nPop(context);
                    });
                  }),
                )
              ],
            ),
          );
        },
      );
    }

    bulanan() async {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (_) {
          final size = MediaQuery.of(context).size;
          return Container(
            color: Colors.white,
            height: size.height * 0.55,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Constant.grayColor.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Per Bulan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      InkWell(
                        onTap: () {
                          context.read<ProfileProvider>().fetchBuyer(
                                context,
                                withLoading: true,
                                idBuyer: userId,
                              );
                          CusNav.nPop(context);
                        },
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Constant.grayColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Constant.xSizedBox12,
                Container(
                  height: 200,
                  child: CupertinoDatePicker(
                    // Menggunakan DateTime.now() langsung untuk memulai dari bulan dan tahun sekarang
                    initialDateTime: DateTime.now(),
                    mode: CupertinoDatePickerMode.monthYear,
                    use24hFormat: true,
                    // Fungsi ini dipanggil ketika pengguna mengubah bulan/tahun
                    onDateTimeChanged: (DateTime newTime) {
                      setState(() {
                        p.selectedDate = newTime;
                        p.selectedMonth = newTime.month.toString();
                        p.selectedYear = newTime.year.toString();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomButton.mainButton('Konfirmasi',
                      borderRadius: BorderRadius.circular(10), () async {
                    handleTap(() async {
                      CusNav.nPop(context);
                    });
                  }),
                )
              ],
            ),
          );
        },
      );
    }

    tahunan() async {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (_) {
          final size = MediaQuery.of(context).size;
          return Container(
            color: Colors.white,
            height: size.height * 0.55,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Constant.grayColor.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Per Tahun',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      InkWell(
                        onTap: () {
                          context.read<ProfileProvider>().fetchBuyer(
                                context,
                                withLoading: true,
                                idBuyer: userId,
                              );
                          CusNav.nPop(context);
                        },
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Constant.grayColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Constant.xSizedBox12,
                Container(
                  height: 200.0,
                  child: Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Flexible(
                        flex: 10,
                        child: CupertinoPicker(
                            itemExtent: 38,
                            onSelectedItemChanged: (int index) {
                              setState(() {
                                p.selectedYear = p.timeList![index];
                              });
                            },
                            children: (p.timeList ?? [])
                                .map((item) => Center(
                                    child: Text(item,
                                        style: TextStyle(fontSize: 20))))
                                .toList()),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomButton.mainButton('Konfirmasi',
                      borderRadius: BorderRadius.circular(10), () async {
                    handleTap(() async {
                      CusNav.nPop(context);
                    });
                  }),
                )
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(context, "Akun Saya",
          isCenter: true,
          leading: SizedBox(),
          color: Colors.white,
          action: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShoppingCartView()));
              },
              icon: Badge(
                isLabelVisible: cartTotal == 0 ? false : true,
                label: Text('$cartTotal'),
                offset: Offset(8, -4),
                backgroundColor: Colors.redAccent,
                child: SvgPicture.asset(Assets.svgsIcCart,
                    width: 24, color: Colors.black),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatListView()),
                );
              },
              icon: Badge(
                isLabelVisible: true,
                label: const Text("2"),
                offset: const Offset(8, -4),
                backgroundColor: Colors.redAccent,
                child: SvgPicture.asset(
                  Assets.svgsIcChat,
                  width: 24,
                ),
              ),
            )
          ]),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProfileProvider>().fetchBuyer(
                context,
                withLoading: true,
                idBuyer: userId,
              );
        },
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            NetworkImage('https://placehold.co/400x400.jpg'),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<String>(
                            future: getName(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                String userName = snapshot.data!;
                                return Text(
                                  userName,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                );
                              } else {
                                return Text('-');
                              }
                            },
                          ),
                          Text(
                            'Berikut ringkasan Transaksi Anda',
                            style: TextStyle(
                              fontSize: 12,
                              color: Constant.grayColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  CustomDropdown.normalDropdown(
                    selectedItem: p.selectedPeriodeData,
                    list: p.periodeData.entries
                        .map((item) => DropdownMenuItem(
                              child: Text(
                                item.key,
                                style: TextStyle(color: Constant.primaryColor),
                              ),
                              value: item.value,
                            ))
                        .toList(),
                    onChanged: (v) async {
                      if (v == 'Periode Data Harian') await harian();
                      if (v == 'Periode Data Bulanan') await bulanan();
                      if (v == 'Periode Data Tahunan') await tahunan();
                      p.selectedPeriodeData = v;
                      await context.read<ProfileProvider>().fetchAkunSaya(
                            context,
                            withLoading: true,
                            idBuyer: userId,
                          );
                    },
                    borderColor: Constant.primaryColor,
                    activeBorderColor: Constant.primaryColor,
                    iconColor: Constant.primaryColor,
                    borderWidth: 1,
                    activeBorderWidth: 1,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      itemBuilder: (context, int index) {
                        List<String> statusCount = [
                          userModel.data?.pesananBaru ?? '0',
                          userModel.data?.pesananDiterima ?? '0',
                          userModel.data?.pesananDikirim ?? '0',
                          userModel.data?.barangDiterima.toString() ?? '0',
                          userModel.data?.prosesPembayaran.toString() ?? '0',
                          userModel.data?.telahDibayar ?? '0',
                        ];
                        return Container(
                          height: 40,
                          padding: EdgeInsets.only(right: 16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: statusColor[index],
                                child: Image.asset(
                                  height: 24,
                                  imgStatus[index],
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    statusCount[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    statusName[index],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF6D7588),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  pesananGrid(),
                  SizedBox(height: 20),
                  ListTile(
                    leading: SvgPicture.asset(Assets.svgsIcTransaksi),
                    title: Text('Transaksi'),
                    onTap: () {
                      CusNav.nPush(context, TransactionListView());
                    },
                  ),
                  Divider(color: Colors.blueGrey[50]),
                  ListTile(
                    leading: SvgPicture.asset(Assets.svgsIcPengaturanAkun),
                    title: Text('Pengaturan Akun'),
                    onTap: () {
                      CusNav.nPush(context, SettingsView());
                    },
                  ),
                  Divider(color: Colors.blueGrey[50]),
                  ListTile(
                    leading: SvgPicture.asset(Assets.svgsIcLogout),
                    title: Text('Logout'),
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      final isAdmin =
                          await prefs.getBool(Constant.kSetPrefIsAdmin) ??
                              false;
                      if (isAdmin) {
                        _showLogoutBottomSheet(context);
                      } else {
                        handleTap(() async {
                          Utils.showYesNoDialog(
                            context: context,
                            title: "Konfirmasi",
                            desc: "Apakah Anda Yakin ingin Keluar",
                            yesCallback: () async {
                              handleTap(() async {
                                await context.read<AuthProvider>().logout();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginView()),
                                  (Route<dynamic> route) => false,
                                );
                              });
                            },
                            noCallback: () {
                              Navigator.pop(context);
                            },
                          );
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget pesananRow() {
    Widget buildRowItem(String count, String label, String icon, Color color) {
      return Container(
        width: 120,
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icon, width: 32),
              SizedBox(height: 10),
              Text(
                count.toString(),
                style: Constant.blackBold16,
              ),
              Text(
                label,
                style: TextStyle(color: Constant.darkGrayColor, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        child: Row(
          children: [
            InkWell(
              onTap: () {
                CusNav.nPush(context, TransactionListView());
              },
              child: buildRowItem(
                  '2',
                  'Pesanan Baru',
                  Assets.iconsImgAkunPesananbaru,
                  Color(0xFFF58B2B).withOpacity(.05)),
            ),
            buildRowItem(
                userModel.data?.pesananDiterima ?? "0",
                'Pesanan Diterima',
                Assets.iconsImgAkunPesananditerima,
                Color(0xFF9AD3BC).withOpacity(.15)),
            buildRowItem(
                userModel.data?.pesananDikirim ?? "0",
                'Pesanan Dikirim',
                Assets.iconsImgAkunPesanandikirim,
                Color(0xFF5397AA).withOpacity(.1)),
            buildRowItem(
                userModel.data?.barangDiterima.toString() ?? "0",
                'Barang Diterima',
                Assets.iconsImgAkunBarangditerima,
                Color(0xFF5397AA).withOpacity(.05)),
            buildRowItem(
                userModel.data?.prosesPembayaran.toString() ?? "0",
                'Proses Pembayaran',
                Assets.iconsImgAkunProsespembayaran,
                Color(0xFFF3EAC2).withOpacity(.4)),
            buildRowItem(
                userModel.data?.telahDibayar ?? "0",
                'Telah Dibayar',
                Assets.iconsImgAkunTelahdibayar,
                Color(0xFFE43532).withOpacity(.05)),
          ],
        ),
      ),
    );
  }

  Widget pesananGrid() {
    Widget _buildGridItem(
        String count, String label, String icon, Color color) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(icon, width: 32),
                SizedBox(height: 10),
                Text(
                  count.toString(),
                  style: Constant.blackBold16,
                ),
                Text(label,
                    style:
                        TextStyle(color: Constant.darkGrayColor, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: .7,
          children: [
            InkWell(
              onTap: () {
                CusNav.nPush(
                  context,
                  TransactionListView(
                    initialRoute: 0,
                  ),
                );
              },
              child: _buildGridItem(
                profileProvider.formatRupiah(
                  userModel.data?.totalPesananPrice ?? "0",
                ),
                'Total Pesanan',
                Assets.iconsImgAkunPesananbaru,
                Color(0xFFF58B2B).withOpacity(.05),
              ),
            ),
            InkWell(
              onTap: () {
                CusNav.nPush(
                    context,
                    TransactionListView(
                      initialRoute: 1,
                    ));
              },
              child: _buildGridItem(
                profileProvider.formatRupiah(
                  userModel.data?.pesananDitolakPrice ?? "0",
                ),
                'Pesanan Ditolak',
                Assets.iconsImgAkunPesananditerima,
                Color(0xFF9AD3BC).withOpacity(.15),
              ),
            ),
            InkWell(
              onTap: () {
                CusNav.nPush(
                  context,
                  TransactionListView(
                    initialRoute: 2,
                  ),
                );
              },
              child: _buildGridItem(
                  profileProvider.formatRupiah(
                    userModel.data?.pesananBaruPrice ?? "0",
                  ),
                  'Pesanan Baru',
                  Assets.iconsImgAkunPesanandikirim,
                  Color(0xFF5397AA).withOpacity(.1)),
            ),
            InkWell(
              onTap: () {
                CusNav.nPush(
                  context,
                  TransactionListView(
                    initialRoute: 3,
                  ),
                );
              },
              child: _buildGridItem(
                profileProvider.formatRupiah(
                  userModel.data?.pesananDiterimaPrice ?? "0",
                ),
                'Pesanan Diterima',
                Assets.iconsImgAkunBarangditerima,
                Color(0xFF5397AA).withOpacity(.05),
              ),
            ),
            InkWell(
              onTap: () {
                CusNav.nPush(
                    context,
                    TransactionListView(
                      initialRoute: 4,
                    ));
              },
              child: _buildGridItem(
                profileProvider.formatRupiah(
                  userModel.data?.pesananDikirimPrice ?? "0",
                ),
                'Pesanan Dikirim',
                Assets.iconsImgAkunProsespembayaran,
                Color(0xFFF3EAC2).withOpacity(.4),
              ),
            ),
            InkWell(
              onTap: () {
                CusNav.nPush(
                    context,
                    TransactionListView(
                      initialRoute: 5,
                    ));
              },
              child: _buildGridItem(
                profileProvider.formatRupiah(
                  '${userModel.data?.barangDiterimaPrice ?? 0}',
                ),
                'Barang / Jasa Diterima',
                Assets.iconsImgAkunTelahdibayar,
                Color(0xFFE43532).withOpacity(.05),
              ),
            ),
            InkWell(
              onTap: () {
                CusNav.nPush(
                  context,
                  TransactionListView(
                    initialRoute: 0,
                  ),
                );
              },
              child: _buildGridItem(
                profileProvider.formatRupiah(
                  '${userModel.data?.siapTagihPrice ?? 0}',
                ),
                'Siap Tagih',
                Assets.iconsImgAkunPesananbaru,
                Color(0xFFF58B2B).withOpacity(.05),
              ),
            ),
            InkWell(
              onTap: () {
                CusNav.nPush(
                    context,
                    TransactionListView(
                      initialRoute: 1,
                    ));
              },
              child: _buildGridItem(
                profileProvider.formatRupiah(
                  '${userModel.data?.prosesPembayaranPrice ?? 0}',
                ),
                'Penerimaan & Verifikasi',
                Assets.iconsImgAkunPesananditerima,
                Color(0xFF9AD3BC).withOpacity(.15),
              ),
            ),
            InkWell(
              onTap: () {
                CusNav.nPush(
                  context,
                  TransactionListView(
                    initialRoute: 2,
                  ),
                );
              },
              child: _buildGridItem(
                  profileProvider.formatRupiah(
                    '${userModel.data?.telahDibayarPrice ?? 0}',
                  ),
                  'Telah Dibayar',
                  Assets.iconsImgAkunPesanandikirim,
                  Color(0xFF5397AA).withOpacity(.1)),
            ),
          ],
        );
      },
    );
  }
}
