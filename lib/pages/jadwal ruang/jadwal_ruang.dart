import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/search_room_provider.dart';
import 'package:simaru/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simaru/widget/api_error_state.dart';

class JadwalRuangPage extends StatefulWidget {
  const JadwalRuangPage({super.key});

  @override
  State<JadwalRuangPage> createState() => _JadwalRuangPageState();
}

class _JadwalRuangPageState extends State<JadwalRuangPage> {
  bool _isSearching = false;
  DateTime? startdate;
  DateTime? enddate;
  TextEditingController startDateController = TextEditingController(text: '');
  TextEditingController endDateController = TextEditingController(text: '');

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    SearchProvider searchProvider = Provider.of<SearchProvider>(context);

    handleSend() async {
      if (startDateController.text.isNotEmpty &&
          endDateController.text.isNotEmpty) {
        try {
          final now = DateTime.now();
          startdate =
              DateFormat("yyyy-MM-dd HH:mm:ss").parse(startDateController.text);
          enddate =
              DateFormat("yyyy-MM-dd HH:mm:ss").parse(endDateController.text);
          if (startdate!.isBefore(now)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: alertColor,
                content: const Text(
                  'Tanggal mulai harus setelah atau sama dengan tanggal sekarang',
                  textAlign: TextAlign.center,
                ),
              ),
            );
            return;
          }

          if (enddate!.isBefore(startdate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: alertColor,
                content: const Text(
                  'Tanggal selesai harus setelah tanggal mulai',
                  textAlign: TextAlign.center,
                ),
              ),
            );
            return;
          }
          if (_isSearching) return;
          setState(() => _isSearching = true);
          final success = await searchProvider.searchroom(
              token: authProvider.user?.token,
              startDate: DateFormat("yyyy-MM-dd HH:mm:ss").format(startdate!),
              endDate: DateFormat("yyyy-MM-dd HH:mm:ss").format(enddate!));
          if (!mounted) return;
          setState(() => _isSearching = false);
          if (success) {
            Navigator.pushNamed(this.context, '/listjadwalruang');
          } else {
            showDialog<void>(
              context: this.context,
              builder: (_) => const Dialog(
                child: SizedBox(height: 250, child: ApiErrorState(size: 140)),
              ),
            );
          }
        } catch (_) {
          if (!mounted) return;
          setState(() => _isSearching = false);
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(
              backgroundColor: alertColor,
              content: const Text(
                'Format tanggal tidak valid',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: alertColor,
            content: const Text(
              'Tanggal mulai dan selesai tidak boleh kosong',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }

    PreferredSizeWidget header() {
      return AppBar(
        backgroundColor: bgColor1,
        centerTitle: true,
        title: const Text('Jadwal Ruang'),
        elevation: 0,
      );
    }

    Widget startBookingInput() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          margin: const EdgeInsets.only(
            top: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tanggal Mulai',
                style: primaryTextStyle3.copyWith(
                  fontSize: 14,
                  fontWeight: medium,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryTextColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: startDateController,
                  readOnly: true,
                  onTap: () {
                    picker.DatePicker.showDateTimePicker(context,
                        theme: const picker.DatePickerTheme(
                          containerHeight: 210.0,
                        ),
                        showTitleActions: true, onConfirm: (date) {
                      String formattedDate =
                          DateFormat("yyyy-MM-dd HH:mm:ss").format(date);
                      startDateController.text = formattedDate;
                    },
                        currentTime: DateTime.now(),
                        locale: picker.LocaleType.id);
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: defaultMargin, vertical: 10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget endBookingInput() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          margin: const EdgeInsets.only(
            top: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tanggal Selesai',
                style: primaryTextStyle3.copyWith(
                  fontSize: 14,
                  fontWeight: medium,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryTextColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: endDateController,
                  readOnly: true,
                  onTap: () {
                    picker.DatePicker.showDateTimePicker(context,
                        theme: const picker.DatePickerTheme(
                          containerHeight: 210.0,
                        ),
                        showTitleActions: true, onConfirm: (date) {
                      String formattedDate =
                          DateFormat("yyyy-MM-dd HH:mm:ss").format(date);
                      endDateController.text = formattedDate;
                    },
                        currentTime: DateTime.now(),
                        locale: picker.LocaleType.id);
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: defaultMargin, vertical: 10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget sendButton() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          height: 50,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: TextButton(
            onPressed: _isSearching ? null : handleSend,
            style: TextButton.styleFrom(
              backgroundColor: bgColor1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSearching
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Cari',
                    style: primaryTextStyle.copyWith(
                        fontSize: 18, fontWeight: medium),
                  ),
          ),
        ),
      );
    }

    return Scaffold(
        backgroundColor: whiteColor,
        appBar: header(),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              startBookingInput(),
              endBookingInput(),
              sendButton(),
            ],
          ),
        ));
  }
}
