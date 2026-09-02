import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mspeed/common/component/impersonation_banner_widget.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/src/keuangan/pesanan/provider/keuangan_provider.dart';
import 'package:mspeed/src/manager/pesanan/provider/manager_provider.dart';
import 'package:mspeed/src/penerima/pesanan/provider/penerima_pesanan_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Impersonation Banner UI & State Tests', () {
    testWidgets('ImpersonationBannerWidget is VISIBLE with Kembali ke Admin button when impersonating', (tester) async {
      SharedPreferences.setMockInitialValues({
        'is_impersonated': true,
        'admin_original_token': 'test_admin_token_123',
        'admin_original_id': '141',
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AdminUserProvider()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ImpersonationBannerWidget(roleName: 'Buyer'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert Banner and Button are VISIBLE
      expect(find.text('Mode Impersonate Aktif'), findsOneWidget);
      expect(find.text('Sesi: Buyer'), findsOneWidget);
      expect(find.text('Kembali ke Admin'), findsOneWidget);
    });

    testWidgets('ImpersonationBannerWidget is HIDDEN (absent) when normal login (not impersonating)', (tester) async {
      SharedPreferences.setMockInitialValues({
        'is_impersonated': false,
        'admin_original_token': '',
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AdminUserProvider()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ImpersonationBannerWidget(roleName: 'Buyer'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert Banner and Button are COMPLETELY ABSENT
      expect(find.text('Mode Impersonate Aktif'), findsNothing);
      expect(find.text('Kembali ke Admin'), findsNothing);
    });

    test('Finance provider loads isImpersonated = true when impersonated', () async {
      SharedPreferences.setMockInitialValues({
        'is_impersonated': true,
        'admin_original_token': 'admin_token_xyz',
      });

      final financeProvider = KeuanganProvider();
      await financeProvider.loadProfile();
      expect(financeProvider.isImpersonated, isTrue);
    });

    test('Finance provider loads isImpersonated = false on normal login', () async {
      SharedPreferences.setMockInitialValues({
        'is_impersonated': false,
        'admin_original_token': '',
      });

      final financeProvider = KeuanganProvider();
      await financeProvider.loadProfile();
      expect(financeProvider.isImpersonated, isFalse);
    });

    test('Manager provider loads isImpersonated = true when impersonated', () async {
      SharedPreferences.setMockInitialValues({
        'is_impersonated': true,
        'admin_original_token': 'admin_token_xyz',
      });

      final managerProvider = ManagerProvider();
      await managerProvider.loadProfile();
      expect(managerProvider.isImpersonated, isTrue);
    });

    test('Manager provider loads isImpersonated = false on normal login', () async {
      SharedPreferences.setMockInitialValues({
        'is_impersonated': false,
        'admin_original_token': '',
      });

      final managerProvider = ManagerProvider();
      await managerProvider.loadProfile();
      expect(managerProvider.isImpersonated, isFalse);
    });

    test('Receiver provider loads isImpersonated = true when impersonated', () async {
      SharedPreferences.setMockInitialValues({
        'is_impersonated': true,
        'admin_original_token': 'admin_token_xyz',
      });

      final receiverProvider = PenerimaPesananProvider();
      await receiverProvider.loadProfile();
      expect(receiverProvider.isImpersonated, isTrue);
    });

    test('Receiver provider loads isImpersonated = false on normal login', () async {
      SharedPreferences.setMockInitialValues({
        'is_impersonated': false,
        'admin_original_token': '',
      });

      final receiverProvider = PenerimaPesananProvider();
      await receiverProvider.loadProfile();
      expect(receiverProvider.isImpersonated, isFalse);
    });
  });
}
