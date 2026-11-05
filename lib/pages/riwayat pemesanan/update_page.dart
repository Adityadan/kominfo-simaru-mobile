import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/update_provider.dart';
import 'package:simaru/themes.dart';
import '../../widget/simaru_ui.dart';

class FormUpdateRuanganPage extends StatefulWidget {
  final int? id;
  const FormUpdateRuanganPage({super.key, this.id});

  @override
  State<FormUpdateRuanganPage> createState() =>
      _FormUpdateRuanganPagePageState();
}

class _FormUpdateRuanganPagePageState extends State<FormUpdateRuanganPage> {
  String? selectedFilePath;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    String? fileType = result.files.single.extension;

    List<String> allowedFileTypes = [
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
    ];

    if (fileType == null ||
        !allowedFileTypes.contains(fileType.toLowerCase())) {
      if (kDebugMode) {
        print('Error: Jenis Berkas Tidak Diizinkan');
      }
      return;
    }

    setState(() {
      selectedFilePath = result.files.single.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UpdateProvider updateProvider = Provider.of<UpdateProvider>(context);

    handleSend() async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                Text(
                  'Booking Room...',
                  style: whiteTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Please wait...'),
              ],
            ),
          );
        },
      );

      final success = await updateProvider.updateAttachment(
        token: authProvider.user?.token,
        id: widget.id,
        attachment: selectedFilePath,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (success) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const SizedBox.shrink(),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'animations/done.json',
                    width: 120,
                    height: 120,
                  ),
                  Text(
                    'Sukses',
                    style: blackTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text('Ruangan Rapat Berhasil Dibooking.'),
                ],
              ),
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
                        borderRadius: BorderRadius.circular(56),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: whiteTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: semibold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const SizedBox.shrink(),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'animations/failed.json',
                    width: 120,
                    height: 120,
                  ),
                  Text(
                    'Pemesanan Gagal',
                    style: blackTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text('Silahkan Isi Data Dengan Benar.'),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: bgColor1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(56),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: whiteTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: semibold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    }

    Widget sendButton() {
      return Container(
        height: 50,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: TextButton(
          onPressed: handleSend,
          style: TextButton.styleFrom(
            backgroundColor: bgColor1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Update',
            style: primaryTextStyle.copyWith(fontSize: 18, fontWeight: medium),
          ),
        ),
      );
    }

    Widget attachment() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                onTap: _pickFile,
                child: const Row(
                  children: [
                    Icon(Icons.attach_file, size: 30),
                    SizedBox(width: 20),
                    Text('Tambah File'),
                  ],
                ),
              ),
            ),
          ),
          if (selectedFilePath != null) Text(selectedFilePath!),
        ],
      );
    }

    Widget content() {
      return SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: defaultMargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              attachment(),
              sendButton(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor1,
      body: Column(
        children: [
          SimaruGradientHeader(
            title: 'Update Attachment',
            subtitle: 'Perbarui lampiran pemesanan ruangan',
            height: MediaQuery.paddingOf(context).top +
                110 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0),
            showBack: true,
            titleSize: 20,
            subtitleSize: 11,
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.paddingOf(context).top + 12, 24, 12),
          ),
          Expanded(
            child: SimaruBottomCurve(
              padding: const EdgeInsets.only(top: 26, bottom: 20),
              child: content(),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
