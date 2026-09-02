import 'package:flutter_test/flutter_test.dart';
import 'package:mspeed/src/keuangan/pesanan/model/finance_order_model.dart';

void main() {
  group('Finance Role Tests - Model & Business Logic', () {
    test('Parse FinanceOrderListResponse from Laravel API response JSON', () {
      final sampleApiResponse = {
        "data": [
          {
            "id": 101,
            "order_num": "ORD/2026/03/0001",
            "payment_status": "menunggu pembayaran",
            "shipping_cost": 25000.0,
            "seller": {
              "id": 201,
              "company_name": "PT Sumber Rejeki Abadi",
              "phone": "081234567890",
              "email": "seller@sumberrejeki.com",
              "address": "Jl. Industri No. 45, Jakarta"
            },
            "buyer": {
              "id": 301,
              "buyer_name": "Divisi Operasional",
              "recipient_name": "Budi Santoso",
              "recipient_phone": "089876543210",
              "recipient_email": "budi@perusahaan.com",
              "recipient_address": "Gedung Kantor Lt. 4, Surabaya"
            },
            "finance": {
              "finance_id": null,
              "finance_name": null
            },
            "prk_submission_id": 55,
            "latest_log": {
              "id": 12,
              "status": "penerimaan & verifikasi",
              "note": "Barang telah diterima dan diverifikasi oleh Receiver",
              "created_at": "2026-03-01T10:00:00.000000Z"
            },
            "order_items": [
              {
                "id": 1,
                "product_name": "Laptop ThinkPad E14",
                "qty": 2,
                "initial_price": 12000000.0,
                "tax": 1320000.0,
                "final_price": 26640000.0
              },
              {
                "id": 2,
                "product_name": "Mouse Wireless Logitech",
                "qty": 2,
                "initial_price": 250000.0,
                "tax": 27500.0,
                "final_price": 555000.0
              }
            ],
            "order_logs": [
              {
                "id": 12,
                "status": "penerimaan & verifikasi",
                "note": "Barang telah diverifikasi",
                "created_at": "2026-03-01T10:00:00.000000Z"
              },
              {
                "id": 11,
                "status": "barang dikirim",
                "note": "Pesanan dalam perjalanan",
                "created_at": "2026-02-28T08:00:00.000000Z"
              }
            ],
            "payment_proofs": [],
            "created_at": "2026-02-25T09:00:00.000000Z",
            "updated_at": "2026-03-01T10:00:00.000000Z"
          },
          {
            "id": 102,
            "order_num": "ORD/2026/03/0002",
            "payment_status": "pesanan dibayar",
            "shipping_cost": 0.0,
            "seller": {
              "id": 202,
              "company_name": "CV Maju Bersama",
              "phone": "08111222333",
              "email": "maju@bersama.com",
              "address": "Bandung"
            },
            "buyer": {
              "id": 301,
              "buyer_name": "Divisi Operasional",
              "recipient_name": "Budi Santoso",
              "recipient_phone": "089876543210",
              "recipient_email": "budi@perusahaan.com",
              "recipient_address": "Surabaya"
            },
            "finance": {
              "finance_id": 15,
              "finance_name": "Finance Head"
            },
            "prk_submission_id": 56,
            "latest_log": {
              "id": 20,
              "status": "pesanan dibayar",
              "note": "Pesanan telah dibayar oleh Divisi Finance.",
              "created_at": "2026-03-01T12:00:00.000000Z"
            },
            "order_items": [
              {
                "id": 3,
                "product_name": "Kertas A4 PaperOne 80gr",
                "qty": 10,
                "initial_price": 50000.0,
                "tax": 5500.0,
                "final_price": 555000.0
              }
            ],
            "order_logs": [
              {
                "id": 20,
                "status": "pesanan dibayar",
                "note": "Pesanan telah dibayar oleh Divisi Finance.",
                "created_at": "2026-03-01T12:00:00.000000Z"
              }
            ],
            "payment_proofs": [
              {
                "id": 1,
                "title": "Bukti Pembayaran Finance",
                "file_url": "http://localhost:8000/storage/orders/payment_proofs/proof_102.jpg"
              }
            ],
            "created_at": "2026-02-26T09:00:00.000000Z",
            "updated_at": "2026-03-01T12:00:00.000000Z"
          }
        ],
        "meta": {
          "current_page": 1,
          "last_page": 1,
          "per_page": 15,
          "total": 2
        }
      };

      final response = FinanceOrderListResponse.fromJson(sampleApiResponse);

      expect(response.data.length, 2);
      expect(response.meta?.total, 2);

      // Order 1 Verifications
      final order1 = response.data[0];
      expect(order1.id, 101);
      expect(order1.orderNum, "ORD/2026/03/0001");
      expect(order1.seller?.companyName, "PT Sumber Rejeki Abadi");
      expect(order1.buyer?.recipientName, "Budi Santoso");
      expect(order1.orderItems.length, 2);
      expect(order1.subtotalItems, 26640000.0 + 555000.0);
      expect(order1.grandTotal, 26640000.0 + 555000.0 + 25000.0);
      expect(order1.canProcessPayment, isTrue);
      expect(order1.isPaid, isFalse);
      expect(order1.statusDisplayLabel, 'Siap Dibayar');

      // Order 2 Verifications
      final order2 = response.data[1];
      expect(order2.id, 102);
      expect(order2.paymentStatus, "pesanan dibayar");
      expect(order2.finance?.financeName, "Finance Head");
      expect(order2.orderItems.length, 1);
      expect(order2.grandTotal, 555000.0);
      expect(order2.canProcessPayment, isFalse);
      expect(order2.isPaid, isTrue);
      expect(order2.statusDisplayLabel, 'Telah Dibayar');
      expect(order2.paymentProofs.length, 1);
      expect(order2.paymentProofs.first.fileUrl, contains("proof_102.jpg"));
    });

    test('Verification of payment reject status', () {
      final sampleDetailJson = {
        "data": {
          "id": 103,
          "order_num": "ORD/2026/03/0003",
          "payment_status": "menunggu pembayaran",
          "shipping_cost": 10000.0,
          "seller": {"id": 203, "company_name": "Seller XYZ"},
          "buyer": {"id": 301, "buyer_name": "Buyer XYZ"},
          "latest_log": {
            "id": 30,
            "status": "pembayaran ditolak finance",
            "note": "Lampiran dokumen faktur tidak lengkap.",
            "created_at": "2026-03-01T14:00:00.000000Z"
          },
          "order_items": [
            {
              "id": 1,
              "product_name": "Toner Printer",
              "qty": 1,
              "initial_price": 500000.0,
              "tax": 55000.0,
              "final_price": 555000.0
            }
          ],
          "order_logs": [
            {
              "id": 30,
              "status": "pembayaran ditolak finance",
              "note": "Lampiran dokumen faktur tidak lengkap.",
              "created_at": "2026-03-01T14:00:00.000000Z"
            }
          ],
          "payment_proofs": []
        }
      };

      final parsed = FinanceOrderDetailResponse.fromJson(sampleDetailJson);
      final order = parsed.data!;

      expect(order.isRejected, isTrue);
      expect(order.canProcessPayment, isFalse);
      expect(order.statusDisplayLabel, 'Pembayaran Ditolak');
    });
  });
}
