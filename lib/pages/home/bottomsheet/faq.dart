import 'package:simaru/themes.dart';
import 'package:flutter/material.dart';
import '../../../widget/simaru_ui.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final Map<int, bool> _isExpandedMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          const SimaruGradientHeader(
            title: 'FAQ',
            height: 112,
            padding: EdgeInsets.fromLTRB(24, 52, 24, 20),
          ),
          Expanded(
            child: SimaruBottomCurve(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Image.asset('assets/faq.png',
                      height: 190,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.help_rounded,
                          size: 150,
                          color: softBlueColor)),
                  const SizedBox(height: 10),
                  Center(child: Text('FAQ', style: simaruTitle(size: 31))),
                  const SizedBox(height: 8),
                  Center(
                      child: Text(
                          'Temukan jawaban atas pertanyaan\nyang sering diajukan seputar SIMARU.',
                          textAlign: TextAlign.center,
                          style: simaruBody(color: greyColor, size: 15))),
                  const SizedBox(height: 28),
                  for (int i = 0; i < 3; i++) _faqTile(i),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqTile(int index) {
    final expanded = _isExpandedMap[index] ?? false;
    return SimaruCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(simaruRadius)),
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(simaruRadius)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        initiallyExpanded: expanded,
        onExpansionChanged: (value) =>
            setState(() => _isExpandedMap[index] = value),
        title: Text(_getQuestion(index),
            style: simaruBody(color: bgColor1, size: 17, weight: semibold)),
        iconColor: bgColor1,
        collapsedIconColor: bgColor1,
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text(_getAnswer(index),
                  style: simaruBody(color: mutedTextColor, size: 13)))
        ],
      ),
    );
  }

  String _getQuestion(int index) {
    switch (index) {
      case 0:
        return 'Apa itu Simaru?';
      case 1:
        return 'Bagaimana cara melakukan Pemesanan Ruang?';
      case 2:
        return 'Bagaimana cara cancel Pemesanan Ruang?';
      default:
        return 'Pertanyaan ini belum memiliki jawaban.';
    }
  }

  String _getAnswer(int index) {
    switch (index) {
      case 0:
        return 'Simaru adalah aplikasi Manajemen Pemesanan Ruang Rapat Dinas Komunikasi dan Informatika Provinsi Jawa Timur.';
      case 1:
        return '- Masuk ke halaman awal aplikasi\n- Pilih Booking Ruangan\n- Pilih ruangan dan pilih Pesan\n- Isi semua form lalu pilih tombol Pesan';
      case 2:
        return '- Masuk ke halaman awal aplikasi\n- Pilih Riwayat Ruangan\n- Pilih ruangan yang akan dicancel dan batalkan pemesanan\n- Anda akan diarahkan ke WhatsApp admin untuk mengisi deskripsi pembatalan';
      default:
        return 'Pertanyaan ini belum memiliki jawaban.';
    }
  }
}
