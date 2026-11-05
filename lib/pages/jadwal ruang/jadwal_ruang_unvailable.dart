import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/search_unvailable_provider.dart';
import 'package:simaru/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simaru/widget/api_error_state.dart';

class JadwalRuangUnvailablePage extends StatefulWidget {
  const JadwalRuangUnvailablePage({super.key});

  @override
  State<JadwalRuangUnvailablePage> createState() =>
      _JadwalRuangUnvailablePageState();
}

class _JadwalRuangUnvailablePageState extends State<JadwalRuangUnvailablePage> {
  TextEditingController nameRoomController = TextEditingController(text: '');
  bool _isSearching = false;

  @override
  void dispose() {
    nameRoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    SearchUnvailableProvider searchUnvailableProvider =
        Provider.of<SearchUnvailableProvider>(context);

    handleSend() async {
      if (_isSearching) return;
      setState(() => _isSearching = true);
      final success = await searchUnvailableProvider.searchunvailableroom(
        token: authProvider.user?.token,
        search: nameRoomController.text,
      );
      if (!mounted) return;
      setState(() => _isSearching = false);
      if (success) {
        Navigator.pushNamed(this.context, '/listunvailableroom');
      } else {
        showDialog<void>(
          context: this.context,
          builder: (_) => const Dialog(
            child: SizedBox(height: 250, child: ApiErrorState(size: 140)),
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
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama Ruang',
              style: blackTextStyle.copyWith(
                fontWeight: medium,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            TextFormField(
              controller: nameRoomController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
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
              sendButton(),
            ],
          ),
        ));
  }
}
