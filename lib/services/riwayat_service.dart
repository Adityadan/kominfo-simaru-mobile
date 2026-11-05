import 'dart:convert';
import 'package:http/http.dart' as http;

import '../data/config.dart';
import '../models/riwayat ruangan/riwayat_model.dart';

class RiwayatService {
  Future<List<RiwayatModel>> notification(String? token) async {
    var url = '$baseUrl/booking';
    var headers = {
      'Content-Type': 'application/json',
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
      List data = jsonDecode(response.body)['data'];
      List<RiwayatModel> notif = [];

      for (var item in data) {
        notif.add(RiwayatModel.fromJson(item));
      }
      return notif;
    } else {
      throw Exception('Gagal get notif');
    }
  }
}
