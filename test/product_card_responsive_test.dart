import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mspeed/src/manager/dashboard/model/manager_dashboard_model.dart';

final _currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kBorder = Color(0xFFE5E7EB);
const Color _kRed = Color(0xFFE31C25);
const Color _kTeal = Color(0xFF0D9488);

Widget _buildTestProductCard(ManagerProductItem item) {
  final priceStr = _currencyFmt.format(item.price ?? 0);
  final sellerName = item.seller?.companyName ?? 'Vendor';
  final city = item.seller?.cityName;
  final catName = item.category?.name ?? '-';

  return Container(
    decoration: BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _kBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image with fixed responsive height
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          child: Container(
            height: 125,
            width: double.infinity,
            color: Colors.grey.shade100,
            child: const Center(
              child: Icon(Icons.inventory_2_outlined, size: 36, color: Colors.grey),
            ),
          ),
        ),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name ?? '-',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceStr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: _kRed,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storefront_rounded, size: 11, color: Colors.grey.shade500),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            sellerName,
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (city != null && city.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          city,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Stok ${item.qty ?? 0} • $catName',
                      style: const TextStyle(
                        fontSize: 10,
                        color: _kTeal,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

void main() {
  group('Manager Product Card Responsive & Overflow Tests', () {
    final testProducts = [
      ManagerProductItem(
        id: 1,
        name: 'Hand Sanitizer Jerigen zlj-###',
        price: 666449,
        qty: 341,
        seller: ManagerProductSeller(
          companyName: 'Yayasan Simanjuntak PT',
          cityName: 'Kabupaten Tebo',
        ),
        category: ManagerProductCategory(name: 'Consumable'),
      ),
      ManagerProductItem(
        id: 2,
        name: 'Buku Agenda Kerja ssa-###',
        price: 45000,
        qty: 120,
        seller: ManagerProductSeller(
          companyName: 'CV Alat Tulis Kantor Prima',
          cityName: 'Jakarta Pusat',
        ),
        category: ManagerProductCategory(name: 'ATK'),
      ),
      ManagerProductItem(
        id: 3,
        name: 'Kacamata Safety Clear jlv-### Extra Protection Heavy Duty Multi-Coated',
        price: 1250000,
        qty: 850,
        seller: ManagerProductSeller(
          companyName: 'PT Sumber Makmur Sentosa Abadi Perkasa Jaya Tbk',
          cityName: 'Kabupaten Bolaang Mongondow Selatan',
        ),
        category: ManagerProductCategory(name: 'Perlengkapan Keselamatan Kerja & APD'),
      ),
      ManagerProductItem(
        id: 4,
        name: 'Kompresor Angin Listrik Industri Berat Tiga Fasa Kapasitas Tangki 500 Liter Daya 10 HP',
        price: 999999999,
        qty: 99999,
        seller: ManagerProductSeller(
          companyName: 'PT Distributor Mesin Perkakas Nusantara Abadi',
          cityName: 'Kabupaten Pangkajene dan Kepulauan',
        ),
        category: ManagerProductCategory(name: 'Peralatan dan Mesin Berat'),
      ),
    ];

    final testScreenSizes = [
      const Size(320, 640),  // Very small phone
      const Size(360, 780),  // Standard phone
      const Size(390, 844),  // iPhone 12/13/14
      const Size(412, 915),  // Pixel 7
      const Size(600, 1024), // Small Tablet
      const Size(800, 1280), // Large Tablet
    ];

    for (final size in testScreenSizes) {
      testWidgets('Product grid renders without overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 280,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _buildTestProductCard(testProducts[i % testProducts.length]),
                        childCount: testProducts.length * 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check for any Flutter overflow errors
        expect(tester.takeException(), isNull);

        // Verify products are rendered
        expect(find.text('Hand Sanitizer Jerigen zlj-###'), findsWidgets);
        expect(find.text('Buku Agenda Kerja ssa-###'), findsWidgets);
      });
    }
  });
}
