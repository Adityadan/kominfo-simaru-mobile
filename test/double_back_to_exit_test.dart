import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simaru/widget/double_back_to_exit.dart';

void main() {
  testWidgets('First back shows message, second back exits', (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(const MaterialApp(
      home: DoubleBackToExit(child: Scaffold(body: Text('Main menu'))),
    ));
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('Tekan kembali sekali lagi untuk keluar'), findsOneWidget);
    expect(
        calls.where((call) => call.method == 'SystemNavigator.pop'), isEmpty);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(calls.where((call) => call.method == 'SystemNavigator.pop'),
        hasLength(1));
  });

  testWidgets('Back after timeout starts a new confirmation window',
      (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(const MaterialApp(
      home: DoubleBackToExit(child: Scaffold()),
    ));
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(seconds: 3));
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(
        calls.where((call) => call.method == 'SystemNavigator.pop'), isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Detail route returns normally without exit message',
      (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigator,
      home: const DoubleBackToExit(child: Scaffold(body: Text('Main menu'))),
    ));
    navigator.currentState!.push(MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: Text('Detail')),
    ));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Main menu'), findsOneWidget);
    expect(find.text('Tekan kembali sekali lagi untuk keluar'), findsNothing);
  });
  testWidgets(
      'Resume restores Android back interception and resets confirmation',
      (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(const MaterialApp(
      home: DoubleBackToExit(child: Scaffold()),
    ));
    await tester.binding.handlePopRoute();
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    calls.clear();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(
        calls.any((call) =>
            call.method == 'SystemNavigator.setFrameworkHandlesBack' &&
            call.arguments == true),
        isTrue);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(
        calls.where((call) => call.method == 'SystemNavigator.pop'), isEmpty);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(calls.where((call) => call.method == 'SystemNavigator.pop'),
        hasLength(1));
  });

  testWidgets('A new login session requires two back presses again',
      (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigator,
      home: const Scaffold(body: Text('Login')),
    ));
    for (var session = 0; session < 2; session++) {
      navigator.currentState!.pushReplacement(MaterialPageRoute<void>(
        builder: (_) => const DoubleBackToExit(child: Scaffold()),
      ));
      await tester.pumpAndSettle();
      calls.clear();
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(
          calls.where((call) => call.method == 'SystemNavigator.pop'), isEmpty);
      expect(
          find.text('Tekan kembali sekali lagi untuk keluar'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(calls.where((call) => call.method == 'SystemNavigator.pop'),
          hasLength(1));
      navigator.currentState!.pushReplacement(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Login')),
      ));
      await tester.pumpAndSettle();
    }
  });
}
