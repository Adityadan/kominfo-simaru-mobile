import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/booking_room_provider.dart';
import 'package:simaru/services/booking_attachment_file.dart';
import 'package:simaru/services/booking_service.dart';
import 'package:simaru/services/scheduledetails_service.dart';
import 'package:simaru/services/room_recommendation_service.dart';
import 'package:simaru/widget/room_recommendations_dialog.dart';
import 'package:simaru/models/booking_availability.dart';
import 'package:simaru/widget/booking_datetime_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:simaru/themes.dart';
import 'package:intl/intl.dart';
import '../../widget/simaru_ui.dart';
import 'package:flutter/services.dart';

class FormPesanRuanganPage extends StatefulWidget {
  final int? idRoom;
  final ScheduleDetailsService? scheduleService;
  final RoomRecommendationService? recommendationService;
  final String? roomName;
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final DateTime Function()? now;
  const FormPesanRuanganPage(
      {super.key,
      this.idRoom,
      this.scheduleService,
      this.now,
      this.recommendationService,
      this.roomName,
      this.initialStart,
      this.initialEnd});

  @override
  State<FormPesanRuanganPage> createState() => _FormPesanRuanganPagePageState();
}

class _FormPesanRuanganPagePageState extends State<FormPesanRuanganPage> {
  PlatformFile? selectedFile;
  Uint8List? _selectedFileBytes;
  bool _sending = false;
  bool _openingPicker = false;
  bool _recommending = false;
  DateTime? _recommendationDay;
  final Set<DateTime> _autoRecommendedDays = {};
  BookingAvailability? _availability;
  late final ScheduleDetailsService _scheduleService;
  late final RoomRecommendationService _recommendationService;
  DateTime get _now => (widget.now?.call() ?? DateTime.now()).toLocal();
  final nameController = TextEditingController();
  final nipController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    nameController.text = user?.name ?? '';
    nipController.text = user?.member?.nip ?? '';
    phoneController.text = user?.phone ?? '';
    _scheduleService = widget.scheduleService ??
        ScheduleDetailsService(includeBookingDetails: false);
    _recommendationService = widget.recommendationService ??
        RoomRecommendationService(schedules: _scheduleService);
    if (widget.initialStart != null) {
      startDateController.text =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.initialStart!);
      _recommendationDay = _day(widget.initialStart!);
    }
    if (widget.initialEnd != null) {
      endDateController.text =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.initialEnd!);
    }
  }

  DateTime _day(DateTime time) => DateTime(time.year, time.month, time.day);

  DateTime? get _selectedRecommendationDay =>
      _recommendationDay ?? DateTime.tryParse(startDateController.text);

  Future<void> _showRecommendations(
      {bool automatic = false,
      DateTime? day,
      bool dismissPickerOnChoose = false}) async {
    if (_sending || (_openingPicker && !automatic) || _recommending) return;
    final selectedDay = day ?? _selectedRecommendationDay;
    if (selectedDay == null) return;
    if (widget.idRoom == null) {
      _showMessage('Pilih ruangan terlebih dahulu.');
      return;
    }
    setState(() => _recommending = true);
    try {
      final recommendationDay = _day(selectedDay);
      _recommendationDay = recommendationDay;
      final chosen = await showDialog<RoomRecommendation>(
        context: context,
        barrierDismissible: false,
        builder: (_) => RoomRecommendationsDialog(
          service: _recommendationService,
          day: recommendationDay,
          currentRoomId: widget.idRoom!,
          token: context.read<AuthProvider>().user?.token,
          now: _now,
          automatic: automatic,
          occupiedPeriods:
              _availability?.periodsOn(recommendationDay) ?? const [],
        ),
      );
      if (!mounted || chosen == null) return;
      if (dismissPickerOnChoose && _openingPicker) {
        Navigator.of(context).pop();
      }
      final window = chosen.bestWindow;
      final duration = window.duration < const Duration(hours: 4)
          ? window.duration
          : const Duration(hours: 4);
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => FormPesanRuanganPage(
                idRoom: chosen.room.id,
                roomName: chosen.room.name,
                initialStart: window.start,
                initialEnd: window.start.add(duration),
                scheduleService: _scheduleService,
                recommendationService: _recommendationService,
                now: widget.now,
              )));
    } finally {
      if (mounted) setState(() => _recommending = false);
    }
  }

  Future<bool> _loadAvailability() async {
    try {
      final roomId = widget.idRoom;
      if (roomId == null) throw const FormatException('Pilih ruangan dahulu.');
      final schedule = await _scheduleService.schedule(
          roomId, context.read<AuthProvider>().user?.token);
      final availability = BookingAvailability.fromSchedule(schedule, roomId);
      if (!mounted) return false;
      _availability = availability;
      return true;
    } catch (_) {
      if (!mounted) return false;
      _availability = null;
      return false;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDate(TextEditingController controller) async {
    if (_sending || _openingPicker || _recommending) return;
    _openingPicker = true;
    DateTime? recommendationDay;
    try {
      final isStart = controller == startDateController;
      final start = DateTime.tryParse(startDateController.text);
      if (!isStart && start == null) {
        _showMessage('Pilih waktu mulai terlebih dahulu.');
        return;
      }
      if (!await _loadAvailability() || !mounted) {
        if (mounted) _showMessage('Jadwal gagal dimuat. Silakan coba lagi.');
        return;
      }
      final now = _now;
      final availability = _availability!;
      if (!isStart &&
          (start!.isBefore(now) || !availability.allowsStart(start))) {
        _showMessage(
            'Waktu mulai sudah tidak tersedia. Pilih waktu mulai lain.');
        return;
      }
      DateTime? resolve(DateTime requested) {
        final candidate = requested.isBefore(now) ? now : requested;
        return isStart
            ? availability.nextAvailableStart(candidate)
            : availability.availableEnd(start!, candidate);
      }

      bool available(DateTime time) =>
          !time.isBefore(now) &&
          (isStart
              ? availability.allowsStart(time)
              : availability.allowsRange(start!, time));
      final previous = DateTime.tryParse(controller.text);
      final requested = previous ?? (isStart ? now : start!);
      var requestedDay = _day(requested);
      final initial = resolve(requested);
      if (initial == null) {
        _showMessage(
            'Tidak ada waktu selesai tersedia. Pilih waktu mulai lain.');
        return;
      }
      final selected = await BookingDatePicker.showDateTimePicker(context,
          theme: const picker.DatePickerTheme(containerHeight: 210.0),
          showTitleActions: true,
          currentTime: now,
          initialTime: initial, onSelectionRequested: (time) {
        requestedDay = _day(time);
        if (isStart &&
            !_recommending &&
            availability.needsRoomRecommendations(requestedDay,
                notBefore: now) &&
            _autoRecommendedDays.add(requestedDay)) {
          _showRecommendations(
              automatic: true, day: requestedDay, dismissPickerOnChoose: true);
        }
      },
          isTimeAvailable: available,
          nextAvailableTime: resolve,
          locale: picker.LocaleType.id);
      if (!mounted || selected == null) return;
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(selected);
        if (isStart) {
          _recommendationDay = requestedDay;
          recommendationDay = requestedDay;
          final end = DateTime.tryParse(endDateController.text);
          if (end != null && !availability.allowsRange(selected, end)) {
            endDateController.clear();
          }
        }
      });
    } finally {
      _openingPicker = false;
    }
    final day = recommendationDay;
    if (mounted &&
        day != null &&
        _availability!.needsRoomRecommendations(day, notBefore: _now) &&
        _autoRecommendedDays.add(day)) {
      await _showRecommendations(automatic: true, day: day);
    }
  }

  @override
  void dispose() {
    for (final c in [
      nameController,
      nipController,
      phoneController,
      startDateController,
      endDateController,
      descriptionController,
      partcipantInternalController,
      partcipantExternalController
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  DateTime? startdate;
  DateTime? enddate;
  TextEditingController startDateController = TextEditingController(text: '');
  TextEditingController endDateController = TextEditingController(text: '');
  TextEditingController descriptionController = TextEditingController(text: '');
  TextEditingController partcipantInternalController =
      TextEditingController(text: '');
  TextEditingController partcipantExternalController =
      TextEditingController(text: '');
  String _radioValue = 'INTERNAL';

  void _handleRadioValueChange(String? value) {
    if (value == null) return;
    setState(() {
      _radioValue = value;
      if (_radioValue == 'INTERNAL') {
        partcipantInternalController.text = '';
        partcipantExternalController.text = '0';
      } else if (_radioValue == 'EXTERNAL') {
        partcipantInternalController.text = '0';
        partcipantExternalController.text = '';
      } else if (_radioValue == 'INTERNAL & EXTERNAL') {
        partcipantInternalController.text = '';
        partcipantExternalController.text = '';
      }
    });
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: [
            'jpg',
            'png',
            'jpeg',
            'pdf',
            'doc',
            'docx',
            'xls',
            'xlsx',
            'ppt',
            'pptx'
          ],
          withData: true);
      if (!mounted || result == null || result.files.isEmpty) return;
      final file = result.files.single;
      if (file.size >= maxBookingAttachmentBytes) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ukuran lampiran harus kurang dari 5 MB.')));
        return;
      }
      final bytes = await readBookingAttachmentBytes(file);
      if (!mounted) return;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Berkas kosong');
      }
      if (bytes.length >= maxBookingAttachmentBytes) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ukuran lampiran harus kurang dari 5 MB.')));
        return;
      }
      setState(() {
        selectedFile = file;
        _selectedFileBytes = bytes;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Berkas tidak dapat dibaca. Silakan pilih ulang.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    BookingRoomProvider bookingRoomProvider =
        Provider.of<BookingRoomProvider>(context);

    handleSend() async {
      if (_sending || _openingPicker || _recommending) return;
      startdate = startDateController.text.isNotEmpty
          ? DateTime.tryParse(startDateController.text)
          : null;
      enddate = endDateController.text.isNotEmpty
          ? DateTime.tryParse(endDateController.text)
          : null;
      if (startdate == null || enddate == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: alertColor,
            content:
                const Text('Tanggal mulai dan selesai tidak boleh kosong')));
        return;
      }
      String? error;
      final internal = int.tryParse(partcipantInternalController.text.trim());
      final external = int.tryParse(partcipantExternalController.text.trim());
      if (nameController.text.trim().isEmpty ||
          nipController.text.trim().isEmpty ||
          phoneController.text.trim().isEmpty) {
        error = 'Nama, NIP, dan nomor telepon wajib diisi.';
      } else if (widget.idRoom == null) {
        error = 'Pilih ruangan terlebih dahulu.';
      } else if (descriptionController.text.trim().isEmpty) {
        error = 'Deskripsi kegiatan wajib diisi.';
      } else if ((_radioValue != 'EXTERNAL' &&
              (internal == null || internal <= 0)) ||
          (_radioValue != 'INTERNAL' && (external == null || external <= 0))) {
        error =
            'Jumlah peserta untuk jenis yang dipilih wajib berupa bilangan bulat positif.';
      } else if (!enddate!.isAfter(startdate!)) {
        error = 'Waktu selesai harus setelah waktu mulai.';
      } else if (startdate!.isBefore(_now)) {
        error = 'Waktu mulai tidak boleh berada di masa lalu.';
      } else if (_selectedFileBytes?.isNotEmpty != true) {
        error = 'Lampiran wajib diunggah sebelum memesan ruangan.';
      } else if (_selectedFileBytes!.length >= maxBookingAttachmentBytes) {
        error = 'Ukuran lampiran harus kurang dari 5 MB.';
      }
      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
        return;
      }
      final formattedStartDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(startdate!);
      final formattedEndDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(enddate!);

      setState(() => _sending = true);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Please wait...')
              ])));

      // Pemeriksaan terakhir memakai jadwal baru, bukan cache saat form dibuka.
      final scheduleReady = await _loadAvailability();
      if (!context.mounted) return;
      if (!scheduleReady ||
          startdate!.isBefore(_now) ||
          !_availability!.allowsRange(startdate!, enddate!)) {
        setState(() => _sending = false);
        Navigator.of(context).pop();
        _showMessage(scheduleReady
            ? 'Waktu sudah terisi atau jeda antar pemesanan belum lebih dari 15 menit. Pilih waktu lain.'
            : 'Jadwal gagal dimuat. Pesanan belum dikirim; silakan coba lagi.');
        return;
      }

      final success = await bookingRoomProvider.bookingRoom(
        token: authProvider.user?.token,
        name: nameController.text.trim(),
        devision: authProvider.user?.member?.divisionId,
        participantExternal: _radioValue == 'INTERNAL'
            ? '0'
            : partcipantExternalController.text.trim(),
        participantInternal: _radioValue == 'EXTERNAL'
            ? '0'
            : partcipantInternalController.text.trim(),
        roomid: widget.idRoom,
        description: descriptionController.text.trim(),
        nip: nipController.text.trim(),
        phone: phoneController.text.trim(),
        startDate: formattedStartDate,
        endDate: formattedEndDate,
        participanttype: _radioValue,
        attachmentBytes: _selectedFileBytes,
        attachmentName: selectedFile?.name,
      );

      if (!context.mounted) return;
      setState(() => _sending = false);
      Navigator.of(context).pop();
      if (success) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const SizedBox.shrink(),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Lottie.asset('animations/done.json', width: 120, height: 120),
              Text('Sukses',
                  style:
                      blackTextStyle.copyWith(fontSize: 20, fontWeight: bold),
                  textAlign: TextAlign.center),
              const Text('Ruangan Rapat Berhasil Dibooking.')
            ]),
            actions: [
              SizedBox(
                  width: double.infinity,
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/home');
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: bgColor1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(56))),
                      child: Text('Done',
                          style: whiteTextStyle.copyWith(
                              fontSize: 16, fontWeight: semibold))))
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const SizedBox.shrink(),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Lottie.asset('animations/failed.json', width: 120, height: 120),
              Text('Pemesanan Gagal',
                  style:
                      blackTextStyle.copyWith(fontSize: 20, fontWeight: bold),
                  textAlign: TextAlign.center),
              Text(bookingRoomProvider.errorMessage ??
                  'Pemesanan gagal. Silakan coba lagi.')
            ]),
            actions: [
              SizedBox(
                  width: double.infinity,
                  child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                          backgroundColor: bgColor1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(56))),
                      child: Text('Done',
                          style: whiteTextStyle.copyWith(
                              fontSize: 16, fontWeight: semibold))))
            ],
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: bgColor1,
      body: Column(
        children: [
          SimaruGradientHeader(
            title: 'Pemesanan Ruang',
            subtitle: widget.roomName ?? 'Silakan lengkapi informasi pemesanan',
            height: MediaQuery.paddingOf(context).top +
                80 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0),
            showBack: true,
            titleSize: 20,
            subtitleSize: 11,
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.paddingOf(context).top + 12, 24, 0),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
              decoration: const BoxDecoration(color: Colors.white),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...[
                    ('Nama Pemesan', nameController),
                    ('NIP', nipController),
                    ('Nomor Telepon', phoneController),
                  ].map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _labeledField(
                          label: '${entry.$1} *',
                          child: TextFormField(
                              controller: entry.$2,
                              enabled: !_sending,
                              decoration: simaruInputDecoration(
                                  hint: entry.$1,
                                  icon: Icons.person_outline))))),
                  Text('Pilih Jenis Peserta',
                      style: simaruBody(
                          color: bgColor1, size: 17, weight: semibold)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                          flex: 11, child: _choiceChip('INTERNAL', 'Internal')),
                      const SizedBox(width: 6),
                      Expanded(
                          flex: 12,
                          child: _choiceChip('EXTERNAL', 'Eksternal')),
                      const SizedBox(width: 6),
                      Expanded(
                          flex: 20,
                          child: _choiceChip(
                              'INTERNAL & EXTERNAL', 'Internal & Eksternal')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _participantFields(),
                  const SizedBox(height: 20),
                  _labeledField(
                      label: 'Deskripsi Kegiatan',
                      child: TextFormField(
                          controller: descriptionController,
                          minLines: 3,
                          maxLines: 4,
                          decoration: simaruInputDecoration(
                              hint: 'Jelaskan kegiatan yang akan dilakukan',
                              icon: Icons.description_outlined))),
                  const SizedBox(height: 20),
                  _labeledField(
                      label: 'Waktu Awal Pemesanan',
                      child: _dateField(
                          startDateController, 'Pilih tanggal & waktu mulai')),
                  const SizedBox(height: 20),
                  _labeledField(
                      label: 'Waktu Akhir Pemesanan',
                      child: _dateField(
                          endDateController, 'Pilih tanggal & waktu selesai')),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _sending ||
                            _recommending ||
                            _selectedRecommendationDay == null
                        ? null
                        : () => _showRecommendations(),
                    icon: const Icon(Icons.meeting_room_outlined),
                    label: const Text('Rekomendasi Ruangan'),
                  ),
                  const SizedBox(height: 28),
                  InkWell(
                    onTap: _pickFile,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: borderBlueColor, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color: const Color(0xffF1F5F9),
                                borderRadius: BorderRadius.circular(14)),
                            child: Icon(Icons.attach_file_rounded,
                                color: bgColor1, size: 30)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Tambah File',
                                  style: simaruBody(
                                      color: bgColor1,
                                      size: 16,
                                      weight: semibold)),
                              Text(
                                  selectedFile?.name ??
                                      'Upload file pendukung (wajib, kurang dari 5 MB)',
                                  style: simaruBody(
                                      color: mutedTextColor, size: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)
                            ]))
                      ]),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SimaruPrimaryButton(
                      label: _sending ? 'Mengirim...' : 'Pesan',
                      onPressed: handleSend),
                ],
              ),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget _choiceChip(String value, String label) {
    final selected = _radioValue == value;
    return InkWell(
      onTap: () => _handleRadioValueChange(value),
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
            color: selected ? softBlueColor : Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
                color: selected ? secondaryColor : const Color(0xffD9E1EC))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? secondaryColor : const Color(0xff8EA0B8),
                size: 15),
            const SizedBox(width: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label,
                    maxLines: 1,
                    style:
                        simaruBody(color: bgColor1, size: 10, weight: semibold)
                            .copyWith(height: 1.2)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _participantFields() {
    if (_radioValue == 'INTERNAL & EXTERNAL') {
      return Row(children: [
        Expanded(
            child: _labeledField(
                label: 'Jumlah Partisipasi Internal',
                child: TextFormField(
                    controller: partcipantInternalController,
                    keyboardType: TextInputType.number,
                    decoration: simaruInputDecoration(
                        hint: 'Internal',
                        icon: Icons.person_outline_rounded)))),
        const SizedBox(width: 12),
        Expanded(
            child: _labeledField(
                label: 'Jumlah Partisipasi Eksternal',
                child: TextFormField(
                    controller: partcipantExternalController,
                    keyboardType: TextInputType.number,
                    decoration: simaruInputDecoration(
                        hint: 'Eksternal',
                        icon: Icons.person_outline_rounded))))
      ]);
    }
    final controller = _radioValue == 'EXTERNAL'
        ? partcipantExternalController
        : partcipantInternalController;
    return _labeledField(
        label: 'Jumlah Partisipasi',
        child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: simaruInputDecoration(
                hint: 'Masukkan jumlah partisipasi',
                icon: Icons.person_outline_rounded)));
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: simaruBody(color: bgColor1, size: 15, weight: semibold)),
      const SizedBox(height: 10),
      child
    ]);
  }

  Widget _dateField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _pickDate(controller),
      decoration: simaruInputDecoration(
          hint: hint, icon: Icons.calendar_today_outlined),
    );
  }
}
