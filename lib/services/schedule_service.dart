import 'dart:convert';
import 'package:simaru/models/schedule_model.dart';
import 'package:http/http.dart' as http;

import '../data/config.dart';

class ScheduleService {
  Future<List<ScheduleModel>> schedule(String? token) async {
    var url = '$baseUrl/rooms/schedules';
    var headers = {
      'Content-Type': 'base/form-data',
      'Authorization': 'Bearer $token',
      'apikey': AppConfig.apiKey,
    };

    var response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(AppConfig.requestTimeout);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data']['data'];
      List<ScheduleModel> schedules = [];

      for (var item in data) {
        schedules.add(ScheduleModel.fromJson(item));
      }

      return schedules;
    } else {
      throw Exception('Failed to get schedules');
    }
  }
}
