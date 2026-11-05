import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:simaru/models/user_model.dart';
import 'package:simaru/pages/home/bottomsheet/profile.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/services/profille_service.dart';

class FakeProfileService extends ProfileService {
  @override
  Future<String?> uploadPhoto({
    required Uint8List bytes,
    required String filename,
    required String token,
  }) async =>
      '/storage/profile.jpg';
}

void main() {
  test('profile photo uses the dedicated update-photo endpoint', () async {
    final service = ProfileService(client: MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/profile/update-photo');
      expect(request.headers['authorization'], 'Bearer test-token');
      expect(request.body, contains('name="_method"'));
      expect(request.body, contains('PUT'));
      expect(request.body, contains('name="photo"'));
      expect(request.body, contains('avatar.jpg'));
      expect(request.body, isNot(contains('name="division_id"')));
      return http.Response(
          jsonEncode({'success': true, 'data': '/storage/avatar.jpg'}), 200);
    }));

    final photo = await service.uploadPhoto(
      bytes: Uint8List.fromList([1, 2, 3]),
      filename: 'avatar.jpg',
      token: 'test-token',
    );
    expect(photo, '/storage/avatar.jpg');
  });

  test('upload exposes validation errors returned by the API', () async {
    final service = ProfileService(
        client: MockClient((_) async => http.Response(
              jsonEncode({
                'errors': {
                  'photo': ['Format foto tidak didukung']
                }
              }),
              422,
            )));

    expect(
      () => service.uploadPhoto(
        bytes: Uint8List.fromList([1]),
        filename: 'avatar.jpg',
        token: 'test-token',
      ),
      throwsA(isA<Exception>().having(
          (error) => error.toString(), 'message', contains('Format foto'))),
    );
  });

  test('successful upload updates the current account photo', () async {
    final auth = AuthProvider(profileService: FakeProfileService())
      ..user = UserModel(name: 'Pengguna', token: 'test-token');
    final bytes = Uint8List.fromList([1, 2, 3]);

    expect(await auth.uploadProfilePhoto(bytes: bytes, filename: 'avatar.jpg'),
        isTrue);
    expect(auth.user?.photo, '/storage/profile.jpg');
    expect(auth.profilePhotoBytes, bytes);
  });

  testWidgets('profile offers gallery and camera choices', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final auth = AuthProvider()..user = UserModel(name: 'Pengguna');

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: auth,
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, child) => const MaterialApp(home: ProfilePage()),
      ),
    ));
    await tester.pump();
    await tester.tap(find.text('Ubah foto profil'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih dari galeri'), findsOneWidget);
    expect(find.text('Ambil foto'), findsOneWidget);
  });
}
