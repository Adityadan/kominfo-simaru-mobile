import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/booking_availability.dart';
import '../models/pemesanan ruangan/ruangan_model.dart';
import '../services/room_recommendation_service.dart';

class RoomRecommendationsDialog extends StatefulWidget {
  const RoomRecommendationsDialog(
      {super.key,
      required this.service,
      required this.day,
      required this.currentRoomId,
      required this.token,
      required this.now,
      required this.automatic,
      this.occupiedPeriods = const []});
  final RoomRecommendationService service;
  final DateTime day;
  final int currentRoomId;
  final String? token;
  final DateTime now;
  final bool automatic;
  final List<BookingBlockedPeriod> occupiedPeriods;

  @override
  State<RoomRecommendationsDialog> createState() =>
      _RoomRecommendationsDialogState();
}

class _RoomRecommendationsDialogState extends State<RoomRecommendationsDialog> {
  RoomRecommendationResult? _result;
  bool _loading = true;
  bool _failed = false;
  final ScrollController _roomsController = ScrollController();

  @override
  void dispose() {
    _roomsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final result = await widget.service.recommend(
        day: widget.day,
        excludeRoomId: widget.currentRoomId,
        token: widget.token,
        now: widget.now,
        minimumDuration: minimumRoomRecommendationDuration,
      );
      if (mounted) {
        setState(() {
          _result = result;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  String _duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return [if (hours > 0) '$hours jam', if (minutes > 0) '$minutes menit']
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SizedBox(
            width: double.infinity,
            height: (470 * textScale.clamp(1, 1.5))
                .clamp(0, MediaQuery.sizeOf(context).height * .86)
                .toDouble(),
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                children: [
                  ConstrainedBox(
                    constraints:
                        BoxConstraints(maxHeight: constraints.maxHeight * .35),
                    child: SingleChildScrollView(child: _header()),
                  ),
                  Expanded(child: _body()),
                  ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight * .25),
                      child: SingleChildScrollView(
                          child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            key: const ValueKey('stay-in-current-room'),
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD54F),
                              foregroundColor: const Color(0xFF152746),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Tetap di ruangan ini',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final midnight =
        DateTime(widget.day.year, widget.day.month, widget.day.day);
    final tomorrow = midnight.add(const Duration(days: 1));
    final timeFormat = DateFormat('HH.mm');
    final occupiedTimes = widget.occupiedPeriods
        .where((period) =>
            period.start.isBefore(tomorrow) && period.end.isAfter(midnight))
        .map((period) {
          final start =
              period.start.isBefore(midnight) ? midnight : period.start;
          final end = period.end.isAfter(tomorrow) ? tomorrow : period.end;
          return '${timeFormat.format(start)}-${end == tomorrow ? '24.00' : timeFormat.format(end)}';
        })
        .toSet()
        .join(', ');
    return Container(
      width: double.infinity,
      color: const Color(0xFFD5E4F8),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('INFORMASI RUANGAN !',
              style: TextStyle(
                  color: Color(0xFF12345B),
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
                children: occupiedTimes.isNotEmpty
                    ? [
                        const TextSpan(text: 'Pada Jam '),
                        TextSpan(
                            text: '$occupiedTimes WIB',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        const TextSpan(
                            text: ' ruangan yang anda pilih sudah dibooking.'),
                      ]
                    : [
                        const TextSpan(
                            text: 'Lihat rekomendasi ruangan untuk '),
                        TextSpan(
                            text: DateFormat('dd/MM/yyyy').format(widget.day),
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        const TextSpan(text: '.'),
                      ]),
            style: const TextStyle(
                color: Color(0xFF12345B), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          const Text('Silahkan pilih ruangan lain!',
              style: TextStyle(
                  color: Color(0xFF12345B),
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _status(Widget child) => SingleChildScrollView(
        key: const ValueKey('room-recommendation-list'),
        padding: const EdgeInsets.all(16),
        child: child,
      );

  Widget _body() {
    if (_loading) {
      return _status(const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Mencari ruangan tersedia...'),
        ]),
      ));
    }
    if (_failed) {
      return _status(Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Rekomendasi gagal dimuat. Silakan coba lagi.'),
        TextButton(onPressed: _load, child: const Text('Coba lagi')),
      ]));
    }
    final result = _result!;
    final cards = [
      ...result.rooms.map((recommendation) => _roomCard(
          recommendation.room, recommendation.windows,
          recommendation: recommendation)),
      ...result.fullyBookedRooms.map((room) => _roomCard(room, const [])),
    ];
    return LayoutBuilder(
        builder: (context, bodyConstraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: bodyConstraints.maxHeight * .3),
                    child: const SingleChildScrollView(
                        child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 10),
                      child: Text('Rekomendasi Ruangan',
                          style: TextStyle(
                              color: Color(0xFF152746),
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ))),
                Expanded(
                  child: cards.isEmpty
                      ? _status(Text(result.uncheckedRooms > 0
                          ? 'Belum ada rekomendasi yang berhasil dikonfirmasi. Coba lagi untuk memeriksa jadwal.'
                          : 'Tidak ada ruangan lain dengan waktu kosong minimal 3 jam pada tanggal ini.'))
                      : LayoutBuilder(builder: (context, constraints) {
                          final cardWidth =
                              (constraints.maxWidth - 44).clamp(0.0, 340.0);
                          return Scrollbar(
                            controller: _roomsController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            interactive: true,
                            scrollbarOrientation: ScrollbarOrientation.bottom,
                            child: SingleChildScrollView(
                              key: const ValueKey('room-recommendation-list'),
                              controller: _roomsController,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var i = 0; i < cards.length; i++) ...[
                                    if (i > 0) const SizedBox(width: 12),
                                    SizedBox(width: cardWidth, child: cards[i]),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                ),
                if (result.uncheckedRooms > 0)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: bodyConstraints.maxHeight * .2),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(children: [
                        Text(
                            '${result.uncheckedRooms} ruangan belum dapat diperiksa. Hanya jadwal yang berhasil diperiksa ditampilkan.'),
                        TextButton(
                            onPressed: _load, child: const Text('Coba lagi')),
                      ]),
                    ),
                  ),
              ],
            ));
  }

  Widget _roomCard(RuanganModel room, List<BookingFreeWindow> windows,
      {RoomRecommendation? recommendation}) {
    final unavailable = recommendation == null;
    return Material(
      key: ValueKey(
          '${unavailable ? 'fully-booked' : 'available'}-room-frame-${room.id}'),
      color: unavailable ? const Color(0xFFFFF4E5) : const Color(0xFFEEF2FF),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: unavailable
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFFDEE4F0))),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey(
            '${unavailable ? 'fully-booked' : 'recommended'}-room-${room.id}'),
        onTap: unavailable
            ? null
            : () => Navigator.of(context).pop(recommendation),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _photo(room.image, room.name, 86, 136),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.name ?? 'Ruangan ${room.id}',
                        style: const TextStyle(
                            color: Color(0xFF152746),
                            fontSize: 15,
                            height: 1.3,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _info(
                        Icons.groups_rounded,
                        room.capacity == null
                            ? 'Kapasitas belum tersedia'
                            : '${room.capacity} Orang'),
                    const SizedBox(height: 8),
                    _info(
                        Icons.location_on_rounded,
                        room.floor == null
                            ? 'Lantai belum tersedia'
                            : 'Lantai ${room.floor}'),
                    const SizedBox(height: 8),
                    if (unavailable)
                      const Text('Tidak ada waktu tersedia\n07.00-16.00',
                          style: TextStyle(
                              color: Color(0xFF9A5700),
                              fontSize: 12,
                              height: 1.4,
                              fontWeight: FontWeight.w600)),
                    for (final window in windows)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _info(Icons.schedule_rounded,
                            'Kosong ${DateFormat('HH.mm').format(window.start)}-${DateFormat('HH.mm').format(window.end)}',
                            bold: true, subtitle: _duration(window.duration)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text,
          {bool bold = false, String? subtitle}) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF12345B)),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text,
                    style: TextStyle(
                        color: const Color(0xFF233653),
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
                if (subtitle != null)
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF233653), fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      );

  Widget _photo(String? url, String? name, double width, double height) {
    final placeholder = Container(
        color: const Color(0xFFDDE8F8),
        child: const Center(
            child: Icon(Icons.meeting_room_outlined,
                size: 38, color: Color(0xFF6D86A8))));
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null || url.trim().isEmpty
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.cover,
                semanticLabel: name == null ? 'Foto ruangan' : 'Foto $name',
                errorBuilder: (_, __, ___) => placeholder,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : placeholder,
              ),
      ),
    );
  }
}
