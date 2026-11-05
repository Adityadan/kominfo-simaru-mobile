import 'package:flutter_test/flutter_test.dart';
import 'package:simaru/models/booking_model.dart';
import 'package:simaru/models/schedule_model.dart';

void main() {
  final now = DateTime(2026, 10, 1, 10);

  BookingModel booking(String status, String start, String end) =>
      BookingModel.fromJson({
        'status': status,
        'booking_start_date': start,
        'booking_end_date': end,
      });

  test('empty room schedule has no bookings to display', () {
    final room =
        ScheduleModel.fromJson({'id': 1, 'name': 'Ruang A', 'bookings': []});
    expect(room.bookings, isEmpty);
  });

  test('only approved bookings within their time window appear in schedule',
      () {
    final active =
        booking('APPROVED', '2026-10-01 09:00:00', '2026-10-01 11:00:00');
    final future =
        booking('APPROVED', '2026-10-01 11:00:00', '2026-10-01 12:00:00');
    final past =
        booking('APPROVED', '2026-10-01 08:00:00', '2026-10-01 09:00:00');
    final finishedEarly =
        booking('DONE', '2026-10-01 09:00:00', '2026-10-01 11:00:00');
    final pending =
        booking('PENDING', '2026-10-01 09:00:00', '2026-10-01 11:00:00');

    expect(active.isScheduledAt(now), isTrue);
    expect(active.isActiveAt(now), isTrue);
    expect(future.isScheduledAt(now), isTrue);
    expect(future.isActiveAt(now), isFalse);
    expect(past.isScheduledAt(now), isFalse);
    expect(past.isActiveAt(now), isFalse);
    expect(finishedEarly.isScheduledAt(now), isFalse);
    expect(finishedEarly.isActiveAt(now), isFalse);
    expect(pending.isScheduledAt(now), isFalse);
    expect(pending.isActiveAt(now), isFalse);
  });

  test('booking ending at current time is no longer active', () {
    final ended =
        booking('APPROVED', '2026-10-01 09:00:00', '2026-10-01 10:00:00');
    expect(ended.isActiveAt(now), isFalse);
  });
}
