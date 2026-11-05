import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../themes.dart';
import '../widget/simaru_ui.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  void onPressed() async {
    const String message =
        'Halo, saya ingin mendaftar dan memesan ruang rapat di Dinas Komunikasi dan Informatika Provinsi Jawa Timur.';
    const String phoneNumber = '+6281252973315';
    final String whatsApp =
        'https://wa.me/$phoneNumber/?text=${Uri.encodeComponent(message)}';
    await launchUrl(Uri.parse(whatsApp), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor1,
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset('assets/home_image.png',
                  fit: BoxFit.cover,
                  color: bgColor1.withOpacity(.84),
                  colorBlendMode: BlendMode.srcATop)),
          Positioned.fill(
              child: Container(
                  decoration: BoxDecoration(gradient: simaruHeaderGradient()))),
          SafeArea(
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(30, 32, 30, 28),
                children: [
                  Transform.translate(
                    offset: const Offset(0, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset('assets/logoKominfo.png',
                                width: 100, height: 100, fit: BoxFit.cover)),
                        const SizedBox(height: 6),
                        Text('SIMARU',
                            textAlign: TextAlign.center,
                            style: simaruTitle(color: Colors.white, size: 38)
                                .copyWith(letterSpacing: 2)),
                        Text('Sistem Informasi Manajemen Ruang',
                            textAlign: TextAlign.center,
                            style: simaruBody(
                                color: Colors.white, size: 14, weight: medium)),
                        Text('KOMINFO JATIM',
                            textAlign: TextAlign.center,
                            style: simaruBody(
                                color: Colors.white, size: 14, weight: medium)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  Text('Daftar & Pesan Ruang',
                      textAlign: TextAlign.center,
                      style: simaruTitle(color: Colors.white, size: 18)),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(simaruRadius),
                      boxShadow: [simaruShadow(.09)],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 116,
                          height: 88,
                          decoration: BoxDecoration(
                              color: softBlueColor,
                              borderRadius: BorderRadius.circular(60)),
                          child: Icon(Icons.chat_bubble_rounded,
                              color: secondaryColor, size: 52),
                        ),
                        const SizedBox(height: 20),
                        Text(
                            'Silahkan Menghubungi Admin\nUntuk Mendaftarkan Akun',
                            textAlign: TextAlign.center,
                            style: blackTextStyle.copyWith(
                                fontSize: 18,
                                fontWeight: semibold,
                                height: 1.35)),
                        const SizedBox(height: 26),
                        SimaruPrimaryButton(
                            label: 'Klik Disini',
                            icon: Icons.chat_bubble_outline_rounded,
                            onPressed: onPressed),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sudah Punya Akun? ',
                          style: whiteTextStyle.copyWith(fontSize: 15)),
                      GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/sign-in'),
                          child: Text('Masuk disini',
                              style: TextStyle(
                                  color: yellowColor,
                                  fontSize: 15,
                                  fontWeight: semibold))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
