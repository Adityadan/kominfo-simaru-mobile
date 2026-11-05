import 'dart:convert';
import 'package:http/http.dart' as http;

import '../data/config.dart';
import '../models/jadwal ruangan/search/search_model.dart';

class SearchService {
  Future<List<SearchModel>> searchroom({
    String? startdate,
    String? enddate,
    String? token,
  }) async {
    var url = '$baseUrl/rooms/search-available';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'apikey': AppConfig.apiKey,
    };
    var body = jsonEncode({
      'start_date': startdate.toString(),
      'end_date': enddate.toString(),
    });
    var response = await http
        .post(
          Uri.parse(url),
          headers: headers,
          body: body,
        )
        .timeout(AppConfig.requestTimeout);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      List<SearchModel> search = [];

      for (var item in data) {
        search.add(SearchModel.fromJson(item));
      }
      return search;
    } else {
      throw Exception('Failed Search');
    }
  }
}
