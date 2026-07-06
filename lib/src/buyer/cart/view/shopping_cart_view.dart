import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_container.dart';
import 'package:mspeed/common/component/custom_dialog.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/safe_network_image.dart';
import 'package:mspeed/common/helper/text_editing_formatter.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/buyer/cart/provider/shopping_cart_provider.dart';
import 'package:mspeed/src/buyer/chat/view/chat_person_view.dart';
import 'package:mspeed/src/keuangan/home/view/main_home_keuangan_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:string_validator/string_validator.dart';
import '../../../../common/component/custom_button.dart';
import '../../../../common/component/custom_textField.dart';
import '../../../../common/helper/constant.dart';
import '../../../../common/base/base_state.dart';
import '../../../../utils/utils.dart';

/// This is the `ShoppingCartView` class.
/// It is a stateful widget that represents the shopping cart view.
/// It displays a list of items in the shopping cart along with their details.
/// Users can increment or decrement the quantity of each item.
/// They can also select a voucher to apply to their purchase.
class ShoppingCartView extends StatefulWidget {
  const ShoppingCartView({super.key});

  @override
  State<ShoppingCartView> createState() => _ShoppingCartViewState();
}

/// This is the private `_ShoppingCartViewState` class.
/// It extends the `BaseState` class and represents the state of the `ShoppingCartView`.
/// It keeps track of the counter for each item and provides methods to increment or decrement the counter.
class _ShoppingCartViewState extends BaseState<ShoppingCartView> {
  int counter = 0;
  String userId = "";
  String subditId = "";

  @override
  void initState() {
    getData();
    context.read<ShoppingCartProvider>().clearAllCart();
    super.initState();
  }

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = await prefs.getString(Constant.kSetPrefId) ?? "";
    subditId = await prefs.getString(Constant.kSetPrefSubditId) ?? "";
    // userId = "148";
    await context
        .read<ShoppingCartProvider>()
        .fetchShoppingCart(context, withLoading: true);
    await context.read<ShoppingCartProvider>().fetchSubdit(context);

    // log("ISINYA KSET SUBDIT : ${subditId}");
  }

  /// Increments the counter by 1.
  void increment() {
    setState(() {
      counter++;
    });
  }

  /// Decrements the counter by 1, if the counter is greater than 0.
  void decrement() {
    setState(() {
      if (counter > 0) {
        counter--;
      }
    });
  }

  void dispose() {
    // Hapus sumber daya yang tidak perlu disimpan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final voucherP = context.read<VoucherProvider>();
    final cartP = context.watch<ShoppingCartProvider>();

    void _subditBottomSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  ...List.generate(cartP.getSubditModel.data?.length ?? 0,
                      (index) {
                    final item = cartP.getSubditModel.data?[index];
                    return InkWell(
                      onTap: () async {
                        cartP.selectedSubditModel = item;
                        await cartP.setSubditDpp(context,
                            dppId: item?.ID ?? '-');
                        CusNav.nPop(context);
                        // log("SelectedISI :" +
                        //     (cartP.selectedSubditModel?.ID ?? ""));
                        setState(() {});
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item?.judul ?? "-",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w400),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item?.nomorPermintaan ?? "-",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    Utils.thousandSeparator(
                                        double.parse(item?.sisa ?? "-")
                                            .toInt()),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Color(0xFFEFB3C8).withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  item?.subditName ?? "-",
                                  textAlign: TextAlign.center,
                                  style: Constant.iPrimaryMedium12,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );
    }

    void _tambahCatatan(
        BuildContext context, int index, int indexx, String produkId) {
      CustomDialog.mainDialog(
          context: context,
          title: "",
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  CustomTextField.borderTextArea(
                    controller: cartP.catatanListC[index][indexx],
                    required: false,
                    labelText: "Masukan Catatan",
                    hintText: "Masukan Catatan",
                    textInputType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    focusNode: cartP.catatanNode,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CustomButton.mainButton("Simpan Catatan",
                      borderRadius: BorderRadius.circular(10), () async {
                    setState(() {
                      cartP.sendCatatan(context,
                          index: index, indexx: indexx, productId: produkId);
                    });
                    CusNav.nPop(context);
                  }),
                ],
              ),
            ),
          ));
    }

    _historyNego(BuildContext context) {
      CustomDialog.newDialog(
          context: context,
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          title: Row(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Text(
                "Riwayat Nego",
                style: Constant.iBlackMedium16,
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                    cartP.getRiwayatNegoModel.data?.length ?? 0, (index) {
                  return cartP.getRiwayatNegoModel.data?[index]?.nego != null
                      ? CustomContainer.mainCard(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: SafeNetworkImage(
                                      url: cartP.getRiwayatNegoModel
                                              .data?[index]?.foto ??
                                          "",
                                      width: double.minPositive,
                                      height: 50,
                                      errorBuilder: Image.asset(
                                          Assets.imagesMainImageNotFound),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      cartP.getRiwayatNegoModel.data?[index]
                                              ?.nama ??
                                          "-",
                                      style: Constant.iBlackMedium16.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          Utils.thousandSeparator(int.parse(
                                              (cartP.getRiwayatNegoModel
                                                          .data?[index]?.nego ??
                                                      "-")
                                                  .replaceAll(".", ""))),
                                          style: Constant.iBlackMedium16
                                              .copyWith(fontSize: 14),
                                        ),
                                        Text(
                                          cartP.getRiwayatNegoModel.data?[index]
                                                  ?.fixstatus ??
                                              "Menunggu",
                                          style: Constant.greyThrough12
                                              .copyWith(
                                                  color:
                                                      Constant.textPriceColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ))
                      : SizedBox();
                }),
              ),
            ),
          ));
    }

    void _negoHarga(
        BuildContext context, int index, int indexx, String produkId) {
      CustomDialog.mainDialog(
          context: context,
          title: "",
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  CustomTextField.borderTextField(
                      controller: cartP.negoListC[index][indexx],
                      required: false,
                      labelText: "Masukan nego Harga",
                      hintText: "Masukan Nego",
                      textInputType: TextInputType.number,
                      textCapitalization: TextCapitalization.words,
                      focusNode: cartP.negoNode,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ]),
                  SizedBox(
                    height: 20,
                  ),
                  CustomButton.mainButton("Simpan Nego",
                      borderRadius: BorderRadius.circular(10), () async {
                    setState(() async {
                      if (int.parse(cartP.negoListC[index][indexx].text
                              .replaceAll(".", "")) >=
                          int.parse((cartP.shoppingCartModel.data?[index]
                                      ?.detail?[indexx]?.hargaAwal ??
                                  "")
                              .replaceAll(".", ""))) {
                        await Utils.showFailed(
                            msg: "Nego harga melebihi harga awal produk!");
                      } else {
                        await cartP.sendNego(context,
                            index: index, indexx: indexx, productId: produkId);
                        await CusNav.nPop(context);
                      }
                    });
                    CusNav.nPop(context);
                  }),
                ],
              ),
            ),
          ));
    }

    Widget kontenCart() {
      // bool isChecked = false;
      // log("ISINYA" : "${cartP.getShoppingCartModel.data?.first?.}")
      return ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.all(16),
        separatorBuilder: (_, __) => SizedBox(height: 5),
        itemCount: cartP.getShoppingCartModel.data?.length ?? 0,
        itemBuilder: (context, index) {
          final item = (cartP.getShoppingCartModel.data ?? [])[index];
          // Check if item and its details are not null or empty
          if (item == null || item.detail == null || item.detail!.isEmpty) {
            // [EDIT]
            return Container(); // Return an empty container if item or its details are null/empty [EDIT]
          }
          return Column(
            children: [
              ExpansionTile(
                  leading: Container(
                      color: Colors.white,
                      width: 20,
                      height: 20,
                      child: Theme(
                        data: ThemeData(
                            checkboxTheme: CheckboxThemeData(
                                side: BorderSide(
                                    color: Colors.grey, width: 0.8))),
                        child: Checkbox(
                          value: cartP.storeListCheck[index],
                          // cartP.itemListCheck[index]
                          // [indexx],
                          // fillColor: MaterialStateProperty.all(
                          //     Constant.primaryColor),
                          // overlayColor:
                          //     MaterialStateProperty.all(
                          //         Constant.borderLightColor),
                          // checkColor: Colors.white,
                          activeColor: Constant.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: BorderSide(width: 0.1, color: Colors.grey),
                          ),
                          onChanged: (check) {
                            if (cartP.selectedStoreId != null &&
                                cartP.selectedStoreId != item.SellerID) {
                              cartP.clearStoreListCheck();
                              cartP.clearListCheck();
                            }
                            cartP.selectedStoreId = item.SellerID ?? "0";
                            cartP.storeListCheck[index] = check ?? false;
                            for (int i = 0;
                                i < cartP.itemListCheck[index].length;
                                i++) {
                              cartP.itemListCheck[index][i] = check ?? false;
                            }
                            // if (!cartP.itemListCheck.any((e)=>e == true) && cartP.itemListCheck[index].contains(false)) {
                            //   cartP.storeListCheck[index] = false;
                            // }
                            // else if(!cartP.itemListCheck.any((e)=>e == false) && cartP.itemListCheck[index].contains(true)){
                            //   cartP.storeListCheck[index] = true;
                            // }
                            setState(() {});
                          },
                        ),
                      )),
                  tilePadding: EdgeInsets.zero,
                  title: Text(item.namaseller ?? ""),
                  maintainState: true,
                  // Agar tile tidak bisa dikurangi
                  initiallyExpanded: true,
                  // Agar tile terbuka secara otomatis
                  trailing: SizedBox.shrink(),
                  // Menghilangkan ikon bawaan
                  // onExpansionChanged: (isExpanded) {}, // Fungsi kosong untuk mencegah mengecilkan
                  children: List.generate((item.detail?.length ?? 0), (indexx) {
                    final prodItem = item.detail?[indexx];
                    bool condition = ((prodItem?.statusNego == null &&
                            prodItem?.nego == null) ||
                        (prodItem?.nego2 != null && prodItem?.nego3 == null) &&
                            (prodItem?.statusNego == null));
                    return Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(bottom: 15),
                      child: InkWell(
                        onTap: () async {
                          // await Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (c) => ProductDetailView(
                          //             id: (cartP.getShoppingCartModel.data
                          //                         ?[index])
                          //                     ?.detail?[indexx]
                          //                     ?.ID ??
                          //                 0)));
                          // getData();
                        },
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    children: [
                                      // Container(
                                      //     color: Colors.white,
                                      //     width: 20,
                                      //     height: 20,
                                      //     child: Theme(
                                      //       data: ThemeData(
                                      //           checkboxTheme:
                                      //               CheckboxThemeData(
                                      //                   side: BorderSide(
                                      //                       color: Colors.grey,
                                      //                       width: 0.8))),
                                      //       child: Checkbox(
                                      //         value: cartP.itemListCheck[index]
                                      //             [indexx],
                                      //         // fillColor: MaterialStateProperty.all(
                                      //         //     Constant.primaryColor),
                                      //         // overlayColor:
                                      //         //     MaterialStateProperty.all(
                                      //         //         Constant.borderLightColor),
                                      //         // checkColor: Colors.white,
                                      //         activeColor:
                                      //             Constant.primaryColor,
                                      //         shape: RoundedRectangleBorder(
                                      //           borderRadius:
                                      //               BorderRadius.circular(4),
                                      //           side: BorderSide(
                                      //               width: 0.1,
                                      //               color: Colors.grey),
                                      //         ),
                                      //         onChanged: (check) {
                                      //           if (cartP.selectedStoreId != null && cartP.selectedStoreId !=
                                      //               item.SellerID) {
                                      //             cartP.clearStoreListCheck();
                                      //             cartP.clearListCheck();
                                      //           }
                                      //           cartP.selectedStoreId = item
                                      //                   .detail?[indexx]
                                      //                   ?.SellerID ??
                                      //               "0";
                                      //           if (cartP.selectedStoreId !=
                                      //               item.SellerID) {
                                      //             cartP.selectedStoreId =
                                      //                 item.SellerID ?? "";
                                      //           } else {
                                      //             cartP.clearListCheck();
                                      //             cartP.selectedStoreId =
                                      //                 item.SellerID ?? "0";
                                      //           }
                                      //           cartP.setCheckItem(
                                      //             index,
                                      //             indexx,
                                      //             check ?? false,
                                      //           );
                                      //           setState(() {});
                                      //         },
                                      //       ),
                                      //     )),
                                      // SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 12, 0, 12),
                                          decoration: ShapeDecoration(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    width: 0.4,
                                                    color: Color(0xFF9D9B9B)),
                                                borderRadius:
                                                    BorderRadius.circular(6)),
                                          ),
                                          child: SafeNetworkImage(
                                            url: prodItem?.foto ?? "",
                                            width: double.minPositive,
                                            height: 50,
                                            errorBuilder: Image.asset(
                                                "assets/images/main-image-not-found.png"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  flex: 9,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              prodItem?.nama ??
                                                  "DEWALT Router Mid-Size, Fixed Base",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Constant.dark14.copyWith(
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: InkWell(
                                                onTap: () async {
                                                  await context
                                                      .read<
                                                          ShoppingCartProvider>()
                                                      .fetchRiwayatNego(context,
                                                          productId: prodItem
                                                                  ?.ProdukID ??
                                                              "");
                                                  await _historyNego(context);
                                                },
                                                child: Icon(
                                                  Icons.history,
                                                  color: Colors.grey,
                                                )),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (prodItem?.statusNego == null &&
                                              prodItem?.nego2 == null)
                                            Text(
                                                Utils.thousandSeparator(int.parse(
                                                    (prodItem?.hargaSebelumNego ??
                                                            "0")
                                                        .replaceAll('.', ''))),
                                                style: Constant.darkBold14),
                                          if (prodItem?.statusNego != null ||
                                              prodItem?.nego2 != null)
                                            Text(
                                              Utils.thousandSeparator(int.parse(
                                                  (prodItem?.hargaSebelumNego ??
                                                          "0")
                                                      .replaceAll('.', ''))),
                                              style: Constant.greyThrough14,
                                            ),
                                          if (prodItem?.statusNego != null ||
                                              (prodItem?.nego2 != null &&
                                                  prodItem?.statusNego == null))
                                            Text(
                                                Utils.thousandSeparator(int.parse(
                                                    ((prodItem?.nego2 != null &&
                                                                prodItem?.statusNego ==
                                                                    null)
                                                            ? prodItem?.nego2 ??
                                                                "0"
                                                            : prodItem
                                                                    ?.fixprice ??
                                                                "0")
                                                        .replaceAll('.', ''))),
                                                style: Constant.darkBold14),
                                        ],
                                      ),
                                      // Text(
                                      //     Utils.thousandSeparator(int.parse((
                                      //         prodItem?.hargaAwal ?? "0").replaceAll('.',''))),
                                      //     style: Constant.darkBold14),

                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          // Row(
                                          //   children: [
                                          //     Image.asset(
                                          //       Assets.iconsIcEdit,
                                          //       scale: 4,
                                          //     ),
                                          //     SizedBox(
                                          //       width: 15,
                                          //     ),
                                          //     Icon(
                                          //       Icons.textsms_outlined,
                                          //       color: Constant.primaryColor,
                                          //     ),
                                          //   ],
                                          // ),
                                          Container(
                                            margin: EdgeInsets.only(left: 8),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 5),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    width: 1,
                                                    color: Color(0xFFE9E9E9)),
                                                borderRadius:
                                                    BorderRadius.circular(60),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    handleTap(() async {
                                                      if (prodItem?.qty ==
                                                          "1") {
                                                        await Utils
                                                            .showYesNoDialog(
                                                          context: context,
                                                          title: "Konfirmasi",
                                                          desc:
                                                              'Apakah Anda yakin ingin menghapus produk ini dari keranjang?',
                                                          yesCallback:
                                                              () async {
                                                            await context
                                                                .read<
                                                                    ShoppingCartProvider>()
                                                                .deleteProductCart(
                                                                    context,
                                                                    cartId: item
                                                                            .detail?[
                                                                                indexx]
                                                                            ?.ID ??
                                                                        "")
                                                                .then((value) {
                                                              Navigator.pop(
                                                                  context);
                                                              return true;
                                                            }).onError((error,
                                                                    stackTrace) {
                                                              Utils.showFailed(
                                                                  msg: error
                                                                          .toString()
                                                                          .toLowerCase()
                                                                          .contains(
                                                                              "doctype")
                                                                      ? "Gagal Hapus Produk!"
                                                                      : "$error");
                                                              return false;
                                                            });
                                                          },
                                                          noCallback: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        );
                                                      } else {
                                                        await context
                                                            .read<
                                                                ShoppingCartProvider>()
                                                            .updateProductCart(
                                                              context,
                                                              cartId: int.parse(
                                                                  prodItem?.ID ??
                                                                      "0"),
                                                              qty: (int.parse(
                                                                      prodItem?.qty ??
                                                                          "1") -
                                                                  1),
                                                              note: "",
                                                            )
                                                            .onError((error,
                                                                stackTrace) {
                                                          Utils.showFailed(
                                                            msg: error
                                                                    .toString()
                                                                    .toLowerCase()
                                                                    .contains(
                                                                        "doctype")
                                                                ? "Maaf, Terjadi Galat!"
                                                                : error
                                                                    .toString(),
                                                          );
                                                        });
                                                        // if(cartP.countShoppingCart() >= 50000000) {
                                                        //   Utils.showFailed(msg: "Anda melebihi batas maksimal harga order");
                                                        // }
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    width: 21,
                                                    height: 21,
                                                    child: CircleAvatar(
                                                      radius: 21,
                                                      backgroundColor: Constant
                                                          .tertiaryColor,
                                                      child: CircleAvatar(
                                                        radius: 17,
                                                        backgroundColor:
                                                            Colors.white,
                                                        foregroundColor:
                                                            Constant
                                                                .tertiaryColor,
                                                        child: Icon(
                                                          Icons.remove,
                                                          size: 17,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Container(
                                                  width: 30,
                                                  child: CustomTextField
                                                      .underlineTextField(
                                                    textInputType:
                                                        TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              r'^\d+\.?\d?')),
                                                      FilteringTextInputFormatter
                                                          .digitsOnly
                                                    ],
                                                    controller:
                                                        cartP.qtyListC[index]
                                                            [indexx],
                                                    onFieldSubmitted:
                                                        (value) async {
                                                      await context
                                                          .read<
                                                              ShoppingCartProvider>()
                                                          .updateProductCart(
                                                              context,
                                                              cartId: int.parse(item
                                                                      .detail?[
                                                                          indexx]
                                                                      ?.ID ??
                                                                  "1"),
                                                              qty: int.parse(
                                                                  value),
                                                              note: "");
                                                      // if(cartP.countShoppingCart() >= 50000000) {
                                                      //   Utils.showFailed(msg: "Anda melebihi batas maksimal harga order");
                                                      // }
                                                    },
                                                    onChanged: (value) async {
                                                      // await context
                                                      //     .read<
                                                      //         ShoppingCartProvider>()
                                                      //     .updateProductCart(
                                                      //         context,
                                                      //         cartId: int.parse(item
                                                      //                 .detail?[
                                                      //                     indexx]
                                                      //                 ?.ID ??
                                                      //             "1"),
                                                      //         qty: int.parse(
                                                      //             value),
                                                      //         note: "");
                                                    },
                                                  ),
                                                ),
                                                // Text(item?.qty.toString() ?? "0",
                                                //     style: Constant.primaryTextStyle),
                                                SizedBox(width: 10),
                                                InkWell(
                                                  onTap: () async {
                                                    handleTap(() async {
                                                      await context
                                                          .read<
                                                              ShoppingCartProvider>()
                                                          .updateProductCart(
                                                            context,
                                                            cartId: int.parse(item
                                                                    .detail?[
                                                                        indexx]
                                                                    ?.ID ??
                                                                ""),
                                                            qty: (int.parse((item
                                                                        .detail?[
                                                                            indexx]
                                                                        ?.qty ??
                                                                    "")) +
                                                                1),
                                                            note: "",
                                                          )
                                                          .onError((error,
                                                              stackTrace) {
                                                        Utils.showFailed(
                                                          msg: error
                                                                  .toString()
                                                                  .toLowerCase()
                                                                  .contains(
                                                                      "doctype")
                                                              ? "Maaf, Terjadi Galat!"
                                                              : error
                                                                  .toString(),
                                                        );
                                                      });
                                                      // if(cartP.countShoppingCart() >= 50000000) {
                                                      //   log("50JT");
                                                      //   Utils.showFailed(msg: "Anda melebihi batas maksimal harga order");
                                                      // }
                                                    });
                                                  },
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Constant.primaryColor,
                                                      foregroundColor:
                                                          Colors.white,
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Badge(
                                      isLabelVisible: (cartP.descListC.length >
                                                  index &&
                                              cartP.descListC[index].length >
                                                  indexx &&
                                              cartP.descListC[index][indexx]
                                                  .text.isNotEmpty)
                                          ? true
                                          : false,
                                      backgroundColor: Colors.green,
                                      label: InkWell(
                                          onTap: () {
                                            setState(() {});
                                          },
                                          child: Icon(
                                            Icons.done,
                                            color: Colors.white,
                                            size: 9,
                                          )),
                                      offset: const Offset(4, -4),
                                      child: CustomButton.thirdButton(
                                          "Tambah Catatan",
                                          contentPadding: EdgeInsets.zero,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          stretched: false,
                                          side: BorderSide(
                                              color: Constant.primaryColor),
                                          textStyle: TextStyle(
                                            color: Constant.primaryColor,
                                            fontWeight: Constant.medium,
                                            fontSize: 12,
                                          ),
                                          margin: EdgeInsets.zero, () async {
                                        _tambahCatatan(context, index, indexx,
                                            prodItem?.ProdukID ?? "");
                                        setState(() {});
                                      }),
                                    )),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    flex: 3,
                                    child: CustomButton.thirdButton(
                                        "Chat Penjual",
                                        contentPadding: EdgeInsets.zero,
                                        borderRadius: BorderRadius.circular(10),
                                        stretched: false,
                                        margin: EdgeInsets.zero, () async {
                                      CusNav.nPush(
                                          context,
                                          ChatPersonView(
                                              id: userId,
                                              sellerName: item.detail?[indexx]
                                                      ?.namaseller ??
                                                  ""));
                                    })),
                                SizedBox(
                                  width: 10,
                                ),
                                // if ((prodItem?.statusNego == null && prodItem?.nego == null) || (prodItem?.statusNego == null && prodItem?.nego2 != null) || (prodItem?.statusNego == null && prodItem?.nego3 == null))

                                Expanded(
                                    flex: 3,
                                    child: CustomButton.thirdButton(
                                        "Nego Harga",
                                        textStyle: TextStyle(
                                            color: condition == false
                                                ? Colors.grey
                                                : Colors.black),
                                        color: condition == false
                                            ? Colors.grey
                                            : Colors.black,
                                        contentPadding: EdgeInsets.zero,
                                        borderRadius: BorderRadius.circular(10),
                                        stretched: false,
                                        margin: EdgeInsets.zero, () async {
                                      if (condition) {
                                        _negoHarga(context, index, indexx,
                                            prodItem?.ProdukID ?? "");
                                      }
                                    })),
                                // if (prodItem?.statusNego != null || prodItem?.nego != null && prodItem?.nego2 == null || prodItem?.nego3 != null)
                                //   Expanded(
                                //       flex: 3,
                                //       child: CustomButton.thirdButton(
                                //           "Nego Harga",
                                //           textStyle:
                                //               TextStyle(color: Colors.grey),
                                //           contentPadding: EdgeInsets.zero,
                                //           borderRadius:
                                //               BorderRadius.circular(10),
                                //           side: BorderSide(color: Colors.grey),
                                //           stretched: false,
                                //           margin: EdgeInsets.zero,
                                //           () async {})),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            if (indexx + 1 < (item.detail?.length ?? 0).toInt())
                              Divider(
                                height: 0.5,
                                color: Colors.grey.withOpacity(0.5),
                              )
                          ],
                        ),
                      ),
                    );
                  })),
              Divider(
                color: Colors.blue.shade100.withOpacity(0.2),
                thickness: 7,
              ),
            ],
          );
        },
      );
    }

    Widget? bottomBtn() {
      return Container(
        height: 40,
        margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomButton.secondaryButton("Pilih Subdit",
                borderRadius: BorderRadius.circular(10),
                margin: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                textStyle: Constant.iPrimaryMedium12, () async {
              _subditBottomSheet(context);
            }),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total', style: Constant.iBlackMedium12),
                  Text(
                    Utils.thousandSeparator(
                        (cartP.countTotalCheckout()).toInt()),
                    style: Constant.darkBold14,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
            if (cartP.countQtyShoppingCart() != 0 &&
                cartP.countShoppingCart() <= 50000000 &&
                cartP.countPajakCheckOut() != 0 &&
                cartP.selectedSubditModel?.ID != null)
              CustomButton.mainButton('Beli',
                  borderRadius: BorderRadius.circular(10), () async {
                handleTap(() async {
                  await cartP.sendBuyBuyer(context,
                      sellerId: cartP.selectedStoreId ?? "0");
                });
              }),
            if (cartP.countQtyShoppingCart() == 0 ||
                cartP.countShoppingCart() >= 50000000 ||
                cartP.countPajakCheckOut() == 0 ||
                cartP.selectedSubditModel?.ID == null)
              CustomButton.mainButton(
                  'Beli',
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                  () async {}),
            // CustomButton.mainButton("Beli",
            //     borderRadius: BorderRadius.circular(10), () async {
            //   Navigator.push(context,
            //       MaterialPageRoute(builder: (context) => CheckOutView()));
            // })
          ],
        ),
      );
    }

    Widget bottomContainer() {
      final subditSelected = cartP.selectedSubditModel?.ID != null;
      final isExpanded = cartP.isExpanded;
      return Container(
        constraints: BoxConstraints(
          minHeight: subditSelected && !isExpanded
              ? 125
              : !subditSelected && isExpanded
                  ? 260
                  : subditSelected && isExpanded
                      ? 375
                      : 40,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (cartP.selectedSubditModel?.ID != null)
              Badge(
                isLabelVisible: true,
                label: InkWell(
                    onTap: () {
                      cartP.clearSubditSelected();
                      setState(() {});
                    },
                    child: Icon(
                      Icons.clear,
                      color: Colors.white,
                      size: 9,
                    )),
                offset: const Offset(-4, -4),
                child: Container(
                  width: 100.w,
                  constraints: BoxConstraints(minHeight: 80),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.07),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10)),
                      border:
                          Border.all(width: 0.7, color: Constant.primaryColor)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pengadaan Alat Operasional Ini Untuk Nama DPP",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              cartP.selectedSubditModel?.nomorPermintaan ?? "-",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              Utils.thousandSeparator(int.parse(cartP
                                      .selectedSubditModel?.nilaiPrk
                                      ?.split(".")
                                      .first ??
                                  "0")),
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                            color: Color(0xFFEFB3C8).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5)),
                        padding: EdgeInsets.all(5),
                        child: Text(
                          cartP.selectedSubditModel?.subditName ??
                              "H207 - SUBDIT OPERASI",
                          textAlign: TextAlign.center,
                          style:
                              Constant.iPrimaryMedium12.copyWith(fontSize: 10),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ExpansionTileUp(),
          ],
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: appbar(),
      bottomNavigationBar: bottomBtn(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          onRefresh: () async => getData(),
          child: Column(
            children: [
              Expanded(child: kontenCart()),
              bottomContainer(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? appbar() {
    return CustomAppBar.appBar(
        context,
        isCenter: true,
        "Keranjang Saya",
        color: Colors.white,
        foregroundColor: Colors.black,
        textStyle: TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            child: Divider(
              color: Colors.grey.withOpacity(0.2),
              thickness: 2,
            ),
          ),
        ),
        action: [
          InkWell(
            onTap: () {
              CusNav.nPush(context, MainHomeKeuanganView());
            },
            child: Container(
              height: 20,
              width: 20,
            ),
          )
        ]);
  }
}

class ExpansionTileUp extends StatefulWidget {
  @override
  _ExpansionTileUpState createState() => _ExpansionTileUpState();
}

class _ExpansionTileUpState extends State<ExpansionTileUp> {
  @override
  Widget build(BuildContext context) {
    final cartP = context.watch<ShoppingCartProvider>();
    final selectedSubdit = cartP.selectedSubditModel;
    return Column(
      children: [
        if (cartP.isExpanded)
          Container(
            padding: EdgeInsets.fromLTRB(15, 5, 15, 2),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cartP.selectedSubditModel != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Text(
                          selectedSubdit?.judul ?? '',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Constant.textColor2,
                          ),
                        ),
                        if (selectedSubdit?.tanggal != null)
                          Text(
                            selectedSubdit?.tanggal == null
                                ? ''
                                : Utils.convertDateddMMMMyyyyHHmm(
                                    selectedSubdit?.tanggal ?? ''),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 10,
                              color: Constant.textColor2,
                            ),
                          ),
                        SizedBox(height: 12),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Subtotal"),
                      Text(
                        Utils.thousandSeparator(
                            cartP.countShoppingCart().toInt()),
                        style: Constant.primaryMedium14,
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("DPP"),
                      Text(
                        Utils.thousandSeparator(cartP.countDpp().toInt()),
                        style: Constant.primaryMedium14,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Masukkan Ongkir"),
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            child: TextField(
                              controller: cartP.ongkirC,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.end,
                              onChanged: (v) {
                                cartP.countTotalCheckout();
                                setState(() {});
                              },
                              onSubmitted: (value) async {
                                cartP.countTotalCheckout();
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                // Menghilangkan semua border
                                enabledBorder: InputBorder.none,
                                // Menghilangkan border saat tidak fokus
                                focusedBorder: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.fromLTRB(29, 5, 0, 5),
                              ),
                              style: TextStyle(
                                  color: Constant.primaryColor,
                                  fontWeight: FontWeight.w600),
                              // inputFormatters: [
                              //   FilteringTextInputFormatter.digitsOnly,
                              //   ThousandsSeparatorInputFormatter(),
                              // ],
                            ),
                          ),
                          Positioned(
                            left: 5,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Text(
                                "Rp",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Constant.primaryColor,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(
                          cartP.getShoppingCartModel.pajak?.length ?? 0,
                          (index) {
                        final item = cartP.getShoppingCartModel.pajak?[index];
                        return Row(
                          children: [
                            Radio(
                              value: (cartP.getShoppingCartModel.pajak?[index]
                                      ?.persentase)
                                  ?.toDouble(),
                              groupValue: cartP.isPajak,
                              visualDensity:
                                  VisualDensity(vertical: -4, horizontal: -4),
                              onChanged: (value) {
                                setState(() {
                                  cartP.isPajak = value as double;
                                  // log("ISI isPajak :" "${cartP.isPajak}");
                                  cartP.countPajakCheckOut();
                                  cartP.countTotalCheckout();
                                });
                              },
                            ),
                            Text("Gunakan ${item?.nama} ${item?.persentase}%"),
                          ],
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Pajak"),
                      Text(
                        // cartP.countPajakCheckOut().toString(),
                        Utils.thousandSeparator(
                            cartP.countPajakCheckOut().toInt()),
                        style: Constant.primaryMedium14,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Colors.grey.withOpacity(0.2),
                    thickness: 1,
                  ),
                ],
              ),
            ),
          ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity(vertical: -4),
          trailing: Icon(cartP.isExpanded
              ? Icons.keyboard_arrow_down_outlined
              : Icons.keyboard_arrow_up_outlined),
          onTap: () {
            setState(() {
              cartP.isExpanded = !cartP.isExpanded;
            });
          },
        ),
      ],
    );
  }
}
