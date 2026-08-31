import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/buyer/product/provider/buyer_product_filter_provider.dart';
import 'package:provider/provider.dart';

class BuyerProductSortBottomSheet extends StatefulWidget {
  const BuyerProductSortBottomSheet({Key? key}) : super(key: key);

  @override
  _BuyerProductSortBottomSheetState createState() => _BuyerProductSortBottomSheetState();
}

class _BuyerProductSortBottomSheetState extends State<BuyerProductSortBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<BuyerProductFilterProvider>();

    Widget _buildSortOption(String title, int value) {
      return InkWell(
        onTap: () {
          p.applySort(value);
          CusNav.nPop(context);
        },
        child: ListTile(
          title: Text(title),
          trailing: Radio<int>(
            value: value,
            groupValue: p.sort,
            onChanged: (int? value) {
              if (value != null) {
                p.applySort(value);
                CusNav.nPop(context);
              }
            },
            activeColor: Colors.red,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  CusNav.nPop(context);
                },
              ),
              const Text(
                'Urutkan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSortOption('Terbaru', 1),
          _buildSortOption('Harga Tertinggi', 2),
          _buildSortOption('Harga Terendah', 3),
          _buildSortOption('Terlaris', 4),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
