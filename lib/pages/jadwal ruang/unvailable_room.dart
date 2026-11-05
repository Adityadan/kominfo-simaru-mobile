import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/pesan_ruang_provider.dart';
import 'package:simaru/widget/api_error_state.dart';
import '../../themes.dart';
import '../../widget/unvailableroom_card.dart';
import '../../widget/simaru_ui.dart';

class UnvailbleRoomPage extends StatefulWidget {
  const UnvailbleRoomPage({super.key});

  @override
  State<UnvailbleRoomPage> createState() => _UnvailbleRoomPageState();
}

class _UnvailbleRoomPageState extends State<UnvailbleRoomPage> {
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
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: pesanruangProvider.ruangan.length,
            itemBuilder: (context, index) =>
                UnvailableRoomCard(pesanruangProvider.ruangan[index]),
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
            title: 'Jadwal Ruangan',
            height: 112,
            padding: EdgeInsets.fromLTRB(24, 52, 24, 20),
          ),
          Expanded(
              child: SimaruBottomCurve(
                  padding: EdgeInsets.zero, child: content())),
        ],
      ),
    );
  }
}
