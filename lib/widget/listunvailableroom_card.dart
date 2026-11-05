import 'package:flutter/material.dart';
import 'package:simaru/models/jadwal ruangan/search/search_model.dart';
import 'package:simaru/models/devision_model.dart';
import 'package:provider/provider.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/themes.dart';

import '../services/devision_service.dart';

class ListUnavailableRoomCard extends StatelessWidget {
  final SearchModel search;
  const ListUnavailableRoomCard(this.search, {super.key});

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: false).user?.token;

    final bookings = search.booking ?? [];

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            search.image ?? '',
            width: 200,
            height: 221,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
                width: 200,
                height: 221,
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image)),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: bookings.map((booking) {
                final startDt = booking.bookingStartDate != null
                    ? DateTime.tryParse(booking.bookingStartDate!)
                    : null;
                final endDt = booking.bookingEndDate != null
                    ? DateTime.tryParse(booking.bookingEndDate!)
                    : null;
                final now = DateTime.now();

                if (booking.status != 'APPROVED' ||
                    startDt == null ||
                    endDt == null ||
                    !endDt.isAfter(now)) {
                  return const SizedBox.shrink();
                }
                return Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pemesanan Ruang Rapat',
                            style: primaryTextStyle3.copyWith(
                              fontSize: 12,
                              fontWeight: semibold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('Nama:',
                              style: primaryTextStyle3.copyWith(
                                  fontSize: 12, fontWeight: semibold)),
                          const SizedBox(height: 3),
                          Text(booking.name ?? '',
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 5),
                          Text('Penggunaan Ruangan:',
                              style: primaryTextStyle3.copyWith(
                                  fontSize: 12, fontWeight: semibold)),
                          Text(
                              '${booking.bookingStartDate ?? ''} – ${booking.bookingEndDate ?? ''}',
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 6),
                          Text('Devisi:',
                              style: primaryTextStyle3.copyWith(
                                  fontSize: 12, fontWeight: semibold)),
                          const SizedBox(height: 3),
                          FutureBuilder<DevisionModel>(
                            future:
                                DivisionDetailsService().fetchDevisionDetail(
                              id: booking.member?.divisionId,
                              token: token,
                            ),
                            builder: (ctx, snap) {
                              if (snap.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading…',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic));
                              }
                              if (snap.hasError || !snap.hasData) {
                                return const Text('-',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.red));
                              }
                              return Text(snap.data?.name ?? '-',
                                  style: const TextStyle(fontSize: 12));
                            },
                          ),
                          const SizedBox(height: 6),
                          Text('Deskripsi:',
                              style: primaryTextStyle3.copyWith(
                                  fontSize: 12, fontWeight: semibold)),
                          const SizedBox(height: 3),
                          Text(booking.description ?? '',
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    Column(
                      children: [
                        Image.asset("assets/booked.png", width: 60, height: 60),
                        const SizedBox(height: 4),
                        const Text('Tanggal Pemesanan:',
                            style: TextStyle(fontSize: 10)),
                        Text(booking.bookingDate ?? '',
                            style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
