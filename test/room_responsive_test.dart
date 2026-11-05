import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:simaru/models/pemesanan%20ruangan/ruangan_model.dart';
import 'package:simaru/pages/pesan%20ruang%20baru/ruangan_page.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/pesan_ruang_provider.dart';
import 'package:simaru/themes.dart';

class FakeRooms extends PesanRuangProvider {
  @override
  List<RuanganModel> get ruangan => [
        RuanganModel(
          id: 1,
          name: 'Ruang Rapat Utama dengan Nama yang Panjang',
          floor: 2,
          capacity: 120,
          image: '',
        ),
      ];

  @override
  Future<void> bookingroom(int? id, String? token) async {}
}

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(844, 390),
    const Size(768, 1024),
  ]) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets('Room layout $size text scale $textScale', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        // Use local test fonts so the layout test never fetches Google Fonts.
        blueTextStyle = const TextStyle();
        blackTextStyle = const TextStyle();
        whiteTextStyle = const TextStyle();
        await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider<PesanRuangProvider>(
                create: (_) => FakeRooms()),
          ],
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            splitScreenMode: true,
            fontSizeResolver: (fontSize, instance) =>
                fontSize * (instance.screenWidth / 390).clamp(0.85, 1.2),
            builder: (_, child) => MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(textScale),
                  padding: const EdgeInsets.only(top: 44, bottom: 24),
                ),
                child: child!,
              ),
              home: const RoomPage(roomId: 1),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(find.text('Pesan'), findsOneWidget);
        expect(find.text('Lihat Jadwal'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(find.text('Informasi Ruangan'), 150,
            scrollable: find.byType(Scrollable), maxScrolls: 40);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Informasi Ruangan'), findsOneWidget);
      });
    }
  }
}
