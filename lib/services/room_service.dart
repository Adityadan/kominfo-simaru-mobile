import 'dart:convert';
import 'package:http/http.dart' as http;

import '../data/config.dart';
import '../models/jadwal ruangan/search/search_model.dart';

class RoomServices {
  Future<SearchModel> room(int? id, String? token) async {
    var url = '$baseUrl/rooms/$id';

    var headers = {
      'Content-Type': 'base/form-data',
      'Authorization': 'Bearer $token',
      'apikey': AppConfig.apiKey,
    };
    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(AppConfig.requestTimeout);

    if (response.statusCode == 200) {
      SearchModel room =
          SearchModel.fromJson(jsonDecode(response.body)['data']);
      return room;
    } else {
      throw Exception('Gagal');
    }
  }
}
