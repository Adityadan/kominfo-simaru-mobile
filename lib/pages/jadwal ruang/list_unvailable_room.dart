import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simaru/models/jadwal ruangan/search/booking_search_model.dart';
import 'package:simaru/models/jadwal ruangan/search/search_model.dart';
import 'package:simaru/models/pemesanan ruangan/ruangan_model.dart';
import 'package:simaru/provider/search_unvailable_provider.dart';
import 'package:simaru/themes.dart';

import '../../widget/listunvailableroom_card.dart';
import '../../widget/simaru_ui.dart';

class ListUnvailableRoomPage extends StatefulWidget {
  final RuanganModel? ruangan;
  const ListUnvailableRoomPage({super.key, this.ruangan});

  @override
  State<ListUnvailableRoomPage> createState() => _ListUnvailableRoomPageState();
}

class _ListUnvailableRoomPageState extends State<ListUnvailableRoomPage> {
  int _currentPage = 0;
  static const int _itemsPerPage = 3;

  @override
  Widget build(BuildContext context) {
    final searchList =
        Provider.of<SearchUnvailableProvider>(context).searchunvailable;

    if (searchList.isEmpty) {
      return Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            _header(),
            const Expanded(
                child: Center(child: Text('Belum ada jadwal ruangan'))),
          ],
        ),
      );
    }

    final SearchModel search = searchList.first;

    final now = DateTime.now();
    final List<BookingSearchModel> bookingApproved =
        (search.booking ?? []).where((b) {
      final start = b.bookingStartDate != null
          ? DateTime.tryParse(b.bookingStartDate!)
          : null;
      final end = b.bookingEndDate != null
          ? DateTime.tryParse(b.bookingEndDate!)
          : null;

      return b.status == 'APPROVED' &&
          start != null &&
          end != null &&
          end.isAfter(now);
    }).toList();

    final int totalPages = (bookingApproved.length / _itemsPerPage).ceil();

    _currentPage = min(_currentPage, max(0, totalPages - 1));

    final int start = _currentPage * _itemsPerPage;
    final int end = min(start + _itemsPerPage, bookingApproved.length);
    final List<BookingSearchModel> pageBookings =
        bookingApproved.isNotEmpty ? bookingApproved.sublist(start, end) : [];

    final pageSearch = SearchModel(
      image: search.image,
      booking: pageBookings,
    );

    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListUnavailableRoomCard(pageSearch),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: totalPages > 1
          ? Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentPage > 0
                        ? () => setState(() {
                              _currentPage--;
                            })
                        : null,
                  ),
                  Text('Page ${_currentPage + 1} of $totalPages'),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _currentPage < totalPages - 1
                        ? () => setState(() {
                              _currentPage++;
                            })
                        : null,
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _header() {
    return SimaruGradientHeader(
      title: widget.ruangan?.name ?? 'Jadwal Ruangan',
      height: 112,
      showBack: true,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
    );
  }
}
