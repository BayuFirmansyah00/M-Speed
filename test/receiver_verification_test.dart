import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mspeed/src/penerima/pesanan/model/receiver_order_model.dart';

void main() {
  group('Receiver (Penerima) Order Model & Parity Tests', () {
    test('Correctly parses ReceiverOrderListResponse with pagination meta', () {
      final mockListJson = {
        'data': [
          {
            'id': 101,
            'order_num': 'ORD/2026/03/0001',
            'payment_status': 'pesanan dikirim',
            'shipping_cost': 25000.0,
            'seller': {
              'id': 10,
              'company_name': 'PT Logistik Maju Jaya',
              'phone': '08123456789',
              'email': 'seller@majujaya.com',
              'address': 'Jl. Industri No. 12, Surabaya',
            },
            'buyer': {
              'id': 20,
              'buyer_name': 'Divisi Pengadaan Pusat',
            },
            'recipient': {
              'recipient_id': 30,
              'recipient_name': 'Budi Gudang',
              'recipient_phone': '08987654321',
              'recipient_email': 'budi.gudang@company.com',
              'recipient_address': 'Gudang Logistik Sidoarjo',
            },
            'latest_log': {
              'id': 5,
              'title': 'Pengiriman Barang',
              'status': 'pesanan dikirim',
              'note': 'Barang sedang dalam perjalanan menuju gudang penerima',
              'created_at': '2026-03-01T10:00:00.000000Z',
            },
            'order_items': [
              {
                'id': 1001,
                'product_name': 'Box Kardus Packing A1',
                'qty': 10,
                'initial_price': 15000.0,
                'tax': 1650.0,
                'final_price': 166500.0,
              },
              {
                'id': 1002,
                'product_name': 'Bubble Wrap Roll 50m',
                'qty': 2,
                'initial_price': 80000.0,
                'tax': 8800.0,
                'final_price': 177600.0,
              },
            ],
            'order_logs': [
              {
                'id': 5,
                'title': 'Pengiriman Barang',
                'status': 'pesanan dikirim',
                'note': 'Barang sedang dalam perjalanan',
                'created_at': '2026-03-01T10:00:00.000000Z',
              },
            ],
            'created_at': '2026-03-01T08:00:00.000000Z',
            'updated_at': '2026-03-01T10:00:00.000000Z',
          }
        ],
        'meta': {
          'current_page': 1,
          'last_page': 1,
          'per_page': 15,
          'total': 1,
        }
      };

      final response = ReceiverOrderListResponse.fromJson(mockListJson);

      expect(response.data.length, equals(1));
      expect(response.meta?.currentPage, equals(1));
      expect(response.meta?.total, equals(1));

      final order = response.data.first;
      expect(order.id, equals(101));
      expect(order.orderNum, equals('ORD/2026/03/0001'));
      expect(order.seller?.companyName, equals('PT Logistik Maju Jaya'));
      expect(order.buyer?.buyerName, equals('Divisi Pengadaan Pusat'));
      expect(order.recipient?.recipientName, equals('Budi Gudang'));
      expect(order.orderItems.length, equals(2));
      expect(order.totalQty, equals(12));
      expect(order.subtotalItems, equals(344100.0));
      expect(order.shippingCost, equals(25000.0));
      expect(order.grandTotal, equals(369100.0));
    });

    test('Computed getters accurately determine canVerifyReception for shipped orders', () {
      final orderJson = {
        'id': 102,
        'order_num': 'ORD/2026/03/0002',
        'payment_status': 'pesanan dikirim',
        'shipping_cost': 0.0,
        'latest_log': {
          'id': 12,
          'title': 'Kurir Menuju Lokasi',
          'status': 'pesanan dikirim',
          'note': 'Estimasi sampai sore ini',
        },
        'order_items': [],
        'order_logs': [],
      };

      final order = ReceiverOrderData.fromJson(orderJson);

      expect(order.effectiveStatus, equals('pesanan dikirim'));
      expect(order.canVerifyReception, isTrue);
      expect(order.isReceived, isFalse);
      expect(order.statusDisplayLabel, contains('Sedang Dikirim'));
      expect(order.statusBadgeColor, equals(const Color(0xFFF59E0B)));
    });

    test('Computed getters accurately detect received status', () {
      final orderJson = {
        'id': 103,
        'order_num': 'ORD/2026/03/0003',
        'payment_status': 'pesanan diterima penerima',
        'shipping_cost': 10000.0,
        'latest_log': {
          'id': 20,
          'title': 'Verifikasi Penerimaan Barang',
          'status': 'pesanan diterima penerima',
          'note': 'Barang diterima lengkap dan segel utuh.',
        },
        'order_items': [],
        'order_logs': [],
      };

      final order = ReceiverOrderData.fromJson(orderJson);

      expect(order.effectiveStatus, equals('pesanan diterima penerima'));
      expect(order.canVerifyReception, isFalse);
      expect(order.isReceived, isTrue);
      expect(order.statusDisplayLabel, equals('Telah Diterima'));
      expect(order.statusBadgeColor, equals(const Color(0xFF10B981)));
    });

    test('Single order detail parser handles null latest_log and empty arrays gracefully', () {
      final detailJson = {
        'data': {
          'id': 104,
          'order_num': 'ORD/2026/03/0004',
          'payment_status': 'menunggu persetujuan manager',
          'shipping_cost': 0.0,
          'order_items': [],
          'order_logs': [],
        }
      };

      final detailResponse = ReceiverOrderDetailResponse.fromJson(detailJson);
      expect(detailResponse.data, isNotNull);
      expect(detailResponse.data?.id, equals(104));
      expect(detailResponse.data?.canVerifyReception, isFalse);
      expect(detailResponse.data?.isReceived, isFalse);
      expect(detailResponse.data?.grandTotal, equals(0.0));
      expect(detailResponse.data?.totalQty, equals(0));
    });
  });
}
