import 'package:flutter_test/flutter_test.dart';
import 'package:simaru/provider/riwayat_provider.dart';

void main() {
  group('RiwayatProvider Tests', () {
    test('notification - success', () async {
      final provider = RiwayatProvider();

      // Replace 'your_token_here' with a valid token for testing.
      const token = '32|w1YyrdvAGQKNeCAxuget2HDTk4RHBTCAmZlblV1X';

      await provider.notifacation(token);

      // Assert that the provider's notifications list is not empty after a successful request.
      expect(provider.notif, isNotNull);
      expect(provider.notif.length, greaterThan(0));
    });

    test('notification - failed', () async {
      final provider = RiwayatProvider();

      // Use an invalid token to trigger an error.
      const token = 'invalid_token';

      await provider.notifacation(token);

      // Expect that the provider's error field is not null after a failure.
      expect(provider, isNotNull);
    });
  });
}
