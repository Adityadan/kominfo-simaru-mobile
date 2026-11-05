import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'package:simaru/models/user_model.dart';
import 'package:simaru/services/auth_service.dart';
import 'package:simaru/services/profille_service.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService();

  final ProfileService _profileService;
  UserModel? _user;
  Uint8List? _profilePhotoBytes;
  String? _profilePhotoError;

  UserModel? get user => _user;
  Uint8List? get profilePhotoBytes => _profilePhotoBytes;
  String? get profilePhotoError => _profilePhotoError;

  set user(UserModel? user) {
    _user = user;
    _profilePhotoBytes = null;
    _profilePhotoError = null;
    notifyListeners();
  }

  Future<bool> uploadProfilePhoto({
    required Uint8List bytes,
    required String filename,
  }) async {
    final token = _user?.token;
    if (token == null || token.isEmpty || bytes.isEmpty) {
      _profilePhotoError = 'Sesi akun tidak tersedia. Silakan masuk lagi.';
      return false;
    }
    final currentUser = _user;
    _profilePhotoError = null;
    try {
      final photo = await _profileService.uploadPhoto(
        bytes: bytes,
        filename: filename,
        token: token,
      );
      if (!identical(_user, currentUser)) return false;
      if (photo != null) _user?.photo = photo;
      _profilePhotoBytes = bytes;
      notifyListeners();
      return true;
    } catch (error) {
      _profilePhotoError = error.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> register({
    String? name,
    String? phone,
    String? email,
    String? password,
    String? passwordconfirmation,
    String? divisionid,
    String? gender,
    String? address,
    String? nip,
  }) async {
    try {
      UserModel user = await AuthService().register(
        name: name,
        phone: phone,
        email: email,
        password: password,
        passwordconfirmation: passwordconfirmation,
        divisionid: divisionid,
        gender: gender,
        address: address,
        nip: nip,
      );
      _user = user;
      _profilePhotoBytes = null;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> login({
    String? email,
    String? password,
  }) async {
    try {
      UserModel user = await AuthService().login(
        email: email,
        password: password,
      );

      _user = user;
      _profilePhotoBytes = null;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> logout({String? token}) async {
    try {
      if (token != null) {
        await AuthService().logout(token);
      }
      _user = null;
      _profilePhotoBytes = null;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
