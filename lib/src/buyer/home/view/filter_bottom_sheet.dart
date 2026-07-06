import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/buyer/home/provider/home_provider.dart';
import 'package:provider/provider.dart';

import '../../../../common/base/base_state.dart';

class FilterBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            child: Column(
              children: [
                SizedBox(height: 16),
                FilterCategorySection(
                  onSelected: (filter) {},
                ),
                SizedBox(height: 16),
                FilterLocationSection(
                    // onSelected: (filter) {},
                    ),
                SizedBox(height: 16),
                FilterPriceSection(),
                SizedBox(height: 16),
                Container(
                  width: MediaQuery.of(context).size.width,
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
          ),
        ],
      ),
    );
  }
}

class FilterCategorySection extends StatefulWidget {
  final Function(List<String>) onSelected;

  FilterCategorySection({required this.onSelected});

  @override
  State<FilterCategorySection> createState() => _FilterCategorySectionState();
}

class _FilterCategorySectionState extends BaseState<FilterCategorySection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Kategori',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(spacing: 8.0, children: _buildCategories()),
      ],
    );
  }

  List<Widget> _buildCategories() {
    final filter = context.watch<HomeProvider>().kategoriMap;
    final widgets = <Widget>[];

    filter.forEach((category, isSelected) {
      widgets.add(InputChip(
        label: Text(category),
        selected: filter[category]!,
        onSelected: (bool selected) {
          // final filter2 = context.read<HomeProvider>().kategoriMap;
          setState(() {
            filter[category] = selected;
            widget.onSelected(
                filter.keys.where((key) => filter[key] == true).toList());
          });
        },
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36),
        ),
        backgroundColor: Color(0xFFEEF0F8),
        selectedColor: Color(0xFFFEF9F4),
        side: BorderSide(color: isSelected ? Colors.red : Color(0xFFEEF0F8)),
        labelStyle: TextStyle(
          color: filter[category]! ? Colors.red : Colors.black,
        ),
      ));
    });

    return widgets;
  }
}

class FilterLocationSection extends StatefulWidget {
  // final Function(List<String>) onSelected;

  // FilterLocationSection({required this.onSelected});

  @override
  State<FilterLocationSection> createState() => _FilterLocationSectionState();
}

class _FilterLocationSectionState extends BaseState<FilterLocationSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lokasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
                onPressed: () {
                  _showModaldata(context);
                },
                child: Text('Lihat Lainnya'))
          ],
        ),
        SizedBox(height: 8),
        Wrap(spacing: 8.0, children: _buildCategories()),
      ],
    );
  }

  List<Widget> _buildCategories() {
    final filter = context.watch<HomeProvider>().kategoriLokasiMap;
    final homeProvider = context.read<HomeProvider>();
    final widgets = <Widget>[];

    final limitedFilter = filter.entries.take(7);

    limitedFilter.forEach((entry) {
      final category = entry.key;
      final isSelected = entry.value;
      widgets.add(InputChip(
        label: Text(category),
        selected: filter[category]!,
        onSelected: (bool selected) {
          setState(() {
            filter[category] = selected;
            homeProvider.updateSelectedLocations();
          });
        },
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36),
        ),
        backgroundColor: Color(0xFFEEF0F8),
        selectedColor: Color(0xFFFEF9F4),
        side: BorderSide(color: isSelected ? Colors.red : Color(0xFFEEF0F8)),
        labelStyle: TextStyle(
          color: filter[category]! ? Colors.red : Colors.black,
        ),
      ));
    });

    return widgets;
  }
}

class FilterPriceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Harga',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 12,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: context.read<HomeProvider>().minPrice,
                decoration: InputDecoration(
                  labelText: 'Harga Terendah',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFEEF0F8)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFEEF0F8)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFEEF0F8)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: context.read<HomeProvider>().maxPrice,
                decoration: InputDecoration(
                  labelText: 'Harga Tertinggi',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFEEF0F8)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFEEF0F8)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFEEF0F8)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void _showModaldata(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        // minChildSize: 0.3,
        maxChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lokasi',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<HomeProvider>().resetFilters();
                          },
                          child: Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: LocationBottomSheet(),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class LocationBottomSheet extends StatefulWidget {
  const LocationBottomSheet({super.key});

  @override
  State<LocationBottomSheet> createState() => _LocationBottomSheetState();
}

class _LocationBottomSheetState extends BaseState<LocationBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(16),
          topEnd: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 8,
          ),
          Wrap(spacing: 8.0, children: _buildCategories()),
        ],
      ),
    );
  }

  List<Widget> _buildCategories() {
    final filter = context.watch<HomeProvider>().kategoriLokasiMap;
    final widgets = <Widget>[];
    final homeProvider = context.read<HomeProvider>();

    widgets.add(
      ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final category = filter.keys.elementAt(index);
          final isSelected = filter[category]!;
          return ListTile(
            title: Text(category),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (bool? selected) {
                setState(() {
                  filter[category] = selected!;
                  homeProvider.updateSelectedLocations();
                });
              },
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(),
        itemCount: filter.length,
      ),
    );

    return widgets;
  }
}
