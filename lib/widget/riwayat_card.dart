import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/riwayat ruangan/riwayat_model.dart';
import '../pages/riwayat pemesanan/detail_pemesanan_page.dart';
import '../themes.dart';
import 'simaru_ui.dart';

class RiwayatCard extends StatelessWidget {
  final RiwayatModel riwayat;
  const RiwayatCard(this.riwayat, {super.key});

  @override
  Widget build(BuildContext context) {
    return SimaruCard(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(
                color: softBlueColor,
                child: Image.network(riwayat.room?.image ?? '',
                    fit: BoxFit.contain,
                    errorBuilder: (_, error, stackTrace) => Center(
                        child: Icon(Icons.meeting_room_outlined,
                            size: 48, color: bgColor1))),
              ),
            ),
            Positioned(left: 10, bottom: 10, child: _statusBadge()),
          ]),
        ),
        const SizedBox(height: 10),
        Text(riwayat.room?.name ?? 'Ruangan', style: simaruTitle(size: 16)),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (context, constraints) {
          final items = [
            _info(Icons.calendar_month_outlined,
                _dateOnly(riwayat.bookingStartDate)),
            _info(Icons.groups_outlined,
                '${(riwayat.participantInternal ?? 0) + (riwayat.participantExternal ?? 0)} Peserta'),
            _info(Icons.description_outlined, riwayat.description ?? '-'),
          ];
          if (constraints.maxWidth < 320 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.3) {
            return Column(children: items);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: items[i]),
            ],
          ]);
        }),
        const SizedBox(height: 8),
        _actionLayout(context, [
          _actionButton(context, 'DETAIL', Icons.info_outline, true, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DetailPemesananPage(riwayat: riwayat)));
          }),
          if (riwayat.status == 'PENDING' && riwayat.idBooking != null)
            _actionButton(context, 'BATALKAN', Icons.close, false, () async {
              String message =
                  'Hai Admin Dinas Komunikasi dan Infromatika Provinsi Jawa Timur. Mohon Maaf Saya Berencana akan membatalkan Pemesanan Ruang Rapat, dengan deskripsi senagai berikut: \n\n Nama Pemesanan:\n ${riwayat.name ?? ''}\n Ruangan:\n ${riwayat.room?.name ?? ''}\n Tanggal Pemesanan:\n ${riwayat.bookingDate ?? ''}\n Jam Pelaksanaan Rapat:\n ${riwayat.bookingStartDate ?? ''} sampai dengan ${riwayat.bookingEndDate ?? ''}\n Deskripsi Pembatalan:\n..........  \n\n\n\n Noted: Untuk Pembatalan Ruangan Tolong isikan Deskripsi Penyebab Pembatalan Rapat Diatas ini(Hapus ...... dengan deskripsi pembatalan).';
              String whatsApp =
                  'https://wa.me/6281252973315?text=${Uri.encodeComponent(message)}';
              await launchUrl(Uri.parse(whatsApp),
                  mode: LaunchMode.externalApplication);
            }),
        ]),
      ]),
    );
  }

  Widget _info(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, color: bgColor1, size: 17),
          const SizedBox(width: 9),
          Expanded(
              child: Text(text,
                  style: simaruBody(color: const Color(0xff475467), size: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    final status = riwayat.status ?? '-';
    Color fg = bgColor1;
    Color bg = softBlueColor;
    IconData icon = Icons.info_outline_rounded;
    if (status == 'APPROVED' || status == 'DONE') {
      fg = const Color(0xff189B35);
      bg = const Color(0xffE3F8E5);
      icon = Icons.check_circle_outline_rounded;
    }
    if (status == 'PENDING') {
      fg = const Color(0xffE08A00);
      bg = const Color(0xffFFF0DB);
      icon = Icons.access_time_rounded;
    }
    if (status == 'CANCELED' || status == 'CANCELLED' || status == 'REJECTED') {
      fg = const Color(0xffED1C24);
      bg = const Color(0xffFFE8EA);
      icon = Icons.cancel_outlined;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: fg, size: 15),
        const SizedBox(width: 5),
        Text(riwayat.statusLabel,
            style:
                TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700))
      ]),
    );
  }

  Widget _actionLayout(BuildContext context, List<Widget> buttons) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(13) / 13;
        final stackButtons =
            buttons.length > 1 && constraints.maxWidth < 300 * textScale;

        if (stackButtons) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < buttons.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                buttons[i],
              ],
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < buttons.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: buttons[i]),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton(BuildContext context, String label, IconData icon,
      bool outlined, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(label,
          textAlign: TextAlign.center,
          softWrap: true,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w700)),
      style: TextButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          backgroundColor:
              outlined ? const Color(0xffE5820B) : const Color(0xffE52529),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), side: BorderSide.none)),
    );
  }

  String _dateOnly(String? raw) {
    final dt = raw == null ? null : DateTime.tryParse(raw);
    return dt == null ? (raw ?? '-') : DateFormat('d MMM yyyy').format(dt);
  }
}
