import 'dart:convert';
import 'package:simaru/models/user_model.dart';
import 'package:http/http.dart' as http;

import '../data/config.dart';

class AuthService {
  Future<UserModel> register({
    String? name,
    String? email,
    String? phone,
    String? password,
    String? passwordconfirmation,
    String? divisionid,
    String? gender,
    String? address,
    String? nip,
  }) async {
    var url = '$baseUrl/auth/register';
    var headers = {
      'Content-Type': 'application/json',
      "Accept": "application/json"
    };
    var body = jsonEncode({
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordconfirmation,
      'division_id': divisionid,
      'gender': gender,
      'address': address,
      'nip': nip,
    });

    var response = await http
        .post(Uri.parse(url), headers: headers, body: body)
        .timeout(AppConfig.requestTimeout);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      UserModel user = UserModel.fromJson(data['user']);
      user.token = 'Bearer ${data['access_token']}';
      return user;
    } else {
      throw Exception('Gagal Register');
    }
  }

  Future<UserModel> login({
    String? email,
    String? password,
  }) async {
    var url = '$baseUrl/auth/login';
    var headers = {
      'Content-Type': 'application/json',
      'apikey': AppConfig.apiKey,
    };
    var body = jsonEncode({
      'email': email,
      'password': password,
    });

    var response = await http
        .post(Uri.parse(url), headers: headers, body: body)
        .timeout(AppConfig.requestTimeout);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      UserModel user = UserModel.fromJson(data['user']);
      user.token = data['access_token'];
      return user;
    } else {
      throw Exception('Gagal Login');
    }
  }

  Future<void> logout(String? token) async {
    var url = '$baseUrl/auth/logout';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'apikey': AppConfig.apiKey,
    };

    var response = await http
        .post(Uri.parse(url), headers: headers)
        .timeout(AppConfig.requestTimeout);

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Gagal logout');
    }
  }
}
