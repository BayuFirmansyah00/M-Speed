import 'package:flutter_test/flutter_test.dart';
import 'package:mspeed/src/manager/dashboard/model/manager_dashboard_model.dart';
import 'package:mspeed/src/manager/pesanan/model/manager_order_model.dart';
import 'package:mspeed/src/manager/pesanan/view/manager_order_item_widget.dart';
import 'package:mspeed/src/manager/team/model/manager_team_model.dart';

void main() {
  group('1. Manager Dashboard Contract & Model Verification', () {
    test('ManagerDashboardModel parses banners, categories, parent_orders, and products correctly', () {
      final mockJson = {
        'banners': [
          {'id': 1, 'caption': 'Promo Spesial', 'img_url': 'http://example.com/banner.jpg'}
        ],
        'categories': [
          {'id': 10, 'name': 'Elektronik', 'status': 1},
          {'id': 11, 'name': 'Alat Tulis', 'status': 1}
        ],
        'parent_orders': [
          {
            'id': 101,
            'order_num': 'ORD-001',
            'buyer_name': 'Buyer A',
            'payment_status': 'pesanan baru',
            'latest_log': {
              'status': 'pesanan baru',
              'note': 'Menunggu persetujuan',
              'created_at': '2026-09-01T10:00:00Z'
            }
          },
          {
            'id': 102,
            'order_num': 'ORD-002',
            'buyer_name': 'Buyer B',
            'payment_status': 'tagihan',
            'latest_log': {
              'status': 'tagihan',
              'note': 'Tagihan diterbitkan',
              'created_at': '2026-09-01T11:00:00Z'
            }
          },
          {
            'id': 103,
            'order_num': 'ORD-003',
            'buyer_name': 'Buyer C',
            'payment_status': 'reject pesanan by manager',
            'latest_log': {
              'status': 'reject pesanan by manager',
              'note': 'Ditolak',
              'created_at': '2026-09-01T12:00:00Z'
            }
          }
        ],
        'products': [
          {
            'id': 501,
            'name': 'Laptop Asus',
            'product_code': 'LPT-01',
            'qty': 5,
            'price': 12000000.0,
            'category': {'id': 10, 'name': 'Elektronik'},
            'seller': {
              'id': 20,
              'company_name': 'PT Toko Komputer',
              'phone': '08123456789',
              'address_detail': 'Jl. Mawar 10',
              'city_name': 'Jakarta Pusat'
            },
            'images': [
              {'id': 1, 'img_url': 'http://example.com/laptop.jpg'}
            ]
          }
        ]
      };

      final dashboard = ManagerDashboardModel.fromJson(mockJson);

      expect(dashboard.banners?.length, 1);
      expect(dashboard.banners?.first.caption, 'Promo Spesial');
      expect(dashboard.categories?.length, 2);
      expect(dashboard.parentOrders?.length, 3);
      expect(dashboard.products?.length, 1);
      expect(dashboard.products?.first.name, 'Laptop Asus');
      expect(dashboard.products?.first.seller?.companyName, 'PT Toko Komputer');
      expect(dashboard.products?.first.primaryImageUrl, 'http://example.com/laptop.jpg');

      // Test KPI status categorization
      expect(dashboard.parentOrders?[0].statusCategory, 'pesanan_baru');
      expect(dashboard.parentOrders?[1].statusCategory, 'tagihan');
      expect(dashboard.parentOrders?[2].statusCategory, 'pesanan_ditolak');
    });
  });

  group('2. Manager Order Model & Business Logic Verification', () {
    test('ManagerOrderData subtotal, grand total, and approval logic', () {
      final mockOrder = ManagerOrderData(
        id: 1,
        orderNum: 'ORD-123',
        paymentStatus: 'pesanan baru',
        shippingCost: 50000.0,
        orderItems: [
          ManagerOrderItem(id: 1, productName: 'Item A', qty: 2, finalPrice: 100000.0),
          ManagerOrderItem(id: 2, productName: 'Item B', qty: 1, finalPrice: 200000.0),
        ],
        orderLogs: [
          ManagerOrderLog(id: 1, status: 'pesanan baru', title: 'Pesanan Dibuat', note: 'Menunggu approval'),
        ],
      );

      expect(mockOrder.subtotal, 400000.0);
      expect(mockOrder.grandTotal, 450000.0);
      expect(mockOrder.canApproveOrder, true);
      expect(mockOrder.canApproveInvoice, false);
      expect(mockOrder.statusLabel, 'Pesanan Baru');

      // Now simulate invoice state
      final mockInvoiceOrder = ManagerOrderData(
        id: 2,
        orderNum: 'ORD-124',
        paymentStatus: 'tagihan',
        orderLogs: [
          ManagerOrderLog(id: 1, status: 'pesanan baru'),
          ManagerOrderLog(id: 2, status: 'approve pesanan by manager'),
          ManagerOrderLog(id: 3, status: 'tagihan', title: 'Tagihan Diterbitkan'),
        ],
      );

      expect(mockInvoiceOrder.canApproveOrder, false);
      expect(mockInvoiceOrder.canApproveInvoice, true);
      expect(mockInvoiceOrder.statusLabel, 'Tagihan');

      // Now simulate approved state
      final mockApprovedOrder = ManagerOrderData(
        id: 3,
        orderNum: 'ORD-125',
        paymentStatus: 'siap tagih by manager',
        orderLogs: [
          ManagerOrderLog(id: 1, status: 'pesanan baru'),
          ManagerOrderLog(id: 2, status: 'tagihan'),
          ManagerOrderLog(id: 4, status: 'siap tagih by manager'),
        ],
      );

      expect(mockApprovedOrder.canApproveOrder, false);
      expect(mockApprovedOrder.canApproveInvoice, false);
      expect(mockApprovedOrder.statusLabel, 'Siap Tagih');
    });
  });

  group('3. Manager Team Model Verification', () {
    test('ManagerTeamModel parses subordinates correctly', () {
      final mockJson = {
        'data': [
          {
            'id': 1,
            'first_name': 'Budi',
            'last_name': 'Santoso',
            'full_name': 'Budi Santoso',
            'phone': '081299998888',
            'completeness': '100%',
            'user': {
              'id': 20,
              'email': 'budi@example.com',
              'role': 'buyer',
            },
            'department': {
              'id': 5,
              'name': 'Procurement IT',
              'sub_direktorate': 'Direktorat Operasional',
            }
          }
        ]
      };

      final team = ManagerTeamModel.fromJson(mockJson);
      expect(team.data?.length, 1);
      final member = team.data!.first;
      expect(member.fullName, 'Budi Santoso');
      expect(member.user?.email, 'budi@example.com');
      expect(member.department?.name, 'Procurement IT');
      expect(member.department?.subDirektorate, 'Direktorat Operasional');
    });
  });
}
