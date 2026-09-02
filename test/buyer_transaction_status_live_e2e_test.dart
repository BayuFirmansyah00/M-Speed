import 'package:flutter_test/flutter_test.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_provider.dart';
import 'package:mspeed/common/helper/constant.dart';

void main() {
  group('Phase 28B - Buyer Transaction Status Live & Contract E2E Tests', () {
    test('TransactionProvider assigns orders to correct tabs across all transition states', () {
      final List<Map<String, dynamic>> mockOrders = [
        {
          'id': 101,
          'order_num': 'ORD-001',
          'payment_status': 'pesanan baru',
          'shipping_cost': 15000,
          'latest_log': {'status': 'pesanan baru', 'title': 'Dibuat'},
          'items': [
            {'product_name': 'Item 1', 'qty': 1, 'initial_price': 50000, 'final_price': 50000}
          ],
          'logs': [
            {'status': 'pesanan baru'}
          ]
        },
        {
          'id': 102,
          'order_num': 'ORD-002',
          'payment_status': 'approve pesanan by manager',
          'shipping_cost': 15000,
          'latest_log': {'status': 'approve pesanan by manager', 'title': 'Disetujui Manager'},
          'items': [
            {'product_name': 'Item 2', 'qty': 1, 'initial_price': 75000, 'final_price': 75000}
          ],
          'logs': [
            {'status': 'approve pesanan by manager'},
            {'status': 'pesanan baru'}
          ]
        },
        {
          'id': 103,
          'order_num': 'ORD-003',
          'payment_status': 'pesanan diterima penjual',
          'shipping_cost': 15000,
          'latest_log': {'status': 'pesanan diterima penjual', 'title': 'Diterima Seller'},
          'items': [
            {'product_name': 'Item 3', 'qty': 2, 'initial_price': 30000, 'final_price': 60000}
          ],
          'logs': [
            {'status': 'pesanan diterima penjual'},
            {'status': 'approve pesanan by manager'},
            {'status': 'pesanan baru'}
          ]
        },
        {
          'id': 104,
          'order_num': 'ORD-004',
          'payment_status': 'pesanan dikirim',
          'shipping_cost': 20000,
          'latest_log': {'status': 'pesanan dikirim', 'title': 'Dikirim'},
          'items': [
            {'product_name': 'Item 4', 'qty': 1, 'initial_price': 100000, 'final_price': 100000}
          ],
          'logs': [
            {'status': 'pesanan dikirim'},
            {'status': 'pesanan diterima penjual'}
          ]
        },
        {
          'id': 105,
          'order_num': 'ORD-005',
          'payment_status': 'pesanan diterima penerima',
          'shipping_cost': 20000,
          'latest_log': {'status': 'pesanan diterima penerima', 'title': 'Diterima Penerima'},
          'items': [
            {'product_name': 'Item 5', 'qty': 1, 'initial_price': 120000, 'final_price': 120000}
          ],
          'logs': [
            {'status': 'pesanan diterima penerima'},
            {'status': 'pesanan dikirim'}
          ]
        },
        {
          'id': 106,
          'order_num': 'ORD-006',
          'payment_status': 'tagihan',
          'shipping_cost': 20000,
          'latest_log': {'status': 'tagihan', 'title': 'Tagihan Diterbitkan'},
          'items': [
            {'product_name': 'Item 6', 'qty': 1, 'initial_price': 150000, 'final_price': 150000}
          ],
          'logs': [
            {'status': 'tagihan'},
            {'status': 'pesanan diterima penerima'}
          ]
        },
        {
          'id': 107,
          'order_num': 'ORD-007',
          'payment_status': 'siap tagih by manager',
          'shipping_cost': 20000,
          'latest_log': {'status': 'siap tagih by manager', 'title': 'Tagihan Disetujui Manager'},
          'items': [
            {'product_name': 'Item 7', 'qty': 1, 'initial_price': 150000, 'final_price': 150000}
          ],
          'logs': [
            {'status': 'siap tagih by manager'},
            {'status': 'tagihan'}
          ]
        },
        {
          'id': 108,
          'order_num': 'ORD-008',
          'payment_status': 'pesanan dibayar',
          'shipping_cost': 20000,
          'latest_log': {'status': 'pesanan dibayar', 'title': 'Dibayar Finance'},
          'items': [
            {'product_name': 'Item 8', 'qty': 1, 'initial_price': 150000, 'final_price': 150000}
          ],
          'logs': [
            {'status': 'pesanan dibayar'},
            {'status': 'siap tagih by manager'}
          ]
        }
      ];

      // Tab mapping verification:
      // Tab 1: Pesanan Baru (ORD-001)
      // Tab 2: Diterima (ORD-002, ORD-003)
      // Tab 3: Dikirim (ORD-004)
      // Tab 4: Barang Diterima (ORD-005)
      // Tab 5: Proses Pembayaran (ORD-006, ORD-007)
      // Tab 6: Telah Dibayar (ORD-008)

      final tabBuckets = <int, List<String>>{
        1: [],
        2: [],
        3: [],
        4: [],
        5: [],
        6: [],
      };

      for (final item in mockOrders) {
        final tabIndex = TransactionProvider.logStatusToTabIndexForTest(item);
        tabBuckets[tabIndex]!.add(item['order_num']);
      }

      expect(tabBuckets[1], contains('ORD-001'), reason: 'Tab 1 contains pesanan baru');
      expect(tabBuckets[2], containsAll(['ORD-002', 'ORD-003']), reason: 'Tab 2 contains approve pesanan by manager and pesanan diterima penjual');
      expect(tabBuckets[3], contains('ORD-004'), reason: 'Tab 3 contains pesanan dikirim');
      expect(tabBuckets[4], contains('ORD-005'), reason: 'Tab 4 contains pesanan diterima penerima');
      expect(tabBuckets[5], containsAll(['ORD-006', 'ORD-007']), reason: 'Tab 5 contains tagihan and siap tagih by manager');
      expect(tabBuckets[6], contains('ORD-008'), reason: 'Tab 6 contains pesanan dibayar');
    });

    test('Constant.statusColor provides appropriate theme color for all Laravel status values', () {
      expect(Constant.statusColor('pesanan baru'), isNotNull);
      expect(Constant.statusColor('approve pesanan by manager'), isNotNull);
      expect(Constant.statusColor('pesanan diterima penjual'), isNotNull);
      expect(Constant.statusColor('pesanan dikirim'), isNotNull);
      expect(Constant.statusColor('pesanan diterima penerima'), isNotNull);
      expect(Constant.statusColor('tagihan'), isNotNull);
      expect(Constant.statusColor('siap tagih by manager'), isNotNull);
      expect(Constant.statusColor('pesanan dibayar'), isNotNull);
      expect(Constant.statusColor('reject pesanan by manager'), isNotNull);
    });
  });
}
