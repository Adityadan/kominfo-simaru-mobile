import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ApiErrorState extends StatelessWidget {
  const ApiErrorState({super.key, this.onRetry, this.size = 180});

  final VoidCallback? onRetry;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('animations/tidakadanotif.json',
                width: size, height: size),
            const SizedBox(height: 8),
            const Text('Data gagal dimuat. Coba lagi.',
                textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
            ],
          ],
        ),
      ),
    );
  }
}
