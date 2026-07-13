import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/utils/Utils.dart';

import '../../../buyer/transaction/provider/transaction_status.dart';

class OrderItem extends StatelessWidget {
  final String orderNumber;
  final String date;
  final String sellerName;
  final String total;
  final TransactionStatus status;
  final Color bgColor;

  const OrderItem({
    Key? key,
    required this.orderNumber,
    required this.date,
    required this.sellerName,
    required this.total,
    required this.status,
    required this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
      color: bgColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 10,
                child: Container(
                  width: 200,
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
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                child: Container(
                  width: 200,
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
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                child: Container(
                  width: 200,
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
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 5,
                child: Container(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                            color: Constant.grayColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        Utils.thousandSeparator(int.parse(total)),
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                child: Container(
                  width: 200,
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
                              color: Constant.statusColor(status.toString()) == Colors.black 
                                  ? Colors.green 
                                  : Constant.statusColor(status.toString()))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
