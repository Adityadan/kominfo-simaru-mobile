import 'booking_model.dart';
import 'schedule_model.dart';

const bookingTurnaround = Duration(minutes: 15);

class BookingFreeWindow {
  const BookingFreeWindow(this.start, this.end);

  final DateTime start;
  final DateTime end;
  Duration get duration => end.difference(start);
}

class BookingBlockedPeriod {
  const BookingBlockedPeriod(this.start, this.end);

  final DateTime start;
  final DateTime end;

  DateTime get blockedThrough => end.add(bookingTurnaround);

  DateTime get nextAvailableStart {
    final boundary = blockedThrough;
    return DateTime(boundary.year, boundary.month, boundary.day, boundary.hour,
            boundary.minute)
        .add(const Duration(minutes: 1));
  }
}

class BookingAvailability {
  BookingAvailability(this.periods);

  final List<BookingBlockedPeriod> periods;

  factory BookingAvailability.fromSchedule(ScheduleModel schedule, int roomId) {
    if (schedule.id != roomId) {
      throw const FormatException('Jadwal tidak sesuai dengan ruangan.');
    }
    final periods = <BookingBlockedPeriod>[];
    for (final booking in schedule.bookings ?? <BookingModel>[]) {
      if (booking.deletedAt != null) continue;
      if (booking.idRoom != null && booking.idRoom != '$roomId') continue;
      final status = booking.status?.trim().toUpperCase();
      if (status == 'REJECTED' ||
          status == 'CANCELLED' ||
          status == 'CANCELED') {
        continue;
      }
      // PENDING ikut memblokir agar permintaan yang menunggu tidak bertumpuk.
      // Status yang belum dikenal juga dianggap terisi, bukan bebas.
      final start = booking.startsAt;
      final end = booking.endsAt;
      if (start == null || end == null || !end.isAfter(start)) {
        throw const FormatException('Waktu pada jadwal ruangan tidak valid.');
      }
      periods.add(BookingBlockedPeriod(start, end));
    }
    periods.sort((a, b) => a.start.compareTo(b.start));
    return BookingAvailability(List.unmodifiable(periods));
  }

  bool allowsRange(DateTime start, DateTime end) {
    if (!end.isAfter(start)) return false;
    return !periods.any((period) =>
        start.isBefore(period.nextAvailableStart) &&
        !end.add(bookingTurnaround).isBefore(period.start));
  }

  bool allowsStart(DateTime start) =>
      allowsRange(start, start.add(const Duration(minutes: 1)));

  DateTime nextAvailableStart(DateTime requested) {
    var candidate = _ceilMinute(requested);
    final sorted = periods.toList()..sort((a, b) => a.start.compareTo(b.start));
    for (final period in sorted) {
      if (candidate.isBefore(period.nextAvailableStart) &&
          !candidate
              .add(const Duration(minutes: 1))
              .add(bookingTurnaround)
              .isBefore(period.start)) {
        candidate = period.nextAvailableStart;
      }
    }
    return candidate;
  }

  /// An end cannot jump past another reservation: clamp to the end of the
  /// available interval when no later end is possible for this selected start.
  DateTime? availableEnd(DateTime start, DateTime requested) {
    final earliest = _ceilMinute(start.add(const Duration(minutes: 1)));
    if (!allowsRange(start, earliest)) return null;
    var candidate = _ceilMinute(requested);
    if (candidate.isBefore(earliest)) candidate = earliest;
    DateTime? latest;
    for (final period in periods) {
      if (period.start.isAfter(start)) {
        final boundary = period.start.subtract(bookingTurnaround);
        final limit = DateTime(boundary.year, boundary.month, boundary.day,
                boundary.hour, boundary.minute)
            .subtract(const Duration(minutes: 1));
        if (latest == null || limit.isBefore(latest)) latest = limit;
      }
    }
    if (latest != null && candidate.isAfter(latest)) candidate = latest;
    return allowsRange(start, candidate) ? candidate : null;
  }

  static DateTime _ceilMinute(DateTime time) {
    final minute =
        DateTime(time.year, time.month, time.day, time.hour, time.minute);
    return time.isAfter(minute)
        ? minute.add(const Duration(minutes: 1))
        : minute;
  }

  /// Contiguous, actually bookable intervals within meeting hours (07–16).
  /// Gaps include the same minute boundaries and turnaround as the picker.
  List<BookingFreeWindow> meetingWindows(DateTime day, {DateTime? notBefore}) {
    var cursor = DateTime(day.year, day.month, day.day, 7);
    final close = DateTime(day.year, day.month, day.day, 16);
    if (notBefore != null && notBefore.isAfter(cursor)) {
      cursor = _ceilMinute(notBefore);
    }
    if (!cursor.isBefore(close)) return [];
    final windows = <BookingFreeWindow>[];
    final sorted = periods.toList()..sort((a, b) => a.start.compareTo(b.start));
    for (final period in sorted) {
      if (!period.nextAvailableStart.isAfter(cursor)) continue;
      final boundary = period.start.subtract(bookingTurnaround);
      var end = DateTime(boundary.year, boundary.month, boundary.day,
              boundary.hour, boundary.minute)
          .subtract(const Duration(minutes: 1));
      if (end.isAfter(close)) end = close;
      if (end.isAfter(cursor)) windows.add(BookingFreeWindow(cursor, end));
      if (period.nextAvailableStart.isAfter(cursor)) {
        cursor = period.nextAvailableStart;
      }
      if (!cursor.isBefore(close)) return windows;
    }
    if (cursor.isBefore(close)) windows.add(BookingFreeWindow(cursor, close));
    return windows;
  }

  bool needsRoomRecommendations(DateTime day, {DateTime? notBefore}) =>
      !meetingWindows(day, notBefore: notBefore)
          .any((window) => window.duration > const Duration(hours: 1));

  List<BookingBlockedPeriod> periodsOn(DateTime day) {
    final midnight = DateTime(day.year, day.month, day.day);
    final tomorrow = DateTime(day.year, day.month, day.day + 1);
    return periods
        .where((period) =>
            period.start.isBefore(tomorrow) &&
            period.nextAvailableStart.isAfter(midnight))
        .toList();
  }
}
