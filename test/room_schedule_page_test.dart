import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:simaru/models/booking_model.dart';
import 'package:simaru/models/schedule_model.dart';
import 'package:simaru/pages/jadwal%20ruang/room_schedule_page.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/services/scheduledetails_service.dart';
import 'package:simaru/themes.dart';
import 'package:simaru/widget/room_schedule_card.dart';

class FakeScheduleDetails extends ScheduleDetailsService {
  FakeScheduleDetails(this.bookings);
  final List<BookingModel> bookings;
  @override
  Future<ScheduleModel> schedule(int? id, String? token) async =>
      ScheduleModel(id: id, name: 'Wilis', bookings: bookings);
}

void main() {
  Future<void> show(
      WidgetTester tester, List<BookingModel> entries, DateTime Function() now,
      {double scale = 1, double width = 390}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    blueTextStyle = blackTextStyle = whiteTextStyle = const TextStyle();
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, child) => MaterialApp(
                builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(scale)),
                    child: child!),
                home: RoomSchedulePage(
                    roomId: 7,
                    roomName: 'Wilis',
                    service: FakeScheduleDetails(entries),
                    now: now),
              )),
    ));
    await tester.pump();
  }

  BookingModel booking(String description, int start, int end) => BookingModel(
        description: description,
        status: 'APPROVED',
        bookingStartDate:
            '2026-10-01 ${start.toString().padLeft(2, '0')}:00:00',
        bookingEndDate: '2026-10-01 ${end.toString().padLeft(2, '0')}:00:00',
        participantInternal: 12,
        participantExternal: 8,
      );

  testWidgets(
      'cards show chronological dates, descriptions, hours, participants and phases',
      (tester) async {
    await show(
        tester,
        [
          booking('Rapat sore', 13, 16),
          booking('Rapat pagi', 8, 9),
          booking('Rapat tim', 10, 11)
        ],
        () => DateTime(2026, 10, 1, 10));
    expect(find.text('Wilis'), findsOneWidget);
    expect(find.text('1 Oktober 2026'), findsNWidgets(3));
    expect(find.text('Jumlah partisipan 20 orang'), findsNWidgets(3));
    expect(find.text('Pukul 10.00 - 11.00'), findsOneWidget);
    expect(find.text('SELESAI'), findsOneWidget);
    expect(find.text('SEDANG BERLANGSUNG'), findsOneWidget);
    expect(find.text('AKAN DATANG'), findsOneWidget);
    final cards = tester
        .widgetList<RoomScheduleCard>(find.byType(RoomScheduleCard))
        .toList();
    expect(cards.map((c) => c.booking.description),
        ['Rapat pagi', 'Rapat tim', 'Rapat sore']);
    expect(cards.map((c) => c.phase), [
      RoomSchedulePhase.finished,
      RoomSchedulePhase.ongoing,
      RoomSchedulePhase.upcoming
    ]);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'time status changes and finished card disappears at midnight without reopening',
      (tester) async {
    var now = DateTime(2026, 10, 1, 9, 59, 59);
    await show(tester, [booking('Rapat tim', 10, 11)], () => now);
    expect(find.text('AKAN DATANG'), findsOneWidget);
    now = DateTime(2026, 10, 1, 10);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('SEDANG BERLANGSUNG'), findsOneWidget);
    now = DateTime(2026, 10, 1, 23, 59, 59);
    await tester.pump(const Duration(minutes: 1));
    await tester.pump();
    expect(find.text('SELESAI'), findsOneWidget);
    now = DateTime(2026, 10, 2);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(RoomScheduleCard), findsNothing);
    expect(find.text('Belum ada jadwal ruangan'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('schedule card wraps on narrow screen with large text',
      (tester) async {
    await show(
        tester,
        [booking('Rapat koordinasi kegiatan untuk seluruh divisi', 10, 11)],
        () => DateTime(2026, 10, 1, 10),
        width: 320,
        scale: 2);
    expect(find.text('SEDANG BERLANGSUNG'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
