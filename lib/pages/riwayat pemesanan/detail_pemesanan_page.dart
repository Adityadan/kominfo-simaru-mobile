import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/config.dart';
import '../../models/riwayat ruangan/riwayat_model.dart';
import '../../provider/riwayat_provider.dart';
import '../../themes.dart';
import '../../widget/simaru_ui.dart';
import '../keluhan ruang/feedback_page.dart';
import 'update_page.dart';

class DetailPemesananPage extends StatelessWidget {
  final RiwayatModel riwayat;
  const DetailPemesananPage({super.key, required this.riwayat});

  String _value(String? value) =>
      value == null || value.trim().isEmpty ? '-' : value;

  String _date(String? raw) {
    final date = DateTime.tryParse(raw ?? '');
    if (date == null) return _value(raw);
    const months = [
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
      'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} pukul ${DateFormat('HH.mm').format(date)}';
  }

  Future<void> _openAttachment(BuildContext context, String attachment) async {
    try {
      final uri = Uri.parse(baseUrl).resolve(attachment);
      if ((uri.scheme != 'https' && uri.scheme != 'http') ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Lampiran tidak dapat dibuka');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Lampiran tidak dapat dibuka. Silakan coba lagi.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Match by booking ID so another booking can never replace this detail.
    final bookings = context.watch<RiwayatProvider>().notif;
    final booking = bookings
            .where((item) =>
                riwayat.idBooking != null &&
                item.idBooking == riwayat.idBooking)
            .firstOrNull ??
        riwayat;
    final fields = <(String, String, IconData)>[
      ('Nama Pemesan', _value(booking.name), Icons.person_outline),
      ('Ruangan', _value(booking.room?.name), Icons.meeting_room_outlined),
      ('NIP Pemesan', _value(booking.nip), Icons.badge_outlined),
      ('No. Telepon', _value(booking.phone), Icons.phone_outlined),
      (
        'Divisi',
        booking.divisionName ??
            (booking.devisi == null ? '-' : 'ID Divisi: ${booking.devisi}'),
        Icons.business_outlined
      ),
      ('Tanggal Pemesanan', _date(booking.bookingDate), Icons.event_outlined),
      (
        'Tanggal Mulai',
        _date(booking.bookingStartDate),
        Icons.calendar_month_outlined
      ),
      (
        'Tanggal Selesai',
        _date(booking.bookingEndDate),
        Icons.calendar_month_outlined
      ),
      ('Tipe Peserta', _value(booking.participantType), Icons.groups_outlined),
      (
        'Jumlah Peserta',
        'Internal: ${booking.participantInternal ?? 0}, Eksternal: ${booking.participantExternal ?? 0}',
        Icons.people_outline
      ),
    ];
    return Scaffold(
      backgroundColor: bgColor1,
      body: Column(children: [
        SimaruGradientHeader(
          title: 'Detail Pemesanan',
          showBack: true,
          titleSize: 20,
          height: MediaQuery.paddingOf(context).top +
              90 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0),
          padding: EdgeInsets.fromLTRB(
              24, MediaQuery.paddingOf(context).top + 16, 24, 16),
        ),
        Expanded(
            child: SimaruBottomCurve(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: ListView(padding: EdgeInsets.zero, children: [
            Center(
                child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                  color: booking.status == 'PENDING'
                      ? const Color(0xffE5820B)
                      : booking.status == 'APPROVED' || booking.status == 'DONE'
                          ? const Color(0xff188039)
                          : const Color(0xffD32F2F),
                  borderRadius: BorderRadius.circular(24)),
              child: Text(
                  booking.status == 'PENDING'
                      ? 'Menunggu Persetujuan'
                      : booking.statusLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            )),
            const SizedBox(height: 26),
            Text('Informasi Pemesanan', style: simaruTitle(size: 17)),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth >= 300 &&
                      MediaQuery.textScalerOf(context).scale(1) <= 1.3
                  ? 2
                  : 1;
              return Wrap(spacing: 12, runSpacing: 12, children: [
                for (final field in fields)
                  SizedBox(
                      width:
                          (constraints.maxWidth - (columns - 1) * 12) / columns,
                      child: _field(field.$1, field.$2, field.$3)),
              ]);
            }),
            const SizedBox(height: 12),
            _field('Deskripsi', _value(booking.description),
                Icons.description_outlined),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0xffF0F4F8),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lampiran',
                        style: simaruBody(size: 12, color: mutedTextColor)),
                    const SizedBox(height: 8),
                    if (booking.attachment?.trim().isNotEmpty == true)
                      OutlinedButton.icon(
                        onPressed: () =>
                            _openAttachment(context, booking.attachment!),
                        icon: const Icon(Icons.open_in_new, size: 17),
                        label: const Text('Lihat Lampiran'),
                      )
                    else
                      Text('Belum ada lampiran', style: simaruBody(size: 13)),
                  ]),
            ),
            if (booking.canUpdateAttachment || booking.canReview) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              if (booking.canUpdateAttachment)
                _action(
                    'Update Attachment',
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                FormUpdateRuanganPage(id: booking.idBooking)))),
              if (booking.canReview)
                _action(
                    'Beri Ulasan',
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => FeedbackPage(
                                bookingId: booking.idBooking.toString())))),
            ],
          ]),
        )),
      ]),
    );
  }

  Widget _field(String label, String value, IconData icon) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xffF0F4F8),
            borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, size: 15, color: bgColor1),
            const SizedBox(width: 5),
            Expanded(
                child: Text(label,
                    style: simaruBody(size: 11, color: mutedTextColor))),
          ]),
          const SizedBox(height: 7),
          Text(value, style: simaruBody(size: 13, weight: FontWeight.w600)),
        ]),
      );

  Widget _action(String label, VoidCallback callback) => ElevatedButton(
        onPressed: callback,
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffE5820B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: Text(label),
      );
}
