import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_container.dart';
import 'package:mspeed/common/component/custom_searchbar.dart';
import 'package:mspeed/src/buyer/home/provider/home_provider.dart';
import 'package:mspeed/src/buyer/notifikasi/provider/notifikasi_buyer_provider.dart';
import 'package:mspeed/src/buyer/notifikasi/view/notifikasi_view.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/helper/constant.dart';
import '../../../../common/helper/xenolog.dart';
import '../../../../utils/utils.dart';
import '../../../auth/provider/auth_provider.dart';

class HomeView extends StatefulWidget {
  static String thousandSeparator(int val) {
    return NumberFormat.currency(locale: "in_ID", symbol: '', decimalDigits: 0)
        .format(val);
  }

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends BaseState<HomeView> {
  TextEditingController searchC = TextEditingController();
  String? name = "";
  String? jenis = "";

  @override
  void initState() {
    setData();
    getData();
    super.initState();
  }

  getData() async {
    // loading(true);
    await context.read<HomeProvider>().fetchHome();
    // loading(false);
  }

  setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString(Constant.kSetPrefFirstName);
      jenis = prefs.getString(Constant.kSetPrefRoles);
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeP = context.watch<HomeProvider>();
    final authP = context.watch<AuthProvider>();
    final notifP = context.watch<NotifikasiBuyerProvider>();

    Widget header() {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            'Home',
            style: Constant.primaryTextStyle
                .copyWith(fontSize: 18, color: Colors.white),
          ),
        ),
      );
    }

    Widget account() {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: InkWell(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();

            final roles = prefs.getString(Constant.kSetPrefRoles);
            // Navigator.push(context, MaterialPageRoute(
            //   builder: (context) {
            //     if (roles == "agen") {
            //       return KomisiAgenView();
            //     }
            //     return KomisiSubAgenView(
            //         adminId: home.homeModel.data?.user?.id ?? 0);
            //   },
            // ));
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 6,
                child: InkWell(
                  onLongPress: () async {
                    // if (kDebugMode) {
                    XenoLog("1",
                            logType: XenoLogType.Database,
                            projectName: '',
                            version: '',
                            webHookURL: '',
                            emailAddress: '')
                        .showLogDialog(context: context);
                    // }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name ?? "", style: Constant.primaryBold20),
                      SizedBox(height: 4),
                      Text(jenis ?? "", style: Constant.grayMedium13),
                      // Text("961121046", style: Constant.grayMedium13),
                    ],
                  ),
                ),
              ),

              // lama
              // CircleAvatar(
              //   radius: 28,
              //   backgroundColor: Colors.white,
              //   child: CircleAvatar(
              //     radius: 26,
              //     backgroundImage: NetworkImage(
              //         '${home.getHomeModel.data?.user?.photoPath ?? ""}'),
              //   ),
              // )
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotificationView()));
                        },
                        icon: Badge(
                          isLabelVisible:
                              (notifP.notifikasiModel.data?.length ?? 0) != 0,
                          backgroundColor: Constant.redColor,
                          label: Text(
                              "${notifP.notifikasiModel.data?.length ?? 0}"),
                          child: Icon(
                            Icons.notifications,
                            color: Colors.grey,
                          ),
                        )),
                    Builder(
                      builder: (BuildContext context) {
                        return IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: Colors.grey,
                          ),
                          onPressed: () => Scaffold.of(context).openEndDrawer(),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }

    Widget subMenu() {
      return Container(
        height: 82,
        margin: EdgeInsets.only(top: 14, left: 20, right: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 3,
              child: CustomContainer.mainCard(
                  color: Constant.blueColor,
                  image: DecorationImage(
                    image: AssetImage('assets/images/img-total-alat.png'),
                    fit: BoxFit.cover,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset('assets/icons/ic-total-alat.png',
                          width: 30, height: 30),
                      SizedBox(width: 5),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                "Total Alat",
                                style: Constant.whiteRegular12,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Constant.xSizedBox4,
                            Flexible(
                              child: Text(
                                homeP.getHomeModel.data?.first?.totalAsset ??
                                    "0",
                                style: Constant.whiteBold16,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
            ),
            SizedBox(width: 12),
            Flexible(
              flex: 3,
              child: CustomContainer.mainCard(
                  color: Constant.greenColor,
                  image: DecorationImage(
                    image: AssetImage('assets/images/img-ready.png'),
                    fit: BoxFit.cover,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset('assets/icons/ic-ready.png',
                          width: 30, height: 30),
                      SizedBox(width: 5),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                "Ready",
                                style: Constant.whiteRegular12,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Constant.xSizedBox4,
                            Flexible(
                              child: Text(
                                homeP.getHomeModel.data?.first?.ready ?? "0",
                                style: Constant.whiteBold16,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
            ),
            SizedBox(width: 12),
            Flexible(
              flex: 3,
              child: CustomContainer.mainCard(
                  color: Constant.redColor,
                  image: DecorationImage(
                    image: AssetImage('assets/images/img-not-ready.png'),
                    fit: BoxFit.cover,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset('assets/icons/ic-not-ready.png',
                          width: 30, height: 30),
                      SizedBox(width: 5),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                "Not Ready",
                                style: Constant.whiteRegular12,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Constant.xSizedBox4,
                            Flexible(
                              child: Text(
                                homeP.getHomeModel.data?.first?.notReady ?? "0",
                                style: Constant.whiteBold16,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
            ),
          ],
        ),
      );
    }

    Widget totalAlat() {
      return Column(children: [
        //total alat
        Container(
          margin: EdgeInsets.only(top: 10, left: 20, right: 20),
          padding: EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 7,
                    offset: Offset(0, 1))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    'Total Alat',
                    style: Constant.grayBold16
                        .copyWith(color: Constant.darkGrayColor),
                  ),
                ),
              ),
              Text("Cabang 1"),
              SizedBox(
                height: 5,
              ),
              LinearProgressIndicator(
                value: 1,
                minHeight: 8,
              ),
              SizedBox(height: 10),
              Text("Cabang 2"),
              SizedBox(
                height: 5,
              ),
              LinearProgressIndicator(
                value: 0.7,
                minHeight: 8,
              ),
              SizedBox(height: 10),
              Text("Cabang 3"),
              SizedBox(
                height: 5,
              ),
              LinearProgressIndicator(
                value: 0.5,
                minHeight: 8,
              ),
              SizedBox(height: 10),
              Text("Cabang 4"),
              SizedBox(
                height: 5,
              ),
              LinearProgressIndicator(
                value: 0.8,
                minHeight: 8,
              ),
              SizedBox(height: 10),
              Text("Cabang 5"),
              SizedBox(
                height: 5,
              ),
              LinearProgressIndicator(
                value: 0.3,
                minHeight: 8,
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ]);
    }

    Widget alatReady() {
      return Column(children: [
        //ready
        Container(
          margin: EdgeInsets.only(top: 10, left: 20, right: 20),
          padding: EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 7,
                    offset: Offset(0, 1))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    'Ready',
                    style: Constant.grayBold16
                        .copyWith(color: Constant.darkGrayColor),
                  ),
                ),
              ),
              Text("Cabang 1"),
              SizedBox(
                height: 5,
              ),
              LinearProgressIndicator(
                value: 1,
                minHeight: 8,
                color: Colors.green.shade800,
              ),
              SizedBox(height: 10),
              Text("Cabang 2"),
              SizedBox(
                height: 5,
              ),
              LinearProgressIndicator(
                value: 0.7,
                minHeight: 8,
                color: Colors.green.shade800,
              ),
              SizedBox(height: 10),
              Text("Cabang 3"),
              SizedBox(
                height: 5,
              ),
              LinearProgressIndicator(
                value: 0.5,
                minHeight: 8,
                color: Colors.green.shade800,
              ),
              SizedBox(height: 10),
              Text("Cabang 4"),
              SizedBox(
                height: 5,
              ),
              LinearProgressIndicator(
                value: 0.8,
                minHeight: 8,
                color: Colors.green.shade800,
              ),
              SizedBox(height: 10),
              Text("Cabang 5"),
              SizedBox(
                height: 5,
              ),
              LinearProgressIndicator(
                value: 0.3,
                minHeight: 8,
                color: Colors.green.shade800,
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ]);
    }

    Widget alatNoReady() {
      return Column(children: [
        //ready
        Container(
          margin: EdgeInsets.only(top: 10, left: 20, right: 20),
          padding: EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 7,
                    offset: Offset(0, 1))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    'Not Ready',
                    style: Constant.grayBold16
                        .copyWith(color: Constant.darkGrayColor),
                  ),
                ),
              ),
              Text("Cabang 1"),
              SizedBox(
                height: 5,
              ),
              LinearProgressIndicator(
                value: 1,
                minHeight: 8,
                color: Colors.red,
              ),
              SizedBox(height: 10),
              Text("Cabang 2"),
              SizedBox(
                height: 5,
              ),
              LinearProgressIndicator(
                value: 0.7,
                minHeight: 8,
                color: Colors.red,
              ),
              SizedBox(height: 10),
              Text("Cabang 3"),
              SizedBox(
                height: 5,
              ),
              LinearProgressIndicator(
                value: 0.5,
                minHeight: 8,
                color: Colors.red,
              ),
              SizedBox(height: 10),
              Text("Cabang 4"),
              SizedBox(
                height: 5,
              ),
              LinearProgressIndicator(
                value: 0.8,
                minHeight: 8,
                color: Colors.red,
              ),
              SizedBox(height: 10),
              Text("Cabang 5"),
              SizedBox(
                height: 5,
              ),
              LinearProgressIndicator(
                value: 0.3,
                minHeight: 8,
                color: Colors.red,
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ]);
    }

    Widget myDrawer() {
      return Drawer(
        child: Container(
          padding: EdgeInsets.fromLTRB(40, 100, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name ?? "-", style: Constant.primaryBold20),
              SizedBox(height: 10),
              Text(jenis ?? "-",
                  style: Constant.grayRegular13.copyWith(fontSize: 14)),
              SizedBox(height: 20),
              Divider(thickness: 1, color: Colors.grey.shade300),
              SizedBox(height: 20),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.data?.version ?? "";
                  return Text("App version $version",
                      style: Constant.grayRegular12);
                },
              ),
              SizedBox(height: 40),
              CustomButton.logoutButton(
                "Logout",
                () async {
                  await Utils.showYesNoDialog(
                    context: context,
                    title: "Konfirmasi",
                    desc: "Apakah Anda Yakin Ingin Keluar?",
                    yesCallback: () => handleTap(() async {
                      Navigator.pop(context);
                      try {
                        final result =
                            await context.read<AuthProvider>().logout();
                        // if (result.result == 'success') {
                        // home.setHomeModel = HomeModel();
                        Navigator.pushReplacementNamed(context, '/login');
                        // } else {
                        //   Utils.showFailed(msg: result.message);
                        // }
                      } catch (e) {
                        Utils.showFailed(
                            msg: e.toString().toLowerCase().contains("doctype")
                                ? "Maaf, Terjadi Galat!"
                                : "$e");
                      }
                    }),
                    noCallback: () => Navigator.pop(context),
                  );
                },
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          child: AppBar(
            titleSpacing: 0,
            title: CustomSearchBar.searchBarProduct(
                controller: searchC, onTap: () {}),
          ),
        ),
      ),
      backgroundColor: Colors.black,
      endDrawer: myDrawer(),
      body: SafeArea(
        top: true,
        child: Container(
          color: Colors.white,
          child: RefreshIndicator(
            color: Constant.primaryColor,
            onRefresh: () async {
              await context.read<HomeProvider>().fetchHome(withLoading: true);
              await context.read<NotifikasiBuyerProvider>().unreadCount;
            },
            child: ListView(
              children: [
                header(),
                account(),
                subMenu(),
                totalAlat(),
                alatReady(),
                alatNoReady(),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
