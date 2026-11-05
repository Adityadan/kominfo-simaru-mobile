import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:simaru/models/riwayat%20ruangan/riwayat_model.dart';
import 'package:simaru/provider/riwayat_provider.dart';
import 'package:simaru/themes.dart';
import 'package:simaru/widget/riwayat_card.dart';

RiwayatModel booking(int id, String status) => RiwayatModel.fromJson({
      'booking_id': '$id',
      'name': 'Pemesan $id',
      'nip': '123456789',
      'phone': '08123456789',
      'division': {'name': 'Data dan Statistik'},
      'booking_date': '2026-09-18 00:45:00',
      'booking_start_date': '2099-09-23 10:00:00',
      'booking_end_date': '2099-09-23 13:00:00',
      'status': status,
      'participant_type': 'INTERNAL',
      'participant_internal': '22',
      'participant_external': 0,
      'description': 'Agenda booking $id',
      'room': {'id': id, 'name': 'Ruang $id', 'image': ''},
    });

void main() {
  test('API aliases and booking status control actions', () {
    final result = RiwayatModel.fromJson({
      'id': '51',
      'start_date': '2099-01-01 09:00:00',
      'end_date': '2099-01-01 10:00:00',
      'status': 'CANCELED',
    });
    expect(result.idBooking, 51);
    expect(result.bookingStartDate, '2099-01-01 09:00:00');
    expect(result.canUpdateAttachment, false);
    expect(result.canReview, false);
    expect(result.statusLabel, 'Dibatalkan');
    expect(booking(1, 'APPROVED').statusLabel, 'Disetujui');
    expect(booking(1, 'DONE').statusLabel, 'Selesai');
    expect(booking(1, 'APPROVED').canUpdateAttachment, true);
    expect(booking(1, 'DONE').canUpdateAttachment, false);
    expect(booking(1, 'DONE').canReview, true);
  });

  for (final scale in [1.0, 2.0]) {
    for (final status in ['PENDING', 'APPROVED', 'DONE', 'CANCELED']) {
      testWidgets('selected API booking detail $status scale $scale',
          (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        blueTextStyle = const TextStyle();
        blackTextStyle = const TextStyle();
        whiteTextStyle = const TextStyle();
        final selected = booking(2, status);
        final provider = RiwayatProvider()
          ..notif = [booking(1, 'PENDING'), selected];
        await tester.pumpWidget(ChangeNotifierProvider.value(
          value: provider,
          child: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (_, child) => MaterialApp(
                    builder: (context, child) => MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: TextScaler.linear(scale)),
                        child: child!),
                    home: Scaffold(
                        body: SingleChildScrollView(
                            child: RiwayatCard(selected))),
                  )),
        ));
        await tester.pumpAndSettle();
        expect(find.text('BATALKAN'),
            status == 'PENDING' ? findsOneWidget : findsNothing);
        await tester.ensureVisible(find.text('DETAIL'));
        await tester.tap(find.text('DETAIL'));
        await tester.pumpAndSettle();
        expect(find.text('Detail Pemesanan'), findsOneWidget);
        expect(find.text('Pemesan 2'), findsOneWidget);
        expect(find.text('Pemesan 1'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(find.text('Lampiran'), 180,
            scrollable: find.byType(Scrollable).last);
        await tester.pumpAndSettle();
        expect(find.text('Belum ada lampiran'), findsOneWidget);
        expect(find.text('Agenda booking 2'), findsOneWidget);
        expect(
            find.text('Update Attachment'),
            status == 'PENDING' || status == 'APPROVED'
                ? findsOneWidget
                : findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
