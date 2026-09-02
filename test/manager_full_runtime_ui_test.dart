import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mspeed/core/network/api_client.dart';
import 'package:mspeed/src/manager/dashboard/model/manager_dashboard_model.dart';
import 'package:mspeed/src/manager/pesanan/model/manager_order_model.dart';
import 'package:mspeed/src/manager/pesanan/provider/manager_provider.dart';
import 'package:mspeed/src/manager/pesanan/view/manager_order_item_widget.dart';
import 'package:mspeed/src/manager/team/model/manager_team_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Exact response structure from GET /api/manager/v1/manager/dashboard
  final sampleDashboardJson = {
    'parent_orders': [
      {'id': 49, 'order_num': 'ORD-202607858', 'buyer_name': 'Gaduh Wastuti', 'payment_status': 'unpaid', 'latest_log': {'status': 'pesanan baru', 'note': 'Pesanan dibuat'}},
      {'id': 48, 'order_num': 'ORD-202607857', 'buyer_name': 'Siti Rahma', 'payment_status': 'unpaid', 'latest_log': {'status': 'approve pesanan by manager', 'note': 'Disetujui manager'}},
      {'id': 47, 'order_num': 'ORD-202607856', 'buyer_name': 'Budi Santoso', 'payment_status': 'unpaid', 'latest_log': {'status': 'dikirim', 'note': 'Dalam pengiriman'}},
      {'id': 46, 'order_num': 'ORD-202607855', 'buyer_name': 'Ahmad Hidayat', 'payment_status': 'unpaid', 'latest_log': {'status': 'diterima seller', 'note': 'Diterima seller'}},
      {'id': 45, 'order_num': 'ORD-202607854', 'buyer_name': 'Dewi Lestari', 'payment_status': 'unpaid', 'latest_log': {'status': 'tagihan', 'note': 'Invoice terbit'}},
      {'id': 44, 'order_num': 'ORD-202607853', 'buyer_name': 'Eko Prasetyo', 'payment_status': 'unpaid', 'latest_log': {'status': 'siap tagih by manager', 'note': 'Siap bayar'}},
      {'id': 43, 'order_num': 'ORD-202607852', 'buyer_name': 'Rina Wati', 'payment_status': 'unpaid', 'latest_log': {'status': 'verifikasi', 'note': 'Verifikasi finance'}},
      {'id': 42, 'order_num': 'ORD-202607851', 'buyer_name': 'Joko Widodo', 'payment_status': 'paid', 'latest_log': {'status': 'pesanan dibayar', 'note': 'Lunas'}},
    ],
    'categories': [
      {'id': 1, 'name': 'Consumable'},
      {'id': 2, 'name': 'ATK'},
      {'id': 3, 'name': 'Peralatan'},
    ],
    'banners': [
      {'id': 1, 'image_path': 'banners/sample.jpg', 'img_url': 'http://10.0.2.2:8000/storage/banners/sample.jpg'},
    ],
    'products': [
      {
        'id': 1,
        'name': 'Batman Action Figure Heavy Armor Edition Limited',
        'product_code': 'PRD-001',
        'qty': 9,
        'price': 5000000.0,
        'category': {'id': 1, 'name': 'Service'},
        'seller': {'id': 5, 'company_name': 'Fa Nasyidah Tbk PT', 'city_name': 'Kabupaten Bulungan'},
        'images': [{'id': 1, 'image_path': 'products/images/sample.jpg', 'img_url': 'http://10.0.2.2:8000/storage/products/images/sample.jpg'}],
      },
      {
        'id': 2,
        'name': 'Hand Sanitizer Jerigen zlj-### 5 Liter Antiseptic Formula',
        'product_code': 'PRD-002',
        'qty': 341,
        'price': 666449.0,
        'category': {'id': 2, 'name': 'Consumable'},
        'seller': {'id': 6, 'company_name': 'PT Mitra Sejahtera', 'city_name': 'Kabupaten Tebo'},
        'images': [{'id': 2, 'image_path': 'products/images/sample2.jpg', 'img_url': 'http://10.0.2.2:8000/storage/products/images/sample2.jpg'}],
      },
      {
        'id': 3,
        'name': 'Buku Agenda Kerja ssa-### Hard Cover Executive',
        'product_code': 'PRD-003',
        'qty': 120,
        'price': 45000.0,
        'category': {'id': 3, 'name': 'ATK'},
        'seller': {'id': 7, 'company_name': 'CV Alat Tulis Kantor Prima Mandiri', 'city_name': 'Jakarta Pusat'},
        'images': [],
      },
    ],
  };

  // Exact response structure from GET /api/manager/v1/manager/orders
  final sampleOrdersJson = {
    'data': [
      {
        'id': 49,
        'order_num': 'ORD-202607858',
        'payment_status': 'unpaid',
        'shipping_cost': 32114.0,
        'seller': {'id': 5, 'company_name': 'Fa Nasyidah Tbk PT', 'phone': '08781612370', 'email': 'seller5@example.com', 'address': 'Ds. Bass No. 996'},
        'buyer': {'id': 13, 'buyer_name': 'Gaduh Wastuti', 'recipient_name': 'Victoria Rahmawati', 'recipient_phone': '04779421920', 'recipient_email': 'buyer13@example.com', 'recipient_address': 'Jl. Kenanga No. 12'},
        'latest_log': {'id': 100, 'status': 'pesanan baru', 'title': 'Pesanan Baru', 'note': 'Menunggu persetujuan'},
        'order_items': [
          {'id': 10, 'product_name': 'Batman', 'qty': 1, 'initial_price': 5000000.0, 'tax': 0.0, 'final_price': 5000000.0}
        ],
        'order_logs': [
          {'id': 100, 'status': 'pesanan baru', 'title': 'Pesanan Baru', 'note': 'Menunggu persetujuan'}
        ],
      },
      {
        'id': 48,
        'order_num': 'ORD-202607857',
        'payment_status': 'unpaid',
        'shipping_cost': 15000.0,
        'seller': {'id': 6, 'company_name': 'PT Mitra Sejahtera', 'phone': '0812345678', 'email': 'seller6@example.com'},
        'buyer': {'id': 14, 'buyer_name': 'Siti Rahma', 'recipient_name': 'Siti Rahma', 'recipient_phone': '0812987654'},
        'latest_log': {'id': 99, 'status': 'tagihan', 'title': 'Tagihan', 'note': 'Invoice terbit'},
        'order_items': [
          {'id': 11, 'product_name': 'Hand Sanitizer', 'qty': 2, 'initial_price': 666449.0, 'tax': 0.0, 'final_price': 666449.0}
        ],
        'order_logs': [
          {'id': 99, 'status': 'tagihan', 'title': 'Tagihan', 'note': 'Invoice terbit'}
        ],
      },
    ],
  };

  // Exact response structure from GET /api/manager/v1/manager/team
  final sampleTeamJson = {
    'data': [
      {
        'id': 100,
        'first_name': 'Vivi',
        'last_name': 'Jailani',
        'full_name': 'Vivi Jailani',
        'phone': '02735243421',
        'completeness': 100,
        'user': {'id': 120, 'email': 'direksi20@example.com', 'role': 'direksi'},
        'department': {'id': 47, 'name': 'SEKRETARIAT PERUSAHAAN', 'sub_direktorate': 'HUKUM DAN PENGADAAN'},
      },
      {
        'id': 69,
        'first_name': 'Budi',
        'last_name': 'Santoso',
        'full_name': 'Budi Santoso',
        'phone': '08123456789',
        'completeness': 100,
        'user': {'id': 85, 'email': 'buyer1@example.com', 'role': 'buyer'},
        'department': {'id': 12, 'name': 'OPERASIONAL', 'sub_direktorate': 'LOGISTIK'},
      },
    ],
  };

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'token': 'mock_manager_token',
      'first_name': 'Manager',
      'last_name': 'Speed',
    });

    // Clear interceptors and install synchronous mock interceptor
    ApiClient().dio.interceptors.clear();
    ApiClient().dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('dashboard')) {
            return handler.resolve(Response(
              requestOptions: options,
              data: sampleDashboardJson,
              statusCode: 200,
            ));
          } else if (options.path.contains('orders')) {
            return handler.resolve(Response(
              requestOptions: options,
              data: sampleOrdersJson,
              statusCode: 200,
            ));
          } else if (options.path.contains('team')) {
            return handler.resolve(Response(
              requestOptions: options,
              data: sampleTeamJson,
              statusCode: 200,
            ));
          }
          return handler.next(options);
        },
      ),
    );
  });

  group('Manager Full Runtime UI & Navigation Verification', () {
    test('1. Manager Dashboard KPI & Product parsing test', () {
      final dashboardModel = ManagerDashboardModel.fromJson(sampleDashboardJson);
      expect(dashboardModel.parentOrders?.length, 8);
      expect(dashboardModel.products?.length, 3);
      expect(dashboardModel.categories?.length, 3);
      expect(dashboardModel.banners?.length, 1);
    });

    testWidgets('2. Manager Order Items and Eligibility test', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final ordersModel = ManagerOrderModel.fromJson(sampleOrdersJson);
      final order1 = ordersModel.data![0];
      final order2 = ordersModel.data![1];

      expect(order1.canApproveOrder, isTrue);
      expect(order1.canApproveInvoice, isFalse);
      expect(order2.canApproveOrder, isFalse);
      expect(order2.canApproveInvoice, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                ManagerOrderItemWidget(order: order1),
                ManagerOrderItemWidget(order: order2),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('ORD-202607858'), findsOneWidget);
      expect(find.text('ORD-202607857'), findsOneWidget);
    });

    test('3. Manager Team Member parsing & model test', () {
      final teamModel = ManagerTeamModel.fromJson(sampleTeamJson);
      expect(teamModel.data?.length, 2);
      expect(teamModel.data![0].fullName, 'Vivi Jailani');
      expect(teamModel.data![1].fullName, 'Budi Santoso');
    });

    test('4. Manager Provider State & Fetch cycle', () async {
      final provider = ManagerProvider();
      
      await provider.fetchDashboard(withLoading: false);
      expect(provider.dashboard.parentOrders?.length, 8);
      expect(provider.dashboard.products?.length, 3);
      expect(provider.kpiTotalPesanan, 8);

      await provider.fetchOrders(withLoading: false);
      expect(provider.orders.data?.length, 2);
      expect(provider.filteredOrders.length, 2);

      await provider.fetchTeam(withLoading: false);
      expect(provider.team.data?.length, 2);
      expect(provider.team.data![0].fullName, 'Vivi Jailani');
    });
  });
}
