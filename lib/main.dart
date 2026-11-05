import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simaru/pages/home/bottomsheet/faq.dart';
import 'package:simaru/pages/home/main_page.dart';
import 'package:simaru/pages/jadwal%20ruang/jadwal_ruang.dart';
import 'package:simaru/pages/jadwal%20ruang/list_jadwal_ruang.dart';
import 'package:simaru/pages/jadwal%20ruang/list_unvailable_room.dart';
import 'package:simaru/pages/jadwal%20ruang/unvailable_room.dart';
import 'package:simaru/pages/pesan%20ruang%20baru/pesan_ruang_room.dart';
import 'package:simaru/pages/riwayat%20pemesanan/riwayat_page.dart';
import 'package:simaru/pages/signIn_page.dart';
import 'package:simaru/pages/signUp_page.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/booking_room_provider.dart';
import 'package:simaru/provider/devision_provider.dart';
import 'package:simaru/provider/feedback_provider.dart';
import 'package:simaru/provider/pesan_ruang_provider.dart';
import 'package:simaru/provider/riwayat_provider.dart';
import 'package:simaru/provider/schedule_provider.dart';
import 'package:simaru/provider/search_room_provider.dart';
import 'package:simaru/provider/search_scheduledetails_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simaru/provider/search_unvailable_provider.dart';
import 'package:simaru/provider/update_provider.dart';
import 'package:simaru/themes.dart';
import 'pages/keluhan ruang/feedback_page.dart';

const _statusBarStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemStatusBarContrastEnforced: false,
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(_statusBarStyle);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => FeedbackProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => RiwayatProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ScheduleProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SearchProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => BookingRoomProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SearchScheduleDetailsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PesanRuangProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SearchUnvailableProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UpdateProvider(),
        ),
        ChangeNotifierProvider(create: (context) => DivisionDetailsProvider()),
      ],
      child: ScreenUtilInit(
        // Baseline mobile design in logical pixels.
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        fontSizeResolver: (fontSize, instance) =>
            fontSize * (instance.screenWidth / 390).clamp(0.85, 1.2),
        builder: (context, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: _statusBarStyle,
            child: child ?? const SizedBox.shrink(),
          ),
          theme: ThemeData(
            scaffoldBackgroundColor: whiteColor,
            canvasColor: whiteColor,
            dialogBackgroundColor: whiteColor,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              systemOverlayStyle: _statusBarStyle,
            ),
          ),
          routes: {
            '/': (context) => const SignInPage(),
            '/sign-in': (context) => const SignInPage(),
            '/sign-up': (context) => const SignUpPage(),
            '/home': (context) => const MainPage(),
            '/faq': (context) => const FaqPage(),
            '/riwayat': (context) => const RiwayatPage(),
            '/feedback': (context) => const FeedbackPage(),
            '/jadwalruang': (context) => const JadwalRuangPage(),
            '/listjadwalruang': (context) => const ListJadwalRuang(),
            '/pesanruang': (context) => const PesanRuangPage(),
            '/unvailableroom': (context) => const UnvailbleRoomPage(),
            '/listunvailableroom': (context) => const ListUnvailableRoomPage(),
          },
        ),
      ),
    );
  }
}
