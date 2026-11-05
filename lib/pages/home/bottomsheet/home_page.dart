import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simaru/models/booking_model.dart';
import 'package:simaru/models/pemesanan%20ruangan/ruangan_model.dart';
import 'package:simaru/pages/pesan%20ruang%20baru/ruangan_page.dart';
import 'package:simaru/pages/jadwal%20ruang/room_schedule_page.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/pesan_ruang_provider.dart';
import 'package:simaru/provider/schedule_provider.dart';
import 'package:simaru/themes.dart';
import 'package:simaru/widget/api_error_state.dart';
import '../../../widget/simaru_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _carouselStartPage = 1000;
  final PageController _imageController =
      PageController(initialPage: _carouselStartPage);
  final ScrollController _availableRoomsController = ScrollController();
  Timer? _imageTimer;
  Timer? _availabilityTimer;
  bool _refreshing = false;
  int _currentPage = _carouselStartPage;
  int _currentImage = 0;

  final List<String> _homeImages = [
    'assets/home_image.png',
    'assets/meeting-room1.jpg',
    'assets/meeting-room3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRoomData());
    _imageTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_imageController.hasClients) return;
      _imageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
    _availabilityTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        if (mounted) _loadRoomData();
      },
    );
  }

  Future<void> _loadRoomData() async {
    if (_refreshing || !mounted) return;
    _refreshing = true;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await Future.wait([
        Provider.of<PesanRuangProvider>(context, listen: false)
            .bookingroom(null, authProvider.user?.token),
        Provider.of<ScheduleProvider>(context, listen: false)
            .schedules(authProvider.user?.token),
      ]);
    } finally {
      _refreshing = false;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    _availabilityTimer?.cancel();
    _imageController.dispose();
    _availableRoomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final roomProvider = Provider.of<PesanRuangProvider>(context);
    final rooms = roomProvider.ruangan;
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final now = DateTime.now();
    final scheduledBookings = <({RuanganModel room, BookingModel booking})>[];
    if (scheduleProvider.hasLoaded) {
      for (final schedule in scheduleProvider.schedule) {
        if (schedule.id == null) continue;
        for (final booking in schedule.bookings ?? <BookingModel>[]) {
          if (!booking.isScheduledAt(now)) continue;
          scheduledBookings.add((
            room: RuanganModel(id: schedule.id, name: schedule.name),
            booking: booking,
          ));
        }
      }
      scheduledBookings
          .sort((a, b) => a.booking.startsAt!.compareTo(b.booking.startsAt!));
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: RefreshIndicator(
        onRefresh: _loadRoomData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SimaruGradientHeader(
                title: 'Selamat datang, ${user?.name ?? 'Member'}',
                subtitle: '',
                titleSize: 20,
                subtitleSize: 28,
                height: 250,
                showLogo: true,
                padding: const EdgeInsets.fromLTRB(24, 58, 24, 22),
              ),
              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          controller: _imageController,
                          onPageChanged: (index) => setState(() {
                            _currentPage = index;
                            _currentImage = index % _homeImages.length;
                          }),
                          itemBuilder: (context, index) => ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              _homeImages[index % _homeImages.length],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, size: 60),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _homeImages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentImage
                                  ? bgColor1
                                  : softBlueColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (scheduleProvider.isLoading ||
                          !scheduleProvider.hasLoaded &&
                              scheduleProvider.error == null ||
                          scheduleProvider.error != null ||
                          scheduledBookings.isNotEmpty) ...[
                        _buildSectionTitle('Jadwal Ruangan'),
                        const SizedBox(height: 12),
                        SimaruCard(
                          padding: const EdgeInsets.all(14),
                          margin: EdgeInsets.zero,
                          child: scheduleProvider.isLoading ||
                                  !scheduleProvider.hasLoaded &&
                                      scheduleProvider.error == null
                              ? const SizedBox(
                                  height: 100,
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : scheduleProvider.error != null
                                  ? ApiErrorState(
                                      size: 130,
                                      onRetry: _loadRoomData,
                                    )
                                  : Column(
                                      children: scheduledBookings.map((entry) {
                                        final room = entry.room;
                                        final start = entry.booking.startsAt!;
                                        final end = entry.booking.endsAt!;
                                        final time =
                                            '${DateFormat('dd/MM HH:mm').format(start)} - '
                                            '${DateFormat('dd/MM HH:mm').format(end)}';

                                        return Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        RoomSchedulePage(
                                                            roomId: room.id!,
                                                            roomName: room
                                                                    .name ??
                                                                'Ruangan'))),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 10),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: const Color(0xffF5F9FF),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xffDDE8FF),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 44,
                                                    height: 44,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xffE4EEFF),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .calendar_month_rounded,
                                                      color: bgColor1,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          room.name ??
                                                              'Ruangan',
                                                          style: simaruBody(
                                                            color: bgColor1,
                                                            size: 14,
                                                            weight: semibold,
                                                          ),
                                                        ),
                                                        Text(
                                                          time,
                                                          style: simaruBody(
                                                            color:
                                                                mutedTextColor,
                                                            size: 12,
                                                            weight: medium,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xffEAF7EE),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              999),
                                                    ),
                                                    child: Text(
                                                      entry.booking
                                                              .isActiveAt(now)
                                                          ? 'Dipakai'
                                                          : 'Dipesan',
                                                      style: simaruBody(
                                                        color: const Color(
                                                            0xff1F9D5C),
                                                        size: 11,
                                                        weight: semibold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                        ),
                        const SizedBox(height: 26),
                      ],
                      _buildSectionTitle('Informasi Ruangan'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xffE7ECF4)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: roomProvider.isLoading ||
                                !roomProvider.hasLoaded &&
                                    roomProvider.error == null
                            ? const SizedBox(
                                height: 160,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : roomProvider.error != null
                                ? ApiErrorState(
                                    size: 130,
                                    onRetry: _loadRoomData,
                                  )
                                : rooms.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child:
                                            Text('Belum ada informasi ruangan'),
                                      )
                                    : SizedBox(
                                        height:
                                            (MediaQuery.sizeOf(context).height *
                                                    0.32)
                                                .clamp(200.0, 320.0),
                                        child: Scrollbar(
                                          controller: _availableRoomsController,
                                          thumbVisibility: true,
                                          trackVisibility: true,
                                          interactive: true,
                                          thickness: 5,
                                          radius: const Radius.circular(8),
                                          child: ListView.separated(
                                            controller:
                                                _availableRoomsController,
                                            primary: false,
                                            padding: const EdgeInsets.only(
                                                right: 14),
                                            itemCount: rooms.length,
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(height: 10),
                                            itemBuilder: (context, index) =>
                                                _buildAvailableRoomTile(
                                                    rooms[index]),
                                          ),
                                        ),
                                      ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openRoomDetail(RuanganModel room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomPage(roomId: room.id),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: simaruTitle(size: 20),
    );
  }

  Widget _buildAvailableRoomTile(RuanganModel room) {
    final isFeatured = room.name == 'MTIX';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openRoomDetail(room),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color:
                isFeatured ? const Color(0xffEBF3FF) : const Color(0xffF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isFeatured
                  ? const Color(0xffCFE0FF)
                  : const Color(0xffE7ECF4),
            ),
          ),
          child: Text(
            room.name ?? 'Ruangan',
            softWrap: true,
            style: simaruBody(
              color: isFeatured ? bgColor1 : const Color(0xff475467),
              size: 13,
              weight: semibold,
            ),
          ),
        ),
      ),
    );
  }
}
