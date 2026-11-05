import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:simaru/models/booking_model.dart';
import 'package:simaru/models/pemesanan%20ruangan/ruangan_model.dart';
import 'package:simaru/models/schedule_model.dart';
import 'package:simaru/pages/home/bottomsheet/home_page.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/pesan_ruang_provider.dart';
import 'package:simaru/provider/schedule_provider.dart';

class FakeRooms extends PesanRuangProvider {
  FakeRooms() {
    ruangan = [
      RuanganModel(id: 1, name: 'Ruang A'),
      RuanganModel(id: 2, name: 'Ruang B'),
    ];
  }

  @override
  Future<void> bookingroom(int? id, String? token) async {}
}

class FakeSchedules extends ScheduleProvider {
  FakeSchedules([List<ScheduleModel> rooms = const []]) {
    schedule = rooms;
  }

  @override
  Future<void> schedules(String? token) async {}
}

void main() {
  Future<void> showHome(
      WidgetTester tester, List<ScheduleModel> schedules) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider<PesanRuangProvider>(create: (_) => FakeRooms()),
        ChangeNotifierProvider<ScheduleProvider>(
            create: (_) => FakeSchedules(schedules)),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, child) => const MaterialApp(home: HomePage()),
      ),
    ));
    await tester.pump();
  }

  testWidgets('home hides empty schedule and shows rooms without count cards',
      (tester) async {
    await showHome(tester, []);

    expect(find.text('Jadwal Ruangan'), findsNothing);
    expect(find.text('Ruang A'), findsOneWidget);
    expect(find.text('Ruang B'), findsOneWidget);
    expect(find.text('Informasi Ruangan'), findsOneWidget);
    expect(find.text('Kosong'), findsNothing);
    expect(find.text('Sudah Dipesan'), findsNothing);
    expect(find.text('No booking data'), findsNothing);
  });

  testWidgets('approved booking appears; finished room stays in room list',
      (tester) async {
    await showHome(tester, [
      ScheduleModel(
        id: 1,
        name: 'Ruang A',
        bookings: [
          BookingModel(
              status: 'APPROVED',
              bookingStartDate: '2099-01-01 09:00:00',
              bookingEndDate: '2099-01-01 10:00:00'),
        ],
      ),
      ScheduleModel(
        id: 2,
        name: 'Ruang B',
        bookings: [
          BookingModel(
              status: 'DONE',
              bookingStartDate: '2099-01-01 09:00:00',
              bookingEndDate: '2099-01-01 10:00:00'),
        ],
      ),
    ]);

    expect(find.text('Jadwal Ruangan'), findsOneWidget);
    expect(find.text('Ruang A'), findsNWidgets(2));
    expect(find.text('Ruang B'), findsOneWidget);
    expect(find.text('Informasi Ruangan'), findsOneWidget);
  });
}
