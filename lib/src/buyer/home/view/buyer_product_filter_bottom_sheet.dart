import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/buyer/product/provider/buyer_product_filter_provider.dart';
import 'package:provider/provider.dart';

class BuyerProductFilterBottomSheet extends StatefulWidget {
  const BuyerProductFilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<BuyerProductFilterBottomSheet> createState() => _BuyerProductFilterBottomSheetState();
}

class _BuyerProductFilterBottomSheetState extends State<BuyerProductFilterBottomSheet> {
  final TextEditingController _minPriceCtrl = TextEditingController();
  final TextEditingController _maxPriceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = context.read<BuyerProductFilterProvider>();
    _minPriceCtrl.text = p.minPrice;
    _maxPriceCtrl.text = p.maxPrice;
  }

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BuyerProductFilterProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Kategori',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: p.availableCategories.map((cat) {
              final isSelected = p.selectedCategoryIds.contains(cat.id);
              return InputChip(
                label: Text(cat.name ?? '-'),
                selected: isSelected,
                onSelected: (bool selected) {
                  p.toggleCategory(cat.id!);
                },
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36),
                ),
                backgroundColor: const Color(0xFFEEF0F8),
                selectedColor: const Color(0xFFFEF9F4),
                side: BorderSide(color: isSelected ? Colors.red : const Color(0xFFEEF0F8)),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.red : Colors.black,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Lokasi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: p.availableCities.take(7).map((city) {
              final isSelected = p.selectedCities.contains(city);
              return InputChip(
                label: Text(city),
                selected: isSelected,
                onSelected: (bool selected) {
                  p.toggleCity(city);
                },
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36),
                ),
                backgroundColor: const Color(0xFFEEF0F8),
                selectedColor: const Color(0xFFFEF9F4),
                side: BorderSide(color: isSelected ? Colors.red : const Color(0xFFEEF0F8)),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.red : Colors.black,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Harga',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _minPriceCtrl,
                  decoration: InputDecoration(
                    labelText: 'Harga Terendah',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFEEF0F8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFEEF0F8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFEEF0F8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    p.applyPriceFilter(val, _maxPriceCtrl.text);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _maxPriceCtrl,
                  decoration: InputDecoration(
                    labelText: 'Harga Tertinggi',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFEEF0F8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFEEF0F8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFEEF0F8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    p.applyPriceFilter(_minPriceCtrl.text, val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                CusNav.nPop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFFED1C24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: const Text('Tampilkan Barang'),
            ),
          ),
        ],
      ),
    );
  }
}
