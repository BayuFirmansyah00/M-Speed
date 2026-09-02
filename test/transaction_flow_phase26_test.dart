import 'package:flutter_test/flutter_test.dart';
import 'package:mspeed/src/seller/pesanan/model/pesanan_seller_model.dart';
import 'package:mspeed/src/seller/pesanan/model/seller_order_status.dart';
import 'package:mspeed/src/manager/pesanan/model/manager_order_model.dart';
import 'package:mspeed/src/keuangan/pesanan/model/finance_order_model.dart';
import 'package:mspeed/src/penerima/pesanan/model/receiver_order_model.dart';

void main() {
  group('Phase 26 - Full End-to-End Flutter Transaction Flow Contract Tests', () {
    // 1. SELLER INVOICE & STATUS GUARDS
    test('SellerOrderStatus enum & Button Visibility Guards', () {
      // Approve Pesanan By Manager -> Can Accept
      expect(SellerOrderStatus.fromString('approve pesanan by manager').canAccept, isTrue);
      expect(SellerOrderStatus.fromString('approve pesanan by manager').canShip, isFalse);
      expect(SellerOrderStatus.fromString('approve pesanan by manager').canCreateInvoice, isFalse);

      // Pesanan Diterima Penjual -> Can Ship
      expect(SellerOrderStatus.fromString('pesanan diterima penjual').canShip, isTrue);
      expect(SellerOrderStatus.fromString('pesanan diterima penjual').canAccept, isFalse);
      expect(SellerOrderStatus.fromString('pesanan diterima penjual').canCreateInvoice, isFalse);

      // Pesanan Diterima Penerima -> Can Create Invoice
      expect(SellerOrderStatus.fromString('pesanan diterima penerima').canCreateInvoice, isTrue);
      expect(SellerOrderStatus.fromString('pesanan diterima penerima').canReInvoice, isFalse);
      expect(SellerOrderStatus.fromString('pesanan diterima penerima').canShip, isFalse);

      // Tolak Tagih By Manager -> Can Re-Invoice
      expect(SellerOrderStatus.fromString('tolak tagih by manager').canReInvoice, isTrue);
      expect(SellerOrderStatus.fromString('tolak tagih by manager').canCreateInvoice, isFalse);

      // Siap Tagih By Manager -> No invoice button
      expect(SellerOrderStatus.fromString('siap tagih by manager').canCreateInvoice, isFalse);
      expect(SellerOrderStatus.fromString('siap tagih by manager').canReInvoice, isFalse);

      // Pesanan Dibayar -> Completed
      expect(SellerOrderStatus.fromString('pesanan dibayar').isCompleted, isTrue);
      expect(SellerOrderStatus.fromString('pesanan dibayar').canCreateInvoice, isFalse);
    });

    test('SellerOrderData parses latest status deterministically', () {
      final orderJson = {
        "id": 999,
        "order_num": "ORD/2026/03/999",
        "payment_status": "pesanan baru",
        "logs_history": [
          {"id": 1, "status": "pesanan baru", "created_at": "2026-03-01 10:00:00"},
          {"id": 2, "status": "approve pesanan by manager", "created_at": "2026-03-01 10:05:00"},
          {"id": 3, "status": "pesanan diterima penjual", "created_at": "2026-03-01 10:10:00"},
          {"id": 4, "status": "pesanan dikirim", "created_at": "2026-03-01 10:15:00"},
          {"id": 5, "status": "pesanan diterima penerima", "created_at": "2026-03-01 10:20:00"},
        ]
      };

      final data = SellerOrderData.fromJson(orderJson);
      expect(data.statusEnum, SellerOrderStatus.pesananDiterimaPenerima);
      expect(data.statusEnum.canCreateInvoice, isTrue);
      expect(data.statusEnum.canReInvoice, isFalse);
    });

    // 2. MANAGER INVOICE & ORDER APPROVAL WORKFLOW
    test('ManagerOrderData evaluates canApproveOrder and canApproveInvoice correctly', () {
      // State 1: pesanan baru
      final managerOrderNew = ManagerOrderData(
        id: 1,
        orderNum: "M-001",
        latestLog: ManagerOrderLog(id: 1, status: "pesanan baru"),
        orderLogs: [ManagerOrderLog(id: 1, status: "pesanan baru")],
      );
      expect(managerOrderNew.canApproveOrder, isTrue);
      expect(managerOrderNew.canApproveInvoice, isFalse);

      // State 2: tagihan
      final managerOrderInvoice = ManagerOrderData(
        id: 2,
        orderNum: "M-002",
        latestLog: ManagerOrderLog(id: 10, status: "tagihan"),
        orderLogs: [
          ManagerOrderLog(id: 1, status: "pesanan baru"),
          ManagerOrderLog(id: 10, status: "tagihan"),
        ],
      );
      expect(managerOrderInvoice.canApproveOrder, isFalse);
      expect(managerOrderInvoice.canApproveInvoice, isTrue);

      // State 3: siap tagih by manager
      final managerOrderApprovedInvoice = ManagerOrderData(
        id: 3,
        orderNum: "M-003",
        latestLog: ManagerOrderLog(id: 15, status: "siap tagih by manager"),
        orderLogs: [
          ManagerOrderLog(id: 10, status: "tagihan"),
          ManagerOrderLog(id: 15, status: "siap tagih by manager"),
        ],
      );
      expect(managerOrderApprovedInvoice.canApproveOrder, isFalse);
      expect(managerOrderApprovedInvoice.canApproveInvoice, isFalse);
    });

    // 3. RECEIVER VERIFICATION WORKFLOW
    test('ReceiverOrderData canVerifyReception on pesanan dikirim', () {
      final receiverOrderShipped = ReceiverOrderData(
        id: 50,
        orderNum: "RCV-001",
        paymentStatus: "pesanan dikirim",
        shippingCost: 15000,
        orderItems: [],
        orderLogs: [],
        latestLog: ReceiverOrderLog(id: 4, title: "Dikirim", status: "pesanan dikirim"),
      );
      expect(receiverOrderShipped.canVerifyReception, isTrue);
      expect(receiverOrderShipped.isReceived, isFalse);

      final receiverOrderReceived = ReceiverOrderData(
        id: 51,
        orderNum: "RCV-002",
        paymentStatus: "pesanan diterima penerima",
        shippingCost: 15000,
        orderItems: [],
        orderLogs: [],
        latestLog: ReceiverOrderLog(id: 5, title: "Diterima", status: "pesanan diterima penerima"),
      );
      expect(receiverOrderReceived.canVerifyReception, isFalse);
      expect(receiverOrderReceived.isReceived, isTrue);
    });

    // 4. FINANCE PAYMENT WORKFLOW
    test('FinanceOrderData canProcessPayment on siap tagih by manager and penerimaan & verifikasi', () {
      // Ready via Manager invoice approval
      final financeOrderSiapTagih = FinanceOrderData(
        id: 80,
        orderNum: "FIN-001",
        latestLog: FinanceOrderLog(id: 11, status: "siap tagih by manager"),
      );
      expect(financeOrderSiapTagih.canProcessPayment, isTrue);
      expect(financeOrderSiapTagih.isPaid, isFalse);
      expect(financeOrderSiapTagih.statusDisplayLabel, "Siap Dibayar");

      // Ready via internal receiver verification
      final financeOrderPenerimaan = FinanceOrderData(
        id: 81,
        orderNum: "FIN-002",
        latestLog: FinanceOrderLog(id: 12, status: "penerimaan & verifikasi"),
      );
      expect(financeOrderPenerimaan.canProcessPayment, isTrue);
      expect(financeOrderPenerimaan.isPaid, isFalse);

      // Paid
      final financeOrderPaid = FinanceOrderData(
        id: 82,
        orderNum: "FIN-003",
        paymentStatus: "pesanan dibayar",
        latestLog: FinanceOrderLog(id: 20, status: "pesanan dibayar"),
      );
      expect(financeOrderPaid.canProcessPayment, isFalse);
      expect(financeOrderPaid.isPaid, isTrue);
      expect(financeOrderPaid.statusDisplayLabel, "Telah Dibayar");

      // Rejected
      final financeOrderRejected = FinanceOrderData(
        id: 83,
        orderNum: "FIN-004",
        latestLog: FinanceOrderLog(id: 21, status: "pembayaran ditolak finance"),
      );
      expect(financeOrderRejected.canProcessPayment, isFalse);
      expect(financeOrderRejected.isRejected, isTrue);
      expect(financeOrderRejected.statusDisplayLabel, "Pembayaran Ditolak");
    });
  });
}
