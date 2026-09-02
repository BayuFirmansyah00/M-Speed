import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mspeed/src/admin/master/view/master_admin_view.dart';
import 'package:mspeed/src/admin/transaksi/view/transaksi_admin_view.dart';
import 'package:mspeed/src/admin/user/view/user_admin_view.dart';
import 'package:mspeed/src/admin/user/view/user_data_admin_view.dart';

void main() {
  group('PHASE 32 — Admin Mobile Parity Tests', () {
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
  });
}
