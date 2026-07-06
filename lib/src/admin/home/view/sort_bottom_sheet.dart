import 'package:flutter/material.dart';
import 'package:mspeed/src/buyer/home/provider/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../common/component/custom_navigator.dart';

class SortBottomSheet extends StatefulWidget {
  const SortBottomSheet({Key? key}) : super(key: key);

  @override
  _SortBottomSheetState createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<HomeProvider>();
    Widget _buildSortOption(String title, int value) {
      return InkWell(
        onTap: () {
          setState(() {
            p.sort = value;
          });
        },
        child: ListTile(
          title: Text(title),
          trailing: Radio(
            value: value,
            groupValue: p.sort,
            onChanged: (int? value) {
              setState(() {
                p.sort = value ?? 0;
              });
            },
            activeColor: value == 0 ? Colors.red : null,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DraggableScrollableSheet(
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {},
                    ),
                    Text(
                      'Urutkan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildSortOption('Paling Sesuai', 0),
                _buildSortOption('Terbaru', 1),
                _buildSortOption('Harga Tertinggi', 2),
                _buildSortOption('Harga Terendah', 3),
                SizedBox(height: 16),
                Container(
                  width: 100.w,
                  child: ElevatedButton(
                    onPressed: () async {
                      CusNav.nPop(context);
                      final p = context.read<HomeProvider>();
                      await context
                          .read<HomeProvider>()
                          .searchProduct(withLoading: true);
                    },
                    child: Text('Tampilkan Barang'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFFED1C24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
