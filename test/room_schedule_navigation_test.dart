import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:simaru/models/booking_model.dart';
import 'package:simaru/models/pemesanan%20ruangan/ruangan_model.dart';
import 'package:simaru/models/schedule_model.dart';
import 'package:simaru/pages/home/bottomsheet/home_page.dart';
import 'package:simaru/pages/jadwal%20ruang/room_schedule_page.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/pesan_ruang_provider.dart';
import 'package:simaru/provider/schedule_provider.dart';
import 'package:simaru/themes.dart';
import 'package:simaru/widget/unvailableroom_card.dart';

class FakeRooms extends PesanRuangProvider {
  @override
  bool get hasLoaded => true;
  @override
  List<RuanganModel> get ruangan => [RuanganModel(id: 7, name: 'Wilis')];
  @override
  Future<void> bookingroom(int? id, String? token) async {}
}

class FakeSchedules extends ScheduleProvider {
  @override
  bool get hasLoaded => true;
  @override
  List<ScheduleModel> get schedule => [
        ScheduleModel(id: 7, name: 'Wilis', bookings: [
          BookingModel(
              status: 'APPROVED',
              bookingStartDate: DateTime.now()
                  .subtract(const Duration(minutes: 10))
                  .toIso8601String(),
              bookingEndDate: DateTime.now()
                  .add(const Duration(hours: 1))
                  .toIso8601String()),
        ])
      ];
  @override
  Future<void> schedules(String? token) async {}
}

class RecordRoutes extends NavigatorObserver {
  Route<dynamic>? lastRoute;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      lastRoute = route;
}

void main() {
  for (final fromHome in [true, false]) {
    testWidgets(
        '${fromHome ? 'Home schedule' : 'schedule room card'} opens schedule for chosen room ID',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      blueTextStyle = blackTextStyle = whiteTextStyle = const TextStyle();
      final observer = RecordRoutes();
      await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider<PesanRuangProvider>(
                create: (_) => FakeRooms()),
            ChangeNotifierProvider<ScheduleProvider>(
                create: (_) => FakeSchedules()),
          ],
          child: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (_, child) => MaterialApp(
                    navigatorObservers: [observer],
                    home: fromHome
                        ? const HomePage()
                        : Scaffold(
                            body: UnvailableRoomCard(
                                RuanganModel(id: 7, name: 'Wilis'))),
                  ))));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Wilis').first);
      final context = tester.element(find.text('Wilis').first);
      await tester.tap(find.text('Wilis').first);
      // Inspect destination without mounting a live network-dependent route.
      final destination =
          (observer.lastRoute! as MaterialPageRoute).builder(context);
      expect(destination, isA<RoomSchedulePage>());
      expect((destination as RoomSchedulePage).roomId, 7);
      expect(destination.roomName, 'Wilis');
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
