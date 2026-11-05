import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:simaru/models/riwayat%20ruangan/riwayat_model.dart';
import 'package:simaru/pages/riwayat%20pemesanan/riwayat_page.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/riwayat_provider.dart';
import 'package:simaru/themes.dart';
import 'package:simaru/widget/riwayat_card.dart';

class TestHistoryProvider extends RiwayatProvider {
  @override
  Future<void> notifacation(String? token) async {}
}

void main() {
  for (final scenario in [
    (390.0, 1),
    (800.0, 2),
    (1200.0, 3),
    (1600.0, 4),
    (1920.0, 5)
  ]) {
    testWidgets('history width ${scenario.$1} uses ${scenario.$2} columns',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(scenario.$1, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      blueTextStyle = const TextStyle();
      blackTextStyle = const TextStyle();
      whiteTextStyle = const TextStyle();
      final provider = TestHistoryProvider()
        ..notif = List.generate(
            11,
            (i) => RiwayatModel.fromJson({
                  'booking_id': i,
                  'status': i.isEven ? 'PENDING' : 'CANCELED',
                  'room': {'name': 'Ruangan $i', 'image': ''},
                  'booking_start_date': '2099-01-01 10:00:00',
                  'participant_internal': 20,
                  'description': 'Agenda rapat',
                }));
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider<RiwayatProvider>.value(value: provider),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          fontSizeResolver: (size, instance) =>
              size * (instance.screenWidth / 390).clamp(0.85, 1.2),
          builder: (_, child) => const MaterialApp(home: RiwayatPage()),
        ),
      ));
      await tester.pumpAndSettle();
      final cards = find.byType(RiwayatCard);
      final first = tester.getRect(cards.at(0));
      for (var i = 1; i < scenario.$2; i++) {
        final rect = tester.getRect(cards.at(i));
        expect(rect.top, first.top);
        expect(rect.left, greaterThan(first.left));
        expect(rect.width, closeTo(first.width, 0.01));
      }
      expect(tester.getRect(cards.at(scenario.$2)).top, greaterThan(first.top));
      final photo =
          find.descendant(of: cards.first, matching: find.byType(AspectRatio));
      final photoSize = tester.getSize(photo);
      expect(photoSize.width / photoSize.height, closeTo(16 / 9, 0.01));
      expect(
          tester
              .widget<Image>(
                  find.descendant(of: photo, matching: find.byType(Image)))
              .fit,
          BoxFit.contain);
      await tester.scrollUntilVisible(find.text('Ruangan 10'), 250,
          scrollable: find.byType(Scrollable));
      await tester.pumpAndSettle();
      expect(find.text('Ruangan 10'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
