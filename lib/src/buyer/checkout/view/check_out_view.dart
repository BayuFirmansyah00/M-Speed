import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_container.dart';
import 'package:mspeed/common/component/custom_date_picker.dart';
import 'package:mspeed/common/component/custom_textField.dart';
import 'package:mspeed/src/buyer/address/view/akun_penerima_view.dart';
import 'package:mspeed/src/buyer/cart/provider/shopping_cart_provider.dart';
import 'package:mspeed/src/buyer/checkout/provider/checkout_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:mspeed/src/buyer/address/provider/address_provider.dart';

import '../../../../common/component/custom_button.dart';
import '../../../../common/helper/constant.dart';
import '../../../../common/base/base_state.dart';

import 'dart:developer';

class CheckOutView extends StatefulWidget {
  const CheckOutView({super.key});

  @override
  State<CheckOutView> createState() => _CheckOutViewState();
}

class _CheckOutViewState extends BaseState<CheckOutView> {
  int shippingAddress = 0;

  // int shippingPayment = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getData();
    });
  }

  getData() async {
    try {
      final addressP = context.read<AddressProvider>();
      addressP.selectedAddress = null;
      addressP.selectedPenerima = null;
      await context
          .read<CheckOutProvider>()
          .fetchCheckout(context, withLoading: true);
      setState(() {});
    } catch (e) {
      Utils.showFailed(msg: "Terjadi galat, harap muat ulang");
      loading(false);
    }
  }

  void didChangeDependencies() {
    shippingAddress;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final cartP = context.watch<ShoppingCartProvider>();
    final addressP = context.watch<AddressProvider>();
    final checkoutP = context.watch<CheckOutProvider>();

    shippingPopUp() {
      return CustomContainer.showModalBottomScroll(
          context: context,
          initialChildSize: 0.8,
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter state) {
            final list =
                checkoutP.checkoutOptionShippingModel.shippingList ?? [];
            return CustomContainer.mainCard(
              isShadow: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Pengiriman',
                    style: TextStyle(
                      color: Constant.primaryColor,
                      fontSize: 16,
                      fontFamily: 'Open-Sans',
                      fontWeight: Constant.semibold,
                      // height: 0,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (c, i) => SizedBox(height: 16),
                      itemBuilder: (c, i) {
                        final typeItem = list[i];
                        return Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              border:
                                  Border.all(width: 0.5, color: Colors.grey)),
                          child: ExpansionTile(
                            title: Text(typeItem?.typeName ?? ""),
                            children: List.generate(
                                (typeItem?.typeList ?? []).length, (index) {
                              final item = typeItem?.typeList?[index];
                              return Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        width: 0.5, color: Colors.grey)),
                                margin: EdgeInsets.only(bottom: 10),
                                child: InkWell(
                                  onTap: () async {
                                    state(() {
                                      // checkoutP.selectedShipping = item;
                                      // shippingAddress = index;
                                      // log(shippingAddress.toString());
                                      // context
                                      //     .read<ShoppingCartProvider>()
                                      //     .fetchShoppingCartConfirm(context,
                                      //         withLoading: true);
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              child: Text(
                                                item?.courierName ?? "-",
                                                style: TextStyle(
                                                  color: Color(0xFF041E42),
                                                  fontSize: 16,
                                                  fontFamily: 'Open-Sans',
                                                  fontWeight: FontWeight.w400,
                                                  // height: 0.10,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              item?.duration ?? "Durasi -",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Color(0xFF9D9B9B),
                                                fontSize: 15,
                                                fontFamily: 'Open-Sans',
                                                fontWeight: FontWeight.w400,
                                                // height: 0.10,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Text(
                                        (item?.priceDesc ?? "-").toString(),
                                        style: TextStyle(
                                          color: Color(0xFF041E42),
                                          fontSize: 14,
                                          fontFamily: 'Open-Sans',
                                          fontWeight: FontWeight.w500,
                                          // height: 0.10,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }));
    }

    Widget paymentPopUp() {
      return CustomContainer.showModalBottomScroll(
          context: context,
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter state) {
            return Column(
              children: [
                CustomContainer.mainCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Pembayaran',
                        style: TextStyle(
                          color: Constant.primaryColor,
                          fontSize: 16,
                          fontFamily: 'Open-Sans',
                          fontWeight: Constant.semibold,
                          // height: 0,
                        ),
                      ),
                      SizedBox(height: 16),
                      Column(
                        children: List.generate(
                          checkoutP
                                  .getCheckoutOptionPaymentModel.data?.length ??
                              0,
                          (index) => CustomContainer.mainCard(
                            margin: EdgeInsets.only(bottom: 10),
                            color: Color(0xFFF4F5F9),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  shippingAddress = index;
                                  log(shippingAddress.toString());
                                  Navigator.pop(context);
                                });
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Container(
                                  //   width: 72,
                                  //   height: 44,
                                  //   decoration: BoxDecoration(
                                  //     image: DecorationImage(
                                  //       image: NetworkImage(
                                  //           "https://via.placeholder.com/72x44"),
                                  //       fit: BoxFit.fill,
                                  //     ),
                                  //   ),
                                  // ),
                                  Image.asset(
                                    'assets/icons/ic_termin.png',
                                    scale: 6,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          child: Text(
                                            (checkoutP.getCheckoutOptionPaymentModel
                                                        .data?[index])
                                                    ?.name ??
                                                "-",
                                            style: TextStyle(
                                              color: Color(0xFF041E42),
                                              fontSize: 16,
                                              fontFamily: 'Open-Sans',
                                              fontWeight: FontWeight.w400,
                                              // height: 0.10,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Pilih Pembayaran yang digunakan',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Color(0xFF9D9B9B),
                                            fontSize: 15,
                                            fontFamily: 'Open-Sans',
                                            fontWeight: FontWeight.w400,
                                            // height: 0.10,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // InkWell(
                                  //   onTap: () async {
                                  //     handleTap(() async {});
                                  //   },
                                  //   child: Container(
                                  //     width: 21,
                                  //     height: 21,
                                  //     child: CircleAvatar(
                                  //       radius: 21,
                                  //       backgroundColor: Constant.primaryColor,
                                  //       child: CircleAvatar(
                                  //         radius: 15,
                                  //         backgroundColor: Color(0xFFF4F5F9),
                                  //         foregroundColor: Constant.tertiaryColor,
                                  //         child: Icon(
                                  //           Icons.keyboard_arrow_right_rounded,
                                  //           size: 17,
                                  //           weight: 20,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  isShadow: false,
                ),
              ],
            );
          }));
    }

    kontenCheckout() {
      final item = checkoutP.getCheckoutModel.data;
      if (item?.produk?.isEmpty ?? false) return SizedBox();
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        handleTap(() async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AkunPenerimaView()));
                          //   if ((context
                          //               .read<AddressProvider>()
                          //               .getAddressShippingList
                          //               .data ??
                          //           [])
                          //       .isEmpty) {
                          //     Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) =>
                          //                 AddAddressView(isEdit: false)));
                          //   }
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => AddressView(
                          //                 selectMode: true,
                          //               )));
                        });
                      },
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ALAMAT PENGIRIMAN',
                                style: TextStyle(
                                  color: Constant.grayColor,
                                  fontSize: 14,
                                  fontFamily: 'Open-Sans',
                                  fontWeight: Constant.semibold,
                                  // height: 0,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  handleTap(() async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AkunPenerimaView()));
                                  });
                                },
                                child: Text(
                                  addressP.selectedAddress == null
                                      ? "Pilih"
                                      : "Ubah",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Constant.primaryColor,
                                    fontSize: 15,
                                    fontFamily: 'Open-Sans',
                                    fontWeight: FontWeight.w500,
                                    // decoration: TextDecoration.underline,
                                    // height: 0,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Constant.tertiaryColor,
                              ),
                              SizedBox(width: 8),
                              addressP.selectedAddress?.nama == null
                                  ? Text('Anda Belum Memilih Alamat')
                                  : Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            addressP.selectedAddress?.nama ??
                                                "",
                                            style: Constant.secondaryTextStyle
                                                .copyWith(
                                                    fontWeight:
                                                        Constant.semibold),
                                          ),
                                          Text(
                                            context
                                                    .read<
                                                        ShoppingCartProvider>()
                                                    .selectedAddress
                                                    ?.address ??
                                                "",
                                            style: Constant.secondaryTextStyle,
                                          ),
                                          Text(
                                            context
                                                    .read<
                                                        ShoppingCartProvider>()
                                                    .selectedAddress
                                                    ?.phone ??
                                                "",
                                            style: Constant.secondaryTextStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item?.produk?.first?.namaseller ?? "-",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Open-Sans',
                              fontWeight: Constant.semibold,
                              // height: 0,
                            ),
                          ),
                          SizedBox(height: 16),
                          ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: (item?.produk ?? []).length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 20),
                            itemBuilder: (context, index) {
                              final item1 = (item?.produk ?? [])[index];
                              // cartP.getShoppingCartConfirmModel
                              // .data?.cart?.item ??
                              // [])[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      // width: 70,
                                      // height: 70,
                                      padding: EdgeInsets.all(8),
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                width: 1,
                                                color: Color(0xFF9D9B9B)),
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                      ),
                                      child: Image.network(item1?.foto ?? ""),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    flex: 8,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item1?.nama ?? "",
                                          maxLines: 2,
                                          style: Constant.secondaryTextStyle
                                              .copyWith(
                                                  fontSize: 16,
                                                  // height: 1.50,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  // if (item1?.pricePromo != 0)
                                                  //   Text(
                                                  //     item1?.pricePromoDesc ??
                                                  //         "Rp 0",
                                                  //     style:
                                                  //     Constant.darkBold14,
                                                  //     overflow: TextOverflow
                                                  //         .ellipsis,
                                                  //     maxLines: 1,
                                                  //   ),
                                                  // if (item1?.pricePromo != 0)
                                                  //   SizedBox(width: 5),
                                                  // if (item1?.pricePromo != 0)
                                                  //   Text(
                                                  //     item1?.priceDesc ??
                                                  //         "Rp 0",
                                                  //     style: Constant
                                                  //         .greyThrough14,
                                                  //     overflow: TextOverflow
                                                  //         .ellipsis,
                                                  //     maxLines: 1,
                                                  //   ),
                                                  // if (item1?.pricePromo == 0),
                                                  Text(
                                                    "${item1?.qty ?? 0}x",
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                      fontFamily: 'Open-Sans',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    Utils.thousandSeparator(
                                                        int.parse(
                                                          item1?.fixprice ??
                                                              "Rp 0")
                                                    ),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                      fontFamily: 'Open-Sans',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
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
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ESTIMASI PENGIRIMAN',
                            style: TextStyle(
                              color: Constant.grayColor,
                              fontSize: 14,
                              fontFamily: 'Open-Sans',
                              fontWeight: FontWeight.w500,
                              // height: 0,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  flex: 5,
                                  child: CustomTextField.borderTextField(
                                    padding: EdgeInsets.zero,
                                    controller: checkoutP.startDateC,
                                    hintText: "dd/mm/yyyy",
                                    required: true,
                                    readOnly: true,
                                    onTap: () async {
                                      await checkoutP.setStartDate(
                                          await CustomDatePicker.pickDate(
                                              context, DateTime.now(),
                                              firstDate: DateTime.now()));
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                  )),
                              SizedBox(
                                width: 15,
                              ),
                              Container(
                                height: 50,
                                child: Center(
                                  child: Text(
                                    "-",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                flex: 5,
                                child: CustomTextField.borderTextField(
                                  controller: checkoutP.endDateC,
                                  padding: EdgeInsets.zero,
                                  hintText: "dd/mm/yyyy",
                                  required: true,
                                  readOnly: true,
                                  onTap: () async {
                                    await checkoutP.setEndDate(
                                        await CustomDatePicker.pickDate(
                                            context, DateTime.now(),
                                            firstDate: DateTime.now()));
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Divider(
                            color: Colors.blue.shade100.withOpacity(0.2),
                            thickness: 7,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    CustomContainer.mainCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ringkasan Belanja',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Open-Sans',
                              fontWeight: Constant.semibold,
                              // height: 0,
                            ),
                          ),
                          SizedBox(height: 28),
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    color: Color(0xFF041E42),
                                    fontSize: 14,
                                    fontFamily: 'Open-Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 0.14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  Utils.thousandSeparator(
                                      cartP.countShoppingCart().toInt()),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Color(0xFF041E42),
                                    fontSize: 16,
                                    fontFamily: 'Open-Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 0.14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // SizedBox(height: 28),
                          (cartP.getShoppingCartConfirmModel.data?.discount ??
                                      0) ==
                                  0
                              ? SizedBox()
                              : Padding(
                                  padding: const EdgeInsets.only(bottom: 28),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          'Order Discounts',
                                          style: TextStyle(
                                            color: Color(0xFF041E42),
                                            fontSize: 16,
                                            fontFamily: 'Open-Sans',
                                            fontWeight: FontWeight.w400,
                                            height: 0.14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          cartP.getShoppingCartConfirmModel.data
                                                  ?.discountDesc ??
                                              "",
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: Color(0xFF041E42),
                                            fontSize: 16,
                                            fontFamily: 'Open-Sans',
                                            fontWeight: FontWeight.w400,
                                            height: 0.14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(height: 28),
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  'Ongkir',
                                  style: TextStyle(
                                    color: Color(0xFF041E42),
                                    fontSize: 14,
                                    fontFamily: 'Open-Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 0.14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  Utils.thousandSeparator(int.parse((cartP.ongkirC.text != "") ? cartP.ongkirC.text : "0")),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Color(0xFF041E42),
                                    fontSize: 16,
                                    fontFamily: 'Open-Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 0.14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 28),
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  'Pajak',
                                  style: TextStyle(
                                    color: Color(0xFF041E42),
                                    fontSize: 16,
                                    fontFamily: 'Open-Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 0.14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  Utils.thousandSeparator(
                                      cartP.countPajakCheckOut().toInt()),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Color(0xFF041E42),
                                    fontSize: 16,
                                    fontFamily: 'Open-Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 0.14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 28),
                          DottedLine(
                            dashColor: Constant.borderRegularColor,
                            lineThickness: 1,
                            dashLength: 5,
                          ),
                          SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  'Total',
                                  style: TextStyle(
                                    color: Color(0xFF041E42),
                                    fontSize: 16,
                                    fontFamily: 'Open-Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 0.14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  Utils.thousandSeparator(
                                      cartP.countTotalCheckout().toInt()),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Constant.primaryColor,
                                    fontSize: 16,
                                    fontFamily: 'Open-Sans',
                                    fontWeight: FontWeight.w500,
                                    height: 0.14,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      isShadow: false,
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              children: [
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.end,
                //   children: [
                //     Expanded(
                //       flex: 5,
                //       child: Text(
                //         'Total Payment',
                //         style: TextStyle(
                //             color: Constant.primaryColor,
                //             fontWeight: Constant.semibold,
                //             fontSize: 16),
                //       ),
                //     ),
                //     Expanded(
                //       flex: 5,
                //       child: Text(
                //         checkoutP.selectedShipping == null
                //             ? "Rp 0"
                //             : cartP.getShoppingCartConfirmModel.data
                //             ?.totalDesc ??
                //             "Rp 0",
                //         textAlign: TextAlign.right,
                //         style: TextStyle(
                //             color: Constant.tertiaryColor,
                //             fontSize: 16,
                //             fontWeight: Constant.bold),
                //       ),
                //     ),
                //   ],
                // ),
                // SizedBox(height: 20),
                if(addressP.selectedAddress?.nama != null && checkoutP.endDateC.text != "" && checkoutP.startDateC.text != "")
                CustomButton.mainButton('Lakukan Pemesanan',
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                    borderRadius: BorderRadius.circular(10), () async {
                  handleTap(() async {
                    await checkoutP
                        .sendCheckout(context, withLoading: true)
                        .then((value) async {
                      await Utils.showSuccess(msg: "Checkout Sukses");
                      await Future.delayed(Duration(seconds: 2), () {
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context) {
                        //   return OrderConfirmationView();
                        // }));

                      });
                      // Navigator.pushNamedAndRemoveUntil(
                      //     context, '/home', (route) => false);
                    }).onError((error, stackTrace) async {
                      await Utils.showFailed(msg: error.toString());
                    });
                  });
                }),
                if(addressP.selectedAddress?.nama == null || checkoutP.endDateC.text == "" || checkoutP.startDateC.text == "")
                CustomButton.mainButton('Lakukan Pemesanan',
                    color: Colors.grey,
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                    borderRadius: BorderRadius.circular(10), () async {
                  handleTap(() async {
                  });
                }),
              ],
            ),
          ),
          SizedBox(height: 8),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(context, "Check Out",
          titleSpacing: 60,
          color: Colors.black,
          foregroundColor: Colors.black,
          textStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: kontenCheckout(),
      ),
    );
  }
}
