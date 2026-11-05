import 'package:flutter/material.dart';
import 'package:simaru/models/pemesanan%20ruangan/ruangan_model.dart';
import 'package:simaru/pages/jadwal%20ruang/room_schedule_page.dart';
import '../themes.dart';
import 'simaru_ui.dart';

class UnvailableRoomCard extends StatelessWidget {
  final RuanganModel ruangan;
  const UnvailableRoomCard(this.ruangan, {super.key});

  @override
  Widget build(BuildContext context) {
    return SimaruCard(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: ruangan.id == null
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => RoomSchedulePage(
                        roomId: ruangan.id!,
                        roomName: ruangan.name ?? 'Ruangan'))),
        borderRadius: BorderRadius.circular(simaruRadius),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                ruangan.image ?? '',
                width: 112,
                height: 112,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    width: 112,
                    height: 112,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ruangan.name ?? '',
                      style: simaruTitle(size: 19),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  _line(Icons.calendar_today_rounded, 'Lihat jadwal ruangan'),
                  _line(Icons.access_time_rounded, 'Jadwal berdasarkan waktu'),
                  _line(Icons.person_outline_rounded,
                      '${ruangan.capacity?.toString() ?? '-'} Kapasitas'),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: bgColor1.withValues(alpha: .6), size: 30),
          ],
        ),
      ),
    );
  }

  Widget _line(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, color: bgColor1, size: 16),
          const SizedBox(width: 9),
          Expanded(
              child: Text(text,
                  style: simaruBody(color: greyColor, size: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
