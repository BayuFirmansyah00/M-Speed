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
    // Generate colors based on status
    Color baseColor = Constant.statusColor(status.toString());
    Color statusBgColor = baseColor.withOpacity(0.1);
    Color statusTextColor = baseColor == Colors.black ? Colors.grey : baseColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER: Order No and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 16, color: Constant.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        orderNumber,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: Colors.black45),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // DIVIDER
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey.withOpacity(0.15),
              ),
              const SizedBox(height: 12),

              // BODY: Seller Name and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Seller Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Toko / Penjual',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.black45,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.storefront_rounded, size: 14, color: Colors.black87),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                sellerName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusTextColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      status.statusName(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusTextColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
