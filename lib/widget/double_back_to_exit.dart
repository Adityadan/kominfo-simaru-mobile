import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Requires two Android back presses within two seconds on the main menu.
class DoubleBackToExit extends StatefulWidget {
  const DoubleBackToExit({super.key, required this.child});

  final Widget child;

  @override
  State<DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit>
    with WidgetsBindingObserver {
  Timer? _exitWindow;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-register when a new main route is entered, including after login.
    _syncBackHandling();
  }

  void _syncBackHandling() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      // Android may recreate its Activity while Flutter retains navigation
      // state. Resend this even if PopScope.canPop has not changed.
      SystemNavigator.setFrameworkHandlesBack(true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _exitWindow?.cancel();
    _exitWindow = null;
    if (state == AppLifecycleState.resumed) _syncBackHandling();
  }

  @override
  void dispose() {
    _exitWindow?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleBack(bool didPop, Object? result) {
    if (didPop) return;
    final messenger = ScaffoldMessenger.of(context);
    if (_exitWindow?.isActive ?? false) {
      _exitWindow?.cancel();
      messenger.hideCurrentSnackBar();
      SystemNavigator.pop();
      return;
    }
    _exitWindow = Timer(const Duration(seconds: 2), () {});
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('Tekan kembali sekali lagi untuk keluar'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: _handleBack,
      child: widget.child,
    );
  }
}
