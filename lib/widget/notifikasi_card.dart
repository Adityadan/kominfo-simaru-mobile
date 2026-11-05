import 'package:simaru/models/riwayat%20ruangan/riwayat_model.dart';
import 'package:simaru/themes.dart';
import 'package:flutter/material.dart';

class NotifCard extends StatelessWidget {
  final RiwayatModel notification;
  const NotifCard(this.notification, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/meeting-room1.jpg',
                    width: 80,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pemesanan Ruang Rapat',
                        style: secondaryTextStyle.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.room?.name ?? '',
                        style: primaryTextStyle3.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Successful',
                        style: succesTextStyle.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  notification.bookingDate?.toString() ?? '',
                  style: subtitleTextStyle.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
