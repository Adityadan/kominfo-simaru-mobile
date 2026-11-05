import 'package:flutter/material.dart';
import 'package:simaru/themes.dart';

import '../models/jadwal ruangan/search/search_model.dart';

class JadwalRuangCard extends StatelessWidget {
  final SearchModel jadwalruang;
  const JadwalRuangCard(this.jadwalruang, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
        left: 5,
        right: 5,
      ),
      padding: const EdgeInsets.only(top: 10, left: 12, bottom: 14, right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), 
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              jadwalruang.image ?? '', 
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(width: 120, height: 120, color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama Ruang:',
                  style: primaryTextStyle3.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  jadwalruang.name ?? '',
                  style: primaryTextStyle3.copyWith(
                    fontSize: 14,
                    fontWeight: semibold,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  'Lokasi: ',
                  style: primaryTextStyle3.copyWith(
                    fontWeight: medium,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  jadwalruang.floor?.toString() ?? '-',
                  style: primaryTextStyle3.copyWith(
                    fontWeight: semibold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  'Kapasitas: ',
                  style: primaryTextStyle3.copyWith(
                    fontWeight: medium,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  jadwalruang.capacity?.toString() ?? '-',
                  style: primaryTextStyle3.copyWith(
                    fontWeight: semibold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
