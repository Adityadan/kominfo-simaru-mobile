import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:simaru/pages/riwayat%20pemesanan/riwayat_page.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/provider/riwayat_provider.dart';
import 'package:simaru/themes.dart';

class TestHistoryState extends RiwayatProvider {
  TestHistoryState({required this.loading, required this.loaded, this.failure});

  final bool loading;
  final bool loaded;
  final String? failure;

  @override
  bool get isLoading => loading;
  @override
  bool get hasLoaded => loaded;
  @override
  String? get error => failure;
  @override
  Future<void> notifacation(String? token) async {}
}

void main() {
  Future<void> showHistory(WidgetTester tester, TestHistoryState state) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    blueTextStyle = const TextStyle();
    blackTextStyle = const TextStyle();
    whiteTextStyle = const TextStyle();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider<RiwayatProvider>.value(value: state),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, child) => const MaterialApp(home: RiwayatPage()),
      ),
    ));
    await tester.pump();
  }

  testWidgets('loading shows a spinner without the error animation',
      (tester) async {
    await showHistory(tester, TestHistoryState(loading: true, loaded: false));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Lottie), findsNothing);
  });

  testWidgets('API failure shows the animation after loading ends',
      (tester) async {
    await showHistory(tester,
        TestHistoryState(loading: false, loaded: false, failure: 'timeout'));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(Lottie), findsOneWidget);
  });

  testWidgets('successful empty response shows a plain empty message',
      (tester) async {
    await showHistory(tester, TestHistoryState(loading: false, loaded: true));
    expect(find.text('Belum ada riwayat pemesanan'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(Lottie), findsNothing);
  });
}
