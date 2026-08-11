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
    final statusColor = Constant.statusColor(status.toString()) == Colors.black 
        ? const Color(0xff10B981) 
        : Constant.statusColor(status.toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xffEBEBF0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card (Order Number & Date)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xffF9FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              border: const Border(bottom: BorderSide(color: Color(0xffEEF0F5), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, color: Color(0xffF59E0B), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      orderNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff100629),
                      ),
                    ),
                  ],
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff8A93A3),
                  ),
                ),
              ],
            ),
          ),
          
          // Body Card (Seller & Details)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xffF59E0B).withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Color(0xffF59E0B), size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Seller',
                            style: TextStyle(fontSize: 10, color: Color(0xff8A93A3), fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            sellerName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff100629),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xffF0F1F5)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(fontSize: 10, color: Color(0xff8A93A3), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rp ${Utils.thousandSeparator(int.parse(total))}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xffF59E0B),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
                      ),
                      child: Text(
                        status.statusName(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
