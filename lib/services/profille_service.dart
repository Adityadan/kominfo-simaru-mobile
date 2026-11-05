import 'dart:convert';
import 'dart:typed_data';
import 'package:simaru/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../data/config.dart';

class ProfileService {
  ProfileService({this.client});

  final http.Client? client;

  Future<String?> uploadPhoto({
    required Uint8List bytes,
    required String filename,
    required String token,
  }) async {
    final request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/profile/update-photo'))
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
        'apikey': AppConfig.apiKey,
      })
      ..fields['_method'] = 'PUT'
      ..files.add(http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: filename,
        contentType: _imageType(filename),
      ));
    final streamedResponse = await (client?.send(request) ?? request.send())
        .timeout(AppConfig.uploadTimeout);
    final response = await http.Response.fromStream(streamedResponse)
        .timeout(AppConfig.uploadTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_responseError(response));
    }

    if (response.body.isEmpty) return null;
    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) return null;
    if (json['success'] == false) throw Exception(_responseError(response));
    final data = json['data'];
    if (data is String && data.trim().isNotEmpty) return data;
    final profile = data is Map<String, dynamic> ? data : json;
    final responseUser = profile['user'];
    final photo =
        (responseUser is Map<String, dynamic> ? responseUser['photo'] : null) ??
            profile['photo'] ??
            profile['photo_url'];
    return photo is String && photo.trim().isNotEmpty ? photo : null;
  }

  String _responseError(http.Response response) {
    if (response.statusCode == 302 ||
        response.statusCode == 401 ||
        response.statusCode == 403) {
      return 'Sesi akun tidak valid (HTTP ${response.statusCode}). Silakan masuk kembali.';
    }
    if (response.statusCode == 413) {
      return 'Ukuran foto terlalu besar untuk server (HTTP 413).';
    }
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final errors = body['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final details = errors.values
              .map((value) => value is List ? value.join(', ') : '$value')
              .join('\n');
          return '$details (HTTP ${response.statusCode})';
        }
        final message = body['message'];
        if (message is String && message.trim().isNotEmpty) {
          return '$message (HTTP ${response.statusCode})';
        }
      }
    } catch (_) {
      // The server can return an HTML error page instead of JSON.
    }
    return 'Server menolak unggahan foto (${response.statusCode})';
  }

  MediaType _imageType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      _ => MediaType('image', 'jpeg'),
    };
  }

  Future<UserModel> profile({
    String? name,
    String? phone,
    String? divisionid,
    String? gender,
    String? address,
    String? nip,
  }) async {
    var url = '$baseUrl/profile';
    var headers = {
      'Content-Type': 'application/json',
      'apikey': AppConfig.apiKey,
    };
    var body = jsonEncode({
      'name': name,
      'phone': phone,
      'division_id': divisionid,
      'gender': gender,
      'address': address,
      'nip': nip,
    });
    var response = await http
        .put(Uri.parse(url), headers: headers, body: body)
        .timeout(AppConfig.requestTimeout);
    if (response.statusCode == 200) {
      UserModel user = UserModel.fromJson(
          jsonDecode(response.body)['data'] ?? jsonDecode(response.body));
      return user;
    } else {
      throw Exception('Gagal Update');
    }
  }
}
