import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import 'simaru_ui.dart';

class RoomScheduleCard extends StatelessWidget {
  const RoomScheduleCard(
      {super.key, required this.booking, required this.phase});

  final BookingModel booking;
  final RoomSchedulePhase phase;

  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String _date(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  @override
  Widget build(BuildContext context) {
    final (label, foreground, background) = switch (phase) {
      RoomSchedulePhase.finished => (
          'SELESAI',
          const Color(0xff5D6570),
          const Color(0xffF0F1F3)
        ),
      RoomSchedulePhase.ongoing => (
          'SEDANG BERLANGSUNG',
          const Color(0xff187544),
          const Color(0xffEAF7EE)
        ),
      RoomSchedulePhase.upcoming => (
          'AKAN DATANG',
          const Color(0xff896000),
          const Color(0xffFFF7D6)
        ),
    };
    final start = booking.startsAt!;
    final end = booking.endsAt!;
    final sameDay = start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;
    final time =
        'Pukul ${DateFormat('HH.mm').format(start)} - ${DateFormat('HH.mm').format(end)}';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: foreground.withValues(alpha: .22)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(_date(start),
                  style: simaruBody(size: 13, weight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(label,
                    style: simaruBody(
                        size: 10, color: foreground, weight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
            booking.description?.trim().isNotEmpty == true
                ? booking.description!
                : 'Kegiatan ruangan',
            style: simaruBody(size: 16, weight: FontWeight.w600)),
        const SizedBox(height: 10),
        Text(sameDay ? time : '$time (selesai ${_date(end)})',
            style: simaruBody(size: 13)),
        const SizedBox(height: 4),
        Text(
            booking.totalParticipants == null
                ? 'Jumlah partisipan belum tersedia'
                : 'Jumlah partisipan ${booking.totalParticipants} orang',
            style: simaruBody(size: 13)),
      ]),
    );
  }
}
