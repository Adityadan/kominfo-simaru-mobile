import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/feedback_provider.dart';
import 'package:simaru/themes.dart';

class FeedbackPage extends StatefulWidget {
  final String? bookingId;

  const FeedbackPage({super.key, this.bookingId});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final List<File> _mediaList = [];
  bool _isSubmitting = false;
  TextEditingController descriptionController = TextEditingController(text: '');

  void _pickImage() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pilih Sumber Gambar"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _getImageFromCamera();
              },
              child: const Text("Kamera"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _getImageFromGallery();
              },
              child: const Text("Galeri"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _mediaList.add(File(pickedFile.path));
        });
      }
    } catch (_) {
      return;
    }
  }

  Future<void> _getImageFromGallery() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          setState(() {
            _mediaList.add(File(path));
          });
        }
      }
    } catch (_) {
      return;
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _mediaList.removeAt(index);
    });
  }

  void showFeedbackDialog(bool isSuccess, {String? errorMessage}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        title: Column(
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                isSuccess
                    ? 'animations/feedback succes.json'
                    : 'animations/feedback gagal.json',
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isSuccess
                    ? 'Berhasil Melakukan Feedback'
                    : 'Gagal Melakukan Feedback',
                textAlign: TextAlign.center,
              ),
              if (!isSuccess && errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) {
                  Navigator.pushNamed(context, '/home');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void handleReport() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    FeedbackProvider feedbackProvider =
        Provider.of<FeedbackProvider>(context, listen: false);

    bool result = await feedbackProvider.feedback(
      bookingId: widget.bookingId,
      description: descriptionController.text,
      mediaList: _mediaList,
      token: authProvider.user?.token,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    final errorMessage = feedbackProvider.errorMessage;
    showFeedbackDialog(result, errorMessage: errorMessage);
  }

  Widget deskripsiInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deskripsi',
            style: blackTextStyle.copyWith(fontSize: 17, fontWeight: medium),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: descriptionController,
            minLines: null,
            maxLines: null,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Deskripsi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gambar',
            style: primaryTextStyle3.copyWith(fontSize: 16, fontWeight: medium),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            itemCount: _mediaList.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            itemBuilder: (context, index) {
              if (index == _mediaList.length) {
                return InkWell(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: blackColor),
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo, color: Colors.black),
                  ),
                );
              } else {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.file(
                        _mediaList[index],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: _DeleteImageButton(
                        onPressed: () => _deleteImage(index),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget sendButton() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: TextButton(
        onPressed: _isSubmitting ? null : handleReport,
        style: TextButton.styleFrom(
          backgroundColor: blueColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Kirim',
                style:
                    primaryTextStyle.copyWith(fontSize: 18, fontWeight: medium),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: bgColor1,
        centerTitle: true,
        title: const Text('Keluhan Ruang'),
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _mediaList.clear();
              descriptionController.text = '';
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              deskripsiInput(),
              _imagePicker(),
              sendButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteImageButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DeleteImageButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        padding: const EdgeInsets.all(4),
        child: const Icon(Icons.delete, color: Colors.white, size: 20),
      ),
    );
  }
}
