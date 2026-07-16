import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/component/image_network_widget.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/buyer/transaction/model/daftar_transaksi_buyer_model.dart';

class OrderItemWidget extends StatelessWidget {
  final DaftarTransaksiBuyerModelData? data;

  const OrderItemWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      margin: EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      Assets.svgsIcBukuAlamat,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      data?.detail?.firstOrNull?.SellerNama ?? '',
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    Text(
                      data?.nomorOrder ?? '',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    ImageNetworkWidget(
                      imageUrl: data?.detail?.firstOrNull?.foto ?? '',
                      width: 60,
                      height: 60,
                      radius: 12,
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data?.detail?.firstOrNull?.nama ?? '',
                            style: TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            data?.Created?.substring(0, 10) ?? '',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'x${data?.detail?.firstOrNull?.qty ?? '0'}',
                          style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w400,
                              color: Constant.grayColor),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          data?.detail?.firstOrNull?.hargaAkhir != null ? formatCurrency(data?.detail?.firstOrNull?.hargaAkhir ?? '0') : formatCurrency(data?.detail?.firstOrNull?.harga ?? '0'),
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
          Divider(
            color: Color(0xFFF6F6F6),
          ),
          Center(
            child: Text(
              'Tampilkan Produk Lainnya',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Constant.grayColor),
            ),
          ),
          Divider(
            color: Color(0xFFF6F6F6),
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${data?.jum ?? '0'} Produk',
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: Constant.grayColor),
                ),
                SizedBox(width: 16.0),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Total Pesanan: ',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: formatCurrency(data?.total ?? '0'),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.red,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatCurrency(String amount) {
    // Mengonversi string ke integer
    int value = int.parse(amount);

    // Membuat format untuk Rupiah
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    // Mengonversi integer ke format mata uang
    return formatCurrency.format(value);
  }
}
