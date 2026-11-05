import 'package:flutter/material.dart';
import 'package:simaru/models/pemesanan%20ruangan/ruangan_model.dart';
import 'package:simaru/pages/pesan%20ruang%20baru/form_pesan_ruang.dart';
import '../pages/pesan ruang baru/ruangan_page.dart';
import '../themes.dart';
import 'simaru_ui.dart';

class BookingRoomCard extends StatelessWidget {
  final RuanganModel ruangan;
  const BookingRoomCard(this.ruangan, {super.key});

  @override
  Widget build(BuildContext context) {
    return SimaruCard(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              ruangan.image ?? '',
              width: 128,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                  width: 128,
                  height: 150,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 30,
                  width: double.infinity,
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      ruangan.name ?? 'Ruangan',
                      maxLines: 1,
                      softWrap: false,
                      style: simaruTitle(size: 20),
                    ),
                  ),
                ),
                _info(Icons.location_on_rounded,
                    ruangan.floor?.toString() ?? 'Lokasi'),
                _info(Icons.groups_rounded,
                    '${ruangan.capacity?.toString() ?? '-'} Kapasitas'),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RoomPage(roomId: ruangan.id))),
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: bgColor1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: bgColor1))),
                          child: Text('Lihat',
                              style: blueTextStyle.copyWith(
                                  fontSize: 16, fontWeight: semibold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FormPesanRuanganPage(
                                      idRoom: ruangan.id))),
                          style: TextButton.styleFrom(
                              backgroundColor: bgColor1,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: Text('Pesan',
                              style: whiteTextStyle.copyWith(
                                  fontSize: 16, fontWeight: semibold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, color: secondaryColor, size: 19),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: simaruBody(color: const Color(0xff454545), size: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
