import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/riwayat_provider.dart';
import 'package:simaru/widget/api_error_state.dart';
import '../../themes.dart';
import '../../widget/riwayat_card.dart';
import '../../widget/simaru_ui.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  @override
  void initState() {
    super.initState();
    getInit();
  }

  getInit() async {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    await Provider.of<RiwayatProvider>(context, listen: false)
        .notifacation(authProvider.user?.token);
  }

  Future<void> _refreshData() async {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    await Provider.of<RiwayatProvider>(context, listen: false)
        .notifacation(authProvider.user?.token);
  }

  Widget content() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Consumer<RiwayatProvider>(
        builder: (context, riwayatProvider, _) {
          if (riwayatProvider.isLoading ||
              !riwayatProvider.hasLoaded && riwayatProvider.error == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (riwayatProvider.error != null) {
            return ApiErrorState(onRetry: _refreshData);
          }
          if (riwayatProvider.notif.isEmpty) {
            return const Center(child: Text('Belum ada riwayat pemesanan'));
          }
          return LayoutBuilder(builder: (context, constraints) {
            const gap = 16.0;
            const minCardWidth = 360.0;
            final availableWidth = constraints.maxWidth - 32;
            final columns = ((availableWidth + gap) / (minCardWidth + gap))
                .floor()
                .clamp(1, 1000);
            final bookings = riwayatProvider.notif;
            // Build rows lazily; let each row grow with its cards' content.
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: (bookings.length / columns).ceil(),
              itemBuilder: (context, row) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var column = 0; column < columns; column++) ...[
                    if (column > 0) const SizedBox(width: gap),
                    Expanded(
                      child: row * columns + column < bookings.length
                          ? RiwayatCard(bookings[row * columns + column])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          const SimaruGradientHeader(
            title: 'Riwayat Pemesanan',
            height: 112,
            padding: EdgeInsets.fromLTRB(24, 52, 24, 20),
          ),
          Expanded(child: content()),
        ],
      ),
    );
  }
}
