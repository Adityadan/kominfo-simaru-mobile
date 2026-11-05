import 'package:simaru/provider/search_room_provider.dart';
import 'package:simaru/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simaru/widget/jadwalruang_card.dart';

class ListJadwalRuang extends StatefulWidget {
  const ListJadwalRuang({super.key});

  @override
  State<ListJadwalRuang> createState() => _ListJadwalRuangState();
}

class _ListJadwalRuangState extends State<ListJadwalRuang> {
  @override
  Widget build(BuildContext context) {
    SearchProvider searchProvider =
        Provider.of<SearchProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: bgColor1,
        centerTitle: true,
        title: const Text('Jadwal Ruang'),
        elevation: 0,
      ),
      body: searchProvider.search.isEmpty
          ? const Center(child: Text('Tidak ada jadwal'))
          : ListView(
              scrollDirection: Axis.vertical,
              children: searchProvider.search
                  .map(
                    (search) => JadwalRuangCard(search),
                  )
                  .toList(),
            ),
    );
  }
}
