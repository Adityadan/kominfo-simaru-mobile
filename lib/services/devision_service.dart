import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/config.dart';
import '../models/devision_model.dart';

class DivisionDetailsService {
  Future<DevisionModel> fetchDevisionDetail({
    int? id,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/divisions/$id');
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'apikey': AppConfig.apiKey,
    };

    final response =
        await http.get(uri, headers: headers).timeout(AppConfig.requestTimeout);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return DevisionModel.fromJson(data);
    } else {
      throw Exception(
        'Failed to load division details (status ${response.statusCode})',
      );
    }
  }
}
