import 'package:flutter_test/flutter_test.dart';
import 'package:mspeed/src/penerima/pesanan/model/receiver_order_model.dart';

void main() {
  group('Phase 28B - Receiver Transaction Model & Contract Tests', () {
    test('ReceiverOrderData parses JSON and calculates canVerifyReception and isReceived correctly', () {
      final jsonShipped = {
        'id': 201,
        'order_num': 'ORD-SHIPPED-001',
        'receipt_num': 'RESI-123456',
        'payment_status': 'pesanan dikirim',
        'shipping_cost': 25000,
        'seller': {
          'id': 5,
          'company_name': 'PT Toko Jaya',
          'phone': '0812345678',
          'email': 'seller@toko.com',
          'address': 'Jakarta'
        },
        'buyer': {
          'id': 10,
          'buyer_name': 'John Buyer'
        },
        'recipient': {
          'recipient_id': 15,
          'recipient_name': 'Alice Receiver',
          'recipient_phone': '0898765432',
          'recipient_email': 'alice@receiver.com',
          'recipient_address': 'Gudang Bintaro'
        },
        'latest_log': {
          'id': 501,
          'title': 'Pesanan Dikirim',
          'status': 'pesanan dikirim',
          'note': 'Barang dikirim via kurir',
          'created_at': '2026-09-02T10:00:00Z'
        },
        'order_items': [
          {
            'id': 1,
            'product_name': 'Komponen A',
            'qty': 2,
            'initial_price': 50000,
            'tax': 0,
            'final_price': 100000
          }
        ],
        'order_logs': [
          {
            'id': 501,
            'title': 'Pesanan Dikirim',
            'status': 'pesanan dikirim',
            'note': 'Barang dikirim via kurir',
            'created_at': '2026-09-02T10:00:00Z'
          }
        ]
      };

      final orderShipped = ReceiverOrderData.fromJson(jsonShipped);
      expect(orderShipped.id, equals(201));
      expect(orderShipped.orderNum, equals('ORD-SHIPPED-001'));
      expect(orderShipped.effectiveStatus, equals('pesanan dikirim'));
      expect(orderShipped.canVerifyReception, isTrue, reason: 'Receiver can verify order when status is pesanan dikirim');
      expect(orderShipped.isReceived, isFalse);
      expect(orderShipped.subtotalItems, equals(100000.0));
      expect(orderShipped.grandTotal, equals(125000.0));

      // After reception verified by receiver:
      final jsonReceived = Map<String, dynamic>.from(jsonShipped);
      jsonReceived['payment_status'] = 'pesanan diterima penerima';
      jsonReceived['latest_log'] = {
        'id': 502,
        'title': 'Verifikasi Penerimaan Barang',
        'status': 'pesanan diterima penerima',
        'note': 'Barang telah diterima dalam kondisi baik',
        'created_at': '2026-09-02T11:00:00Z'
      };

      final orderReceived = ReceiverOrderData.fromJson(jsonReceived);
      expect(orderReceived.effectiveStatus, equals('pesanan diterima penerima'));
      expect(orderReceived.canVerifyReception, isFalse, reason: 'Order already received, action button should hide');
      expect(orderReceived.isReceived, isTrue, reason: 'isReceived is true for pesanan diterima penerima');
    });

    test('ReceiverOrderListResponse parses pagination list correctly', () {
      final listJson = {
        'data': [
          {
            'id': 201,
            'order_num': 'ORD-001',
            'payment_status': 'pesanan dikirim',
            'shipping_cost': 15000,
            'order_items': [],
            'order_logs': []
          }
        ],
        'meta': {
          'current_page': 1,
          'per_page': 15,
          'total': 1,
          'last_page': 1
        }
      };

      final response = ReceiverOrderListResponse.fromJson(listJson);
      expect(response.data.length, equals(1));
      expect(response.data.first.orderNum, equals('ORD-001'));
      expect(response.meta?.total, equals(1));
    });
  });
}
