import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simaru/pages/jadwal%20ruang/room_schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simaru/models/pemesanan%20ruangan/ruangan_model.dart';
import 'package:simaru/pages/pesan%20ruang%20baru/form_pesan_ruang.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/pesan_ruang_provider.dart';
import 'package:simaru/themes.dart';
import 'package:simaru/widget/api_error_state.dart';
import '../../widget/simaru_ui.dart';

class RoomPage extends StatefulWidget {
  final int? roomId;
  const RoomPage({super.key, this.roomId});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  RuanganModel? rooms;
  bool _isLoading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    getRoomsData();
  }

  void getRoomsData() async {
    if (mounted) setState(() => _isLoading = true);
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    PesanRuangProvider pesanRuangProvider =
        Provider.of<PesanRuangProvider>(context, listen: false);
    await pesanRuangProvider.bookingroom(
        widget.roomId, authProvider.user?.token);
    _loadFailed = pesanRuangProvider.error != null;
    try {
      rooms = pesanRuangProvider.ruangan
          .firstWhere((ruangan) => ruangan.id == widget.roomId);
    } catch (_) {
      rooms = null;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      bottomNavigationBar: rooms == null ? null : _bottomActions(context),
      body: SafeArea(
        top: false,
        bottom: false,
        child: rooms == null
            ? _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _loadFailed
                    ? ApiErrorState(onRetry: getRoomsData)
                    : const Center(child: Text('Ruangan tidak ditemukan'))
            : Column(
                children: [
                  SimaruGradientHeader(
                    title: 'Detail Ruangan',
                    height: MediaQuery.paddingOf(context).top +
                        80 *
                            MediaQuery.textScalerOf(context)
                                .scale(1)
                                .clamp(1.0, 2.0),
                    showBack: true,
                    padding: EdgeInsets.fromLTRB(
                        24.w.clamp(16.0, 32.0),
                        MediaQuery.paddingOf(context).top + 12,
                        24.w.clamp(16.0, 32.0),
                        12),
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ListView(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w.clamp(16.0, 32.0),
                              vertical: 18.h.clamp(12.0, 24.0)),
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18.r),
                              child: Image.network(
                                rooms?.image ?? '',
                                height: 255.h.clamp(180.0, 360.0),
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                        height: 255.h.clamp(180.0, 360.0),
                                        color: Colors.grey.shade200,
                                        child: Icon(Icons.broken_image,
                                            size: 64.r)),
                              ),
                            ),
                            SizedBox(height: 22.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rooms?.name ?? '',
                                    style: simaruTitle(size: 27)),
                                SizedBox(height: 10.h),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                      color: softBlueColor,
                                      borderRadius:
                                          BorderRadius.circular(20.r)),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                            color: bgColor1, size: 16.r),
                                        SizedBox(width: 5.w),
                                        Flexible(
                                            child: Text('Kominfo Jatim',
                                                style: simaruBody(
                                                    color: bgColor1,
                                                    size: 12,
                                                    weight: medium)))
                                      ]),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                                'Ruang rapat utama dengan fasilitas lengkap untuk mendukung rapat strategis dan koordinasi penting.',
                                style: simaruBody(
                                    color: const Color(0xff344054), size: 14)),
                            SizedBox(height: 22.h),
                            SimaruCard(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: _summary(
                                          Icons.location_on_outlined,
                                          'Lokasi',
                                          rooms?.floor?.toString() ??
                                              'Kantor Kominfo Jatim')),
                                  Container(
                                      width: 1,
                                      height: 86,
                                      color: const Color(0xffE6EAF1)),
                                  Expanded(
                                      child: _summary(
                                          Icons.groups_rounded,
                                          'Kapasitas',
                                          '${rooms?.capacity?.toString() ?? '-'} Orang')),
                                  Container(
                                      width: 1,
                                      height: 86,
                                      color: const Color(0xffE6EAF1)),
                                  Expanded(
                                      child: _summary(
                                          Icons.grid_view_rounded,
                                          'Tipe Ruangan',
                                          'Internal & Eksternal')),
                                ],
                              ),
                            ),
                            SizedBox(height: 18.h),
                            SimaruCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Informasi Ruangan',
                                      style: simaruBody(
                                          color: bgColor1,
                                          size: 17,
                                          weight: semibold)),
                                  SizedBox(height: 14.h),
                                  ...(rooms?.roomFacilities?.isNotEmpty ?? false
                                      ? rooms!.roomFacilities!
                                          .map((facility) => _facility(
                                              facility.facility?.name ?? '-'))
                                          .toList()
                                      : [
                                          'Ruang ber-AC dengan pencahayaan modern',
                                          'Layar LED dan sistem video conference',
                                          'Free Wi-Fi berkecepatan tinggi'
                                        ].map(_facility).toList()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _bottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 24.w.clamp(16.0, 32.0), vertical: 12.h.clamp(8.0, 16.0)),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
                child: SimaruPrimaryButton(
                    label: 'Lihat Jadwal',
                    outlined: true,
                    onPressed: () {
                      if (rooms?.id == null) return;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => RoomSchedulePage(
                                  roomId: rooms!.id!,
                                  roomName: rooms?.name ?? 'Ruangan')));
                    })),
            SizedBox(width: 15.w),
            Expanded(
                child: SimaruPrimaryButton(
                    label: 'Pesan',
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                FormPesanRuanganPage(idRoom: rooms?.id))))),
          ],
        ),
      ),
    );
  }

  Widget _summary(IconData icon, String label, String value) {
    return SizedBox(
      height: 142.h.clamp(126.0, 160.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                  color: const Color(0xffDCEBFF),
                  borderRadius: BorderRadius.circular(12.r)),
              child: Icon(icon, color: bgColor1, size: 28.r)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 20.h,
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: simaruBody(color: greyColor, size: 12),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            height: 42.h,
            child: Center(
              child: Text(
                value,
                maxLines: 2,
                softWrap: true,
                textAlign: TextAlign.center,
                style: simaruBody(color: bgColor1, size: 12, weight: semibold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _facility(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: bgColor1, size: 18.r),
          SizedBox(width: 10.w),
          Expanded(
              child: Text(text,
                  style: simaruBody(color: const Color(0xff344054), size: 13))),
        ],
      ),
    );
  }
}
