import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:simaru/models/user_model.dart';
import 'package:simaru/pages/pesan%20ruang%20baru/form_pesan_ruang.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/booking_room_provider.dart';
import 'package:simaru/services/booking_service.dart';
import 'package:simaru/themes.dart';

class BookingFilePicker extends FilePicker {
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    return FilePickerResult([
      PlatformFile(
          name: 'surat.pdf',
          size: 9,
          bytes: Uint8List.fromList(utf8.encode('%PDF-test'))),
    ]);
  }
}

void main() {
  testWidgets('PDF booking works with picked bytes', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    blueTextStyle = const TextStyle();
    blackTextStyle = const TextStyle();
    whiteTextStyle = const TextStyle();
    FilePicker.platform = BookingFilePicker();
    var requests = 0;
    final bookings = BookingRoomProvider(service: BookingService(
      client: MockClient((request) async {
        requests++;
        expect(request.url.path, '/api/booking');
        expect(request.headers['content-type'],
            startsWith('multipart/form-data;'));
        expect(request.body, contains('name="room_id"\r\n\r\n5\r\n'));
        expect(request.body, contains('filename="surat.pdf"'));
        expect(request.body, contains('content-type: application/pdf'));
        return http.Response('{"data":{"id":1}}', 201);
      }),
    ));
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider()
              ..user = UserModel(
                  name: 'Pemesan', phone: '08123456789', token: 'test-token')),
        ChangeNotifierProvider.value(value: bookings),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, child) =>
            const MaterialApp(home: FormPesanRuanganPage(idRoom: 5)),
      ),
    ));
    await tester.pumpAndSettle();
    Finder field(String hint) => find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.hintText == hint);
    await tester.enterText(field('NIP'), '123456');
    await tester.enterText(field('Masukkan jumlah partisipasi'), '10');
    await tester.enterText(
        field('Jelaskan kegiatan yang akan dilakukan'), 'Rapat');
    // Dates are normally supplied by the native-style date picker.
    tester
        .widget<TextField>(field('Pilih tanggal & waktu mulai'))
        .controller!
        .text = '2026-10-01 09:00:00';
    tester
        .widget<TextField>(field('Pilih tanggal & waktu selesai'))
        .controller!
        .text = '2026-10-01 10:00:00';
    await tester.ensureVisible(find.text('Tambah File'));
    await tester.tap(find.text('Tambah File'));
    await tester.pumpAndSettle();
    expect(find.text('surat.pdf'), findsOneWidget);
    await tester.ensureVisible(find.text('Pesan'));
    await tester.tap(find.text('Pesan'));
    // Allow the request and success dialog to complete without waiting on Lottie loops.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(requests, 1);
    expect(bookings.errorMessage, isNull);
    expect(find.text('Ruangan Rapat Berhasil Dibooking.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
