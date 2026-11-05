import 'package:flutter_test/flutter_test.dart';
import 'package:simaru/provider/auth_provider.dart';

void main() {
  group('SIMARU APP', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    test('Login Success', () async {
      const email = 'member@member.com';
      const password = 'member';

      final result = await authProvider.login(email: email, password: password);

      expect(result, true);
      expect(authProvider.user, isNotNull);
    });

    test('Login Failure Password', () async {
      const email = 'user@diskominfo.com';
      const password = 'invalidpassword';

      final result = await authProvider.login(email: email, password: password);

      expect(result, false);
      expect(authProvider.user, isNull);
    });

    test('Login Failure Email', () async {
      const email = 'asa@diskominfo.com';
      const password = '121212';

      final result = await authProvider.login(email: email, password: password);

      expect(result, false);
      expect(authProvider.user, isNull);
    });
    test('Login Failure Email & Password Null', () async {
      const email = '';
      const password = '';

      final result = await authProvider.login(email: email, password: password);

      expect(result, false);
      expect(authProvider.user, isNull);
    });
  });
}
