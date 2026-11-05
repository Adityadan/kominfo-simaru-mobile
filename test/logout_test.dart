import 'package:flutter_test/flutter_test.dart';
import 'package:simaru/models/user_model.dart';
import 'package:simaru/provider/auth_provider.dart';

void main() {
  group('Auth Provider', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    test('Logout Success', () async {
      authProvider.user = UserModel();

      final result = await authProvider.logout(
          token: '430|ZSSQ5KNPnsWm00cmUzJOeBNVsu0QfYeGohM0FNct');

      expect(result, true);
      expect(authProvider.user, isNull);
    });

    test('Logout Failure', () async {
      authProvider.user = UserModel();

      final result = await authProvider.logout(token: null);

      expect(result, false);
      expect(authProvider.user, isNotNull);
    });
  });
}
