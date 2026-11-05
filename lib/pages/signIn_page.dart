import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../themes.dart';
import '../widget/simaru_ui.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _obscureText = true;
  final TextEditingController emailController = TextEditingController(text: '');
  final TextEditingController passwordController = TextEditingController(text: '');

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final formLift = keyboardInset > 0 ? -(keyboardInset * 0.22).clamp(-110.0, 0.0) : 0.0;

    handleSignIn() async {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Logging In...',
                style: blackTextStyle.copyWith(fontSize: 20, fontWeight: bold),
                textAlign: TextAlign.center),
            content: const Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Please wait...')
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
                  child: Text('Cancel',
                      style: whiteTextStyle.copyWith(
                          fontSize: 16, fontWeight: semibold)),
                ),
              ),
            ],
          );
        },
      );

      final success = await authProvider.login(
          email: emailController.text, password: passwordController.text);
      if (!mounted) return;
      Navigator.pop(context);

      if (success) {
        Navigator.pushReplacementNamed(this.context, '/home');
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const SizedBox.shrink(),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('animations/failed.json',
                      width: 120, height: 120),
                  Text('Login Gagal',
                      style: blackTextStyle.copyWith(
                          fontSize: 20, fontWeight: bold),
                      textAlign: TextAlign.center),
                  const Text('Email atau password anda salah.'),
                ],
              ),
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
                            fontSize: 16, fontWeight: semibold)),
                  ),
                ),
              ],
            );
          },
        );
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: bgColor1,
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset('assets/home_image.png',
                  fit: BoxFit.cover,
                  color: bgColor1.withOpacity(.82),
                  colorBlendMode: BlendMode.srcATop)),
          Positioned.fill(
              child: Container(
                  decoration: BoxDecoration(gradient: simaruHeaderGradient()))),
          SafeArea(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(0, formLift, 0),
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    30,
                    32,
                    30,
                    keyboardInset > 0 ? keyboardInset + 28 : 28,
                  ),
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
                                  color: Colors.white,
                                  size: 14,
                                  weight: medium)),
                          Text('KOMINFO JATIM',
                              textAlign: TextAlign.center,
                              style: simaruBody(
                                  color: Colors.white,
                                  size: 14,
                                  weight: medium)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    Text('Masuk & Pesan Ruang',
                        textAlign: TextAlign.center,
                        style: simaruTitle(color: Colors.white, size: 18)),
                    const SizedBox(height: 20),
                    SimaruCard(
                      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email',
                              style: simaruBody(
                                  color: bgColor1, size: 15, weight: semibold)),
                          const SizedBox(height: 10),
                          TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: simaruInputDecoration(
                                  hint: 'Masukkan email anda',
                                  icon: Icons.mail_outline)),
                          const SizedBox(height: 22),
                          Text('Kata Sandi',
                              style: simaruBody(
                                  color: bgColor1, size: 15, weight: semibold)),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscureText,
                            decoration: simaruInputDecoration(
                              hint: 'Masukkan Kata Sandi anda',
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                    () => _obscureText = !_obscureText),
                                icon: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: SimaruPrimaryButton(
                                  label: 'Masuk',
                                  onPressed: handleSignIn,
                                  outlined: false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Belum Punya Akun ? ',
                            style: whiteTextStyle.copyWith(fontSize: 15)),
                        GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/sign-up'),
                            child: Text('Daftar disini',
                                style: yellowTextStyle.copyWith(
                                    fontSize: 15, fontWeight: semibold))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
