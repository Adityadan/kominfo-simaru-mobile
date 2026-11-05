import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule_model.dart';
import '../../provider/auth_provider.dart';
import '../../services/scheduledetails_service.dart';
import '../../widget/api_error_state.dart';
import '../../widget/room_schedule_card.dart';
import '../../widget/simaru_ui.dart';

class RoomSchedulePage extends StatefulWidget {
  const RoomSchedulePage({
    super.key,
    required this.roomId,
    required this.roomName,
    this.service,
    this.now,
  });

  final int roomId;
  final String roomName;
  final ScheduleDetailsService? service;
  final DateTime Function()? now;

  @override
  State<RoomSchedulePage> createState() => _RoomSchedulePageState();
}

class _RoomSchedulePageState extends State<RoomSchedulePage>
    with WidgetsBindingObserver {
  late final ScheduleDetailsService _service;
  ScheduleModel? _room;
  bool _loading = true;
  bool _error = false;
  bool _fetching = false;
  bool _foreground = true;
  Timer? _boundaryTimer;
  Timer? _refreshTimer;

  DateTime get _now => (widget.now?.call() ?? DateTime.now()).toLocal();

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ScheduleDetailsService();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
      _startRefreshTimer();
    });
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    if (!_foreground) return;
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) => _load());
  }

  // Update at the actual start, end, and midnight boundaries even without a
  // network response. Expired cards are hidden locally; API records stay intact.
  void _armBoundaryTimer() {
    _boundaryTimer?.cancel();
    if (!_foreground) return;
    final now = _now;
    var next = DateTime(now.year, now.month, now.day + 1);
    for (final booking in _room?.bookings ?? []) {
      for (final boundary in [booking.startsAt, booking.endsAt]) {
        if (boundary != null &&
            boundary.isAfter(now) &&
            boundary.isBefore(next)) {
          next = boundary;
        }
      }
    }
    _boundaryTimer = Timer(next.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _armBoundaryTimer();
    });
  }

  Future<void> _load() async {
    if (_fetching || !mounted) return;
    _fetching = true;
    setState(() {
      _loading = _room == null;
      _error = false;
    });
    try {
      final token = context.read<AuthProvider>().user?.token;
      final room = await _service.schedule(widget.roomId, token);
      if (mounted) setState(() => _room = room);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      _fetching = false;
      if (mounted) {
        setState(() => _loading = false);
        _armBoundaryTimer();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      _armBoundaryTimer();
      _startRefreshTimer();
      _load();
    } else {
      _boundaryTimer?.cancel();
      _refreshTimer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _boundaryTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = _now;
    final entries = _room?.visibleBookingsAt(now) ?? [];
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: Column(children: [
        SimaruGradientHeader(
          title: widget.roomName,
          subtitle: 'Jadwal Ruangan',
          showBack: true,
          titleSize: 22,
          subtitleSize: 12,
          height: MediaQuery.paddingOf(context).top +
              100 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0),
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.paddingOf(context).top + 18, 20, 16),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (_error && _room == null)
                        ApiErrorState(onRetry: _load)
                      else ...[
                        if (_error)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TextButton.icon(
                              onPressed: _load,
                              icon: const Icon(Icons.refresh),
                              label: const Text(
                                  'Pembaruan gagal. Ketuk untuk mencoba lagi.'),
                            ),
                          ),
                        if (entries.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: Text('Belum ada jadwal ruangan',
                                textAlign: TextAlign.center),
                          ),
                        for (final booking in entries)
                          RoomScheduleCard(
                              booking: booking,
                              phase: booking.roomSchedulePhaseAt(now)!),
                      ],
                    ],
                  ),
                ),
        ),
      ]),
    );
  }
}
