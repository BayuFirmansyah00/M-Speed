import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/Constant.dart';

import '../../../buyer/transaction/provider/transaction_status.dart';

class OrderItem extends StatelessWidget {
  final String orderNumber;
  final String date;
  final String sellerName;
  final TransactionStatus status;
  final Color bgColor;

  const OrderItem({
    Key? key,
    required this.orderNumber,
    required this.date,
    required this.sellerName,
    required this.status,
    required this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
      color: bgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Order',
                  style: TextStyle(
                      color: Constant.grayColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  orderNumber,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          SizedBox(width: 8,),
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tanggal',
                  style: TextStyle(
                      color: Constant.grayColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          SizedBox(width: 8,),
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama Seller',
                  style: TextStyle(
                      color: Constant.grayColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  sellerName,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          SizedBox(width: 8,),
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                      color: Constant.grayColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                Text(status.statusName(),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: status == TransactionStatus.BARANG_DITERIMA
                            ? Colors.pink
                            : status == TransactionStatus.PESANAN_DIKIRIM
                                ? Colors.orange
                                : Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
