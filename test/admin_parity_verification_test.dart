import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mspeed/src/admin/master/view/master_admin_view.dart';
import 'package:mspeed/src/admin/transaksi/model/dpp_admin_model.dart';
import 'package:mspeed/src/admin/transaksi/provider/transaction_admin_provider.dart';
import 'package:mspeed/src/admin/transaksi/view/data_dpp_admin_view.dart';
import 'package:mspeed/src/admin/transaksi/view/data_order_admin_view.dart';
import 'package:mspeed/src/admin/transaksi/view/transaksi_admin_view.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/src/admin/user/view/user_admin_view.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';
import 'package:mspeed/src/buyer/transaction/model/detail_tansaction_buyer_model.dart';
import 'package:provider/provider.dart';

class MockTransactionAdminProvider extends TransactionAdminProvider {
  @override
  Future<void> fetchList({bool withLoading = false, String search = ''}) async {}
  @override
  Future<void> fetchList2({bool withLoading = false, String search = ''}) async {}
}

class MockAdminUserProvider extends AdminUserProvider {
  @override
  Future<void> fetchSellers({bool withLoading = false, String search = '', int page = 1}) async {}
  @override
  Future<void> fetchBuyers({bool withLoading = false, String search = '', int page = 1}) async {}
  @override
  Future<void> fetchDireksi({bool withLoading = false, String search = '', int page = 1}) async {}
  @override
  Future<void> fetchAudit({bool withLoading = false, String search = '', int page = 1}) async {}
  @override
  Future<void> fetchKeuangan({bool withLoading = false, String search = '', int page = 1}) async {}
  @override
  Future<void> fetchPenerima({bool withLoading = false, String search = '', int page = 1}) async {}
  @override
  Future<void> fetchManager({bool withLoading = false, String search = '', int page = 1}) async {}
}

void main() {
  setUpAll(() {
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorColor = Colors.white;
  });

  group('PHASE 33 — Admin Mobile Parity Tests', () {
    testWidgets('1. UserAdminView contains exactly 7 items with website terminology', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: UserAdminView(),
        ),
      );
      await tester.pumpAndSettle();

      // Check User Menu Titles
      expect(find.text('Buyer'), findsOneWidget);
      expect(find.text('Seller'), findsOneWidget);
      expect(find.text('Keuangan'), findsOneWidget);
      expect(find.text('Penerima'), findsOneWidget);
      expect(find.text('Manager'), findsOneWidget);
      expect(find.text('Direksi'), findsOneWidget);
      expect(find.text('Audit'), findsOneWidget);

      // Verify Sub-Direktorat is NOT in User Management
      expect(find.text('Data Sub-Direktorat'), findsNothing);
      expect(find.text('Sub-Direktorat'), findsNothing);
      expect(find.text('Subdirektorat'), findsNothing);

      // Verify no "Data " prefixes in main menu cards
      expect(find.text('Data Finance'), findsNothing);
      expect(find.text('Data Penerima'), findsNothing);
      expect(find.text('Data Manager'), findsNothing);
      expect(find.text('Data Audit'), findsNothing);
      expect(find.text('Data Direksi'), findsNothing);

      // Verify category count badge is 7
      expect(find.text('7 kategori'), findsOneWidget);
    });

    testWidgets('2. MasterAdminView contains Subdirektorat, Alamat, Pajak, Kategori, E-Materai, Banner', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: MasterAdminView(),
        ),
      );
      await tester.pumpAndSettle();

      // Check Master Menu Titles
      expect(find.text('Subdirektorat'), findsOneWidget);
      expect(find.text('Alamat'), findsOneWidget);
      expect(find.text('Pajak'), findsOneWidget);
      expect(find.text('Kategori'), findsOneWidget);
      expect(find.text('E-Materai'), findsOneWidget);
      expect(find.text('Banner'), findsOneWidget);

      // Verify old names are replaced
      expect(find.text('Subdit'), findsNothing);
      expect(find.text('Materai'), findsNothing);

      // Verify count badge
      expect(find.text('6 menu'), findsOneWidget);
    });

    testWidgets('3. TransaksiAdminView contains DPP and Transaksi', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: TransaksiAdminView(),
        ),
      );
      await tester.pumpAndSettle();

      // Check Transaction Menu Titles
      expect(find.text('DPP'), findsOneWidget);
      expect(find.text('Transaksi'), findsOneWidget);

      // Verify old names are replaced
      expect(find.text('Data DPP'), findsNothing);
      expect(find.text('Data Order'), findsNothing);

      // Verify count badge
      expect(find.text('2 kategori'), findsOneWidget);
    });

    test('4. UserDataType enum titles match clean terminology', () {
      expect(UserDataType.BUYER.title, 'Buyer');
      expect(UserDataType.SELLER.title, 'Seller');
      expect(UserDataType.FINANCE.title, 'Keuangan');
      expect(UserDataType.PENERIMA.title, 'Penerima');
      expect(UserDataType.MANAGER.title, 'Manager');
      expect(UserDataType.AUDIT.title, 'Audit');
      expect(UserDataType.DIREKSI.title, 'Direksi');
      expect(UserDataType.SUB_DIREKTORAT.title, 'Subdirektorat');
    });

    testWidgets('5. DataOrderAdminView renders real transactions parity structure', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = MockTransactionAdminProvider();
      provider.orders = [
        DetailTransaksiBuyerModelDataParentOrderModel(
          ID: '1',
          nomorOrder: 'ORD-202667674',
          nama: 'Harsanto',
          SellerNama: 'Yayasan Simanjuntak PT',
          PenerimaNama: 'Jaiman',
          total: '1453899',
          status: 'unpaid',
          Created: '2026-09-01T13:38:29.000000Z',
        ),
        DetailTransaksiBuyerModelDataParentOrderModel(
          ID: '134',
          nomorOrder: 'TEST-AUDIT-6a97e20718a0e',
          nama: 'Harsanto',
          SellerNama: 'Perum Namaga Namaga PT',
          PenerimaNama: 'Hamima',
          total: '1453899',
          status: 'pesanan dibayar',
          Created: '2026-09-02T08:44:55.000000Z',
        ),
      ];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TransactionAdminProvider>.value(value: provider),
          ],
          child: const MaterialApp(
            home: DataOrderAdminView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ORD-202667674'), findsOneWidget);
      expect(find.text('TEST-AUDIT-6a97e20718a0e'), findsOneWidget);
      expect(find.text('Yayasan Simanjuntak PT'), findsOneWidget);
      expect(find.text('Perum Namaga Namaga PT'), findsOneWidget);
    });

    testWidgets('6. DataDppAdminView renders real DPP parity structure', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = MockTransactionAdminProvider();
      provider.dpp = DppAdminModel(
        result: 'success',
        data: [
          DppAdminModelData(
            ID: '1',
            nomorPermintaan: '86909/DPP/H207/III/2026',
            jumlahPrk: '19000172',
            nilaiPrk: '100000000',
            sisa: '80999828',
            status: '1',
          ),
          DppAdminModelData(
            ID: '7',
            nomorPermintaan: '31059/DPP/H207/III/2026',
            jumlahPrk: '9638385',
            nilaiPrk: '100000000',
            sisa: '90361615',
            status: '1',
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TransactionAdminProvider>.value(value: provider),
          ],
          child: const MaterialApp(
            home: DataDppAdminView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('86909/DPP/H207/III/2026'), findsOneWidget);
      expect(find.text('31059/DPP/H207/III/2026'), findsOneWidget);
    });

    testWidgets('7. PHASE 34 — UserAdminView AppBar title is "User Data"', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: UserAdminView(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('User Data'), findsOneWidget);
      expect(find.text('Manajemen User'), findsNothing);
    });

    testWidgets('8. PHASE 34 — Seller card renders "Tidak Aktif" and website fields', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final p = MockAdminUserProvider();
      p.userData = [
        UserData(
          name1: 'Perum Namaga Namaga PT',
          name2: 'Irma Latika Padmasari S.I.Kom',
          email: 'seller1@example.com',
          id: '121',
          alamat: 'Gg. Ikan No. 402, Kelurahan Eum., Kecamatan Quis., Kabupaten Manokwari, Papua Barat',
          status: 'Tidak Aktif',
          telp: '(+62) 693 4223 3409',
          kelengkapan: '100%',
        ),
      ];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AdminUserProvider>.value(value: p),
          ],
          child: MaterialApp(
            builder: EasyLoading.init(),
            home: const UserDataAdminView(userType: UserDataType.SELLER),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Perum Namaga Namaga PT'), findsOneWidget);
      expect(find.text('seller1@example.com'), findsOneWidget);
      expect(find.text('Tidak Aktif'), findsOneWidget);
      expect(find.text('Irma Latika Padmasari S.I.Kom'), findsOneWidget);
      expect(find.text('(+62) 693 4223 3409'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('9. PHASE 34 — Direksi and Audit cards do NOT render status badge', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final p = MockAdminUserProvider();
      p.userData = [
        UserData(
          name1: 'Hamima',
          name2: 'Sudiati',
          email: 'direksi1@example.com',
          id: '101',
          telp: '(+62) 812 3456 7890',
        ),
      ];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AdminUserProvider>.value(value: p),
          ],
          child: MaterialApp(
            builder: EasyLoading.init(),
            home: const UserDataAdminView(userType: UserDataType.DIREKSI),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hamima'), findsOneWidget);
      expect(find.text('direksi1@example.com'), findsOneWidget);
      expect(find.text('Sudiati'), findsOneWidget);
      expect(find.text('Aktif'), findsNothing);
      expect(find.text('Tidak Aktif'), findsNothing);
    });
  });
}
