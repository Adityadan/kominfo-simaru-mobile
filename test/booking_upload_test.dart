import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:simaru/services/booking_service.dart';
import 'package:simaru/services/booking_attachment_file.dart';
import 'package:simaru/provider/booking_room_provider.dart';

void main() {
  for (final division in [null, 3]) {
    test('provider sends multipart directly with division $division', () async {
      var calls = 0;
      final provider = BookingRoomProvider(
          service: BookingService(client: MockClient((request) async {
        calls++;
        expect(request.method, 'POST');
        expect(request.url.path, '/api/booking');
        expect(request.headers['content-type'],
            startsWith('multipart/form-data;'));
        expect(request.headers['authorization'], 'Bearer test-token');
        final body = request.body;
        final fields = {
          'start_date': '2026-10-01 09:00:00',
          'end_date': '2026-10-01 10:00:00',
          'name': 'Pemesan',
          'nip': '123456',
          'phone': '08123456789',
          'room_id': '5',
          'division_id': division?.toString() ?? '',
          'description': 'Rapat',
          'participant_internal': '10',
          'participant_external': '0',
          'participant_type': 'INTERNAL',
        };
        for (final field in fields.entries) {
          expect(
              body,
              matches(RegExp(
                  'name="${field.key}"\r\n(?:[^\r\n]+\r\n)*\r\n${RegExp.escape(field.value)}\r\n')));
        }
        expect(body, contains('name="attachment"; filename="surat.pdf"'));
        expect(body, contains('content-type: application/pdf'));
        expect(body, contains('%PDF-test'));
        return http.Response(
            jsonEncode({
              'data': {
                'id': '12',
                'room_id': '5',
                'member_id': '9',
                'division_id': division?.toString(),
                'start_date': fields['start_date'],
                'end_date': fields['end_date'],
                'participant_internal': 10,
                'participant_external': '0',
              }
            }),
            201);
      })));
      final success = await provider.bookingRoom(
        token: 'test-token',
        name: 'Pemesan',
        nip: '123456',
        phone: '08123456789',
        roomid: 5,
        devision: division,
        description: 'Rapat',
        startDate: '2026-10-01 09:00:00',
        endDate: '2026-10-01 10:00:00',
        participantInternal: '10',
        participanttype: 'INTERNAL',
        attachmentBytes: Uint8List.fromList(utf8.encode('%PDF-test')),
        attachmentName: 'surat.pdf',
      );
      expect(success, true, reason: provider.errorMessage);
      expect(calls, 1);
      expect(provider.errorMessage, isNull);
      final booking = provider.bookingroom.single;
      expect(booking.id, 12);
      expect(booking.idRoom, 5);
      expect(booking.devisi, division);
      expect(booking.bookingStartDate, '2026-10-01 09:00:00');
      expect(booking.bookingEndDate, '2026-10-01 10:00:00');
      expect(booking.participantInternal, '10');
      expect(booking.participantExternal, '0');
      expect(booking.toJson()['room_id'], 5);
      expect(booking.toJson()['start_date'], booking.bookingStartDate);
    });
  }

  test('local file path uploads as multipart and accepts legacy response dates',
      () async {
    final directory = await Directory.systemTemp.createTemp('booking-test-');
    addTearDown(() => directory.delete(recursive: true));
    final file =
        await File('${directory.path}/surat.pdf').writeAsString('%PDF-local');
    final service = BookingService(client: MockClient((request) async {
      expect(request.url.path, '/api/booking');
      expect(request.body, contains('filename="surat.pdf"'));
      expect(request.body, contains('content-type: application/pdf'));
      expect(request.body, contains('%PDF-local'));
      return http.Response(
          '{"data":{"id":1,"booking_start_date":"2026-10-01 09:00:00","booking_end_date":"2026-10-01 10:00:00"}}',
          200);
    }));
    final booking = await service.booking(attachment: file.path);
    expect(booking.bookingStartDate, '2026-10-01 09:00:00');
    expect(booking.bookingEndDate, '2026-10-01 10:00:00');
  });

  test('booking attachment MIME type follows the file extension', () {
    expect(bookingAttachmentType('SURAT.PDF').toString(), 'application/pdf');
    expect(bookingAttachmentType('foto.jpg').toString(), 'image/jpeg');
    expect(bookingAttachmentType('surat.docx').toString(),
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
  });

  test('picked PDF can be read from its path when bytes are absent', () async {
    final directory = await Directory.systemTemp.createTemp('booking-pdf-');
    addTearDown(() => directory.delete(recursive: true));
    final file =
        await File('${directory.path}/surat.pdf').writeAsString('%PDF-path');
    final picked = PlatformFile(name: 'surat.pdf', size: 9, path: file.path);
    expect(
        utf8.decode((await readBookingAttachmentBytes(picked))!), '%PDF-path');
  });

  test('empty attachment prevents HTTP calls', () async {
    var calls = 0;
    final provider = BookingRoomProvider(
        service: BookingService(client: MockClient((_) async {
      calls++;
      return http.Response('{}', 200);
    })));
    expect(await provider.bookingRoom(), false);
    expect(provider.errorMessage, contains('Lampiran wajib'));
    expect(calls, 0);
  });
  test('booking accepts an attachment larger than 1 MB', () async {
    var calls = 0;
    final service = BookingService(client: MockClient((request) async {
      calls++;
      expect(request.url.path, '/api/booking');
      return http.Response('{"data":{"id":1}}', 201);
    }));
    await service.booking(
        attachmentBytes: Uint8List(1024 * 1024 + 1),
        attachmentName: 'surat.pdf');
    expect(calls, 1);
  });
  test('booking rejects an attachment of 5 MB before HTTP', () async {
    var calls = 0;
    final service = BookingService(client: MockClient((_) async {
      calls++;
      return http.Response('{}', 200);
    }));
    await expectLater(
        service.booking(
            attachmentBytes: Uint8List(maxBookingAttachmentBytes),
            attachmentName: 'surat.pdf'),
        throwsA(isA<Exception>().having((error) => error.toString(), 'message',
            contains('kurang dari 5 MB'))));
    expect(calls, 0);
  });
  test('bytes without local path upload before booking and preserve division',
      () async {
    final paths = <String>[];
    final service = BookingService(client: MockClient((request) async {
      paths.add(request.url.path);
      if (request.url.path.endsWith('/upload-raw')) {
        expect(request.bodyBytes, [1, 2, 3]);
        expect(request.headers['X-Filename'], 'surat.pdf');
        return http.Response(
            '{"data":{"url":"https://example.test/surat.pdf"}}', 201);
      }
      final body = jsonDecode(request.body);
      expect(body['attachment'], 'https://example.test/surat.pdf');
      expect(body['division_id'], 3);
      return http.Response('{"data":{"id":1}}', 201);
    }));
    await service.booking(
        uploadMode: 'raw',
        devision: 3,
        attachmentBytes: Uint8List.fromList([1, 2, 3]),
        attachmentName: 'surat.pdf');
    expect(paths, ['/api/booking/upload-raw', '/api/booking']);
  });
  test('multipart rejection exposes server validation', () async {
    var calls = 0;
    final provider = BookingRoomProvider(
        service: BookingService(client: MockClient((request) async {
      calls++;
      expect(request.url.path, '/api/booking');
      return http.Response(
          '{"errors":{"attachment":["Berkas terlalu besar"]}}', 422);
    })));
    expect(
        await provider.bookingRoom(
            attachmentBytes: Uint8List.fromList([1]),
            attachmentName: 'surat.pdf'),
        false);
    expect(calls, 1);
    expect(provider.errorMessage, 'Berkas terlalu besar');
  });
  test('HTML response with HTTP 413 reports server upload limit', () async {
    var calls = 0;
    final provider = BookingRoomProvider(
        service: BookingService(client: MockClient((request) async {
      calls++;
      expect(request.url.path, '/api/booking');
      return http.Response('<html>Request Entity Too Large</html>', 413);
    })));
    expect(
        await provider.bookingRoom(
            attachmentBytes: Uint8List.fromList([1]),
            attachmentName: 'surat.pdf'),
        false);
    expect(provider.errorMessage, contains('HTTP 413'));
    expect(provider.errorMessage, contains('Server menolak ukuran unggahan'));
    expect(calls, 1, reason: 'Jangan mengulang booking lewat endpoint lain.');
  });
  test('missing upload URL stops booking', () async {
    var calls = 0;
    final service = BookingService(client: MockClient((_) async {
      calls++;
      return http.Response('{"data":{}}', 200);
    }));
    await expectLater(
        service.booking(
            uploadMode: 'raw',
            attachmentBytes: Uint8List.fromList([1]),
            attachmentName: 'surat.pdf'),
        throwsException);
    expect(calls, 1);
  });
}
