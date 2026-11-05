import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/pesan_ruang_provider.dart';
import 'package:simaru/widget/api_error_state.dart';
import '../../themes.dart';
import '../../widget/booking_room_card.dart';
import '../../widget/simaru_ui.dart';

class PesanRuangPage extends StatefulWidget {
  const PesanRuangPage({super.key});

  @override
  State<PesanRuangPage> createState() => _PesanRuangPageState();
}

class _PesanRuangPageState extends State<PesanRuangPage> {
  @override
  void initState() {
    super.initState();
    getInit();
  }

  getInit() async {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    await Provider.of<PesanRuangProvider>(context, listen: false)
        .bookingroom(null, authProvider.user?.token);
  }

  Future<void> _refreshData() async {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    await Provider.of<PesanRuangProvider>(context, listen: false)
        .bookingroom(null, authProvider.user?.token);
  }

  Widget content() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Consumer<PesanRuangProvider>(
        builder: (context, pesanruangProvider, _) {
          if (pesanruangProvider.isLoading ||
              !pesanruangProvider.hasLoaded &&
                  pesanruangProvider.error == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (pesanruangProvider.error != null) {
            return ApiErrorState(onRetry: _refreshData);
          }
          if (pesanruangProvider.ruangan.isEmpty) {
            return const Center(child: Text('Belum ada ruangan'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: pesanruangProvider.ruangan.length,
            itemBuilder: (context, index) {
              final reversedIndex =
                  pesanruangProvider.ruangan.length - index - 1;
              return BookingRoomCard(pesanruangProvider.ruangan[reversedIndex]);
            },
          );
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
              title: 'Booking Ruangan',
              height: 112,
              padding: EdgeInsets.fromLTRB(24, 52, 24, 20)),
          Expanded(child: content()),
        ],
      ),
    );
  }
}
