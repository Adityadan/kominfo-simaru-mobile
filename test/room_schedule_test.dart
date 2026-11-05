import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:simaru/models/booking_model.dart';
import 'package:simaru/models/schedule_model.dart';
import 'package:simaru/services/scheduledetails_service.dart';

BookingModel entry(int id, String start, String end,
        {String status = 'APPROVED', String room = '7'}) =>
    BookingModel(
        id: id,
        idRoom: room,
        bookingStartDate: start,
        bookingEndDate: end,
        status: status);

void main() {
  final now = DateTime(2026, 10, 1, 10);
  test(
      'room schedule includes completed today, active, and future in time order',
      () {
    final room = ScheduleModel(id: 7, bookings: [
      entry(4, '2026-10-02 15:00:00', '2026-10-02 16:00:00'),
      entry(3, '2026-10-01 13:00:00', '2026-10-01 15:00:00'),
      entry(2, '2026-10-01 10:00:00', '2026-10-01 11:00:00'),
      entry(1, '2026-10-01 08:00:00', '2026-10-01 09:00:00'),
      entry(5, '2026-09-30 08:00:00', '2026-09-30 09:00:00'),
      entry(6, '2026-10-01 10:00:00', '2026-10-01 11:00:00', status: 'PENDING'),
      entry(7, '2026-10-01 10:00:00', '2026-10-01 11:00:00', room: '9'),
    ]);
    final visible = room.visibleBookingsAt(now);
    expect(visible.map((b) => b.id), [1, 2, 3, 4]);
    expect(visible.map((b) => b.roomSchedulePhaseAt(now)), [
      RoomSchedulePhase.finished,
      RoomSchedulePhase.ongoing,
      RoomSchedulePhase.upcoming,
      RoomSchedulePhase.upcoming,
    ]);
    expect(room.visibleBookingsAt(DateTime(2026, 10, 2)).map((b) => b.id), [4]);
  });

  test('start, end, midnight, and overnight boundaries', () {
    final booking = entry(1, '2026-10-01 10:00:00', '2026-10-01 11:00:00');
    expect(booking.roomSchedulePhaseAt(DateTime(2026, 10, 1, 9, 59, 59)),
        RoomSchedulePhase.upcoming);
    expect(booking.roomSchedulePhaseAt(now), RoomSchedulePhase.ongoing);
    expect(booking.roomSchedulePhaseAt(DateTime(2026, 10, 1, 11)),
        RoomSchedulePhase.finished);
    expect(booking.roomSchedulePhaseAt(DateTime(2026, 10, 1, 23, 59, 59)),
        RoomSchedulePhase.finished);
    expect(booking.roomSchedulePhaseAt(DateTime(2026, 10, 2)), isNull);
    final overnight = entry(2, '2026-10-01 23:00:00', '2026-10-02 01:00:00');
    expect(overnight.roomSchedulePhaseAt(DateTime(2026, 10, 2)),
        RoomSchedulePhase.ongoing);
    expect(overnight.roomSchedulePhaseAt(DateTime(2026, 10, 2, 1)),
        RoomSchedulePhase.finished);
    final midnight = entry(3, '2026-10-01 23:00:00', '2026-10-02 00:00:00');
    expect(midnight.roomSchedulePhaseAt(DateTime(2026, 10, 2)), isNull);
  });

  test('DONE ends early and disappears at midnight of completion', () {
    final booking =
        entry(1, '2026-10-01 09:00:00', '2026-10-02 11:00:00', status: 'DONE')
          ..completedAt = DateTime(2026, 10, 1, 9, 30);
    expect(booking.roomSchedulePhaseAt(now), RoomSchedulePhase.finished);
    expect(booking.roomSchedulePhaseAt(DateTime(2026, 10, 2)), isNull);
    expect(booking.isScheduledAt(now), isFalse);
  });

  test('participants and dates are read from API fields', () {
    final booking = BookingModel.fromJson({
      'booking_id': '12',
      'status': 'APPROVED',
      'start_date': '2026-10-01 10:00:00',
      'end_date': '2026-10-01 11:00:00',
      'participant_internal': '12',
      'participant_external': 8,
    });
    expect(booking.id, 12);
    expect(booking.totalParticipants, 20);
    expect(booking.roomSchedulePhaseAt(now), RoomSchedulePhase.ongoing);
    expect(BookingModel.fromJson({'participant': '20'}).totalParticipants, 20);
  });

  for (final nested in [false, true]) {
    test('detail API reads ${nested ? 'nested' : 'direct'} room data by ID',
        () async {
      final service =
          ScheduleDetailsService(client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/rooms/schedules/7');
        expect(request.headers['authorization'], 'Bearer token');
        final room = {
          'id': 7,
          'name': 'Wilis',
          'bookings': [
            {
              'status': 'APPROVED',
              'start_date': '2026-10-01 10:00:00',
              'end_date': '2026-10-01 11:00:00'
            }
          ]
        };
        return http.Response(
            jsonEncode({
              'data': nested ? {'data': room} : room
            }),
            200);
      }));
      final room = await service.schedule(7, 'Bearer token');
      expect(room.id, 7);
      expect(room.visibleBookingsAt(now), hasLength(1));
    });
  }

  test('selects matching room instead of first search result', () async {
    final service = ScheduleDetailsService(
        client: MockClient((_) async => http.Response(
            jsonEncode({
              'data': {
                'data': [
                  {'id': 2, 'name': 'Other', 'bookings': []},
                  {'id': 7, 'name': 'Wilis', 'bookings': []},
                ]
              }
            }),
            200)));
    expect((await service.schedule(7, 'token')).name, 'Wilis');
  });

  test('malformed detail is an error rather than an empty schedule', () async {
    final service = ScheduleDetailsService(
        client: MockClient((_) async => http.Response('{"data":{}}', 200)));
    await expectLater(service.schedule(7, 'token'), throwsFormatException);
  });
}
