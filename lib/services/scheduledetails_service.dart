import 'dart:convert';
import 'package:simaru/models/schedule_model.dart';
import 'package:http/http.dart' as http;

import '../data/config.dart';

class ScheduleDetailsService {
  ScheduleDetailsService({this.client});
  final http.Client? client;

  Future<ScheduleModel> schedule(int? id, String? token) async {
    if (id == null) throw ArgumentError('ID ruangan tidak tersedia');
    var url = '$baseUrl/rooms/schedules/$id';
    var headers = {
      'Accept': 'application/json',
      'Authorization':
          token?.startsWith('Bearer ') == true ? token! : 'Bearer $token',
      'apikey': AppConfig.apiKey,
    };

    var response = await (client != null
            ? client!.get(Uri.parse(url), headers: headers)
            : http.get(Uri.parse(url), headers: headers))
        .timeout(AppConfig.requestTimeout);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is! Map || body['success'] == false) {
        throw const FormatException('Respons jadwal tidak valid');
      }
      dynamic data = body['data'];
      if (data is Map && data['data'] != null) data = data['data'];
      if (data is List) {
        final matches = data
            .whereType<Map>()
            .where((room) => room['id']?.toString() == '$id');
        data = matches.isEmpty ? null : matches.first;
      }
      if (data is! Map || !data.containsKey('bookings')) {
        throw const FormatException('Data jadwal ruangan tidak tersedia');
      }
      final bookings = data['bookings'];
      if (bookings != null &&
          bookings is! List &&
          !(bookings is Map && bookings['data'] is List)) {
        throw const FormatException('Format daftar jadwal tidak valid');
      }
      final schedule = ScheduleModel.fromJson(Map<String, dynamic>.from(data));
      if (schedule.id != null && schedule.id != id) {
        throw const FormatException(
            'Jadwal tidak sesuai dengan ruangan yang dipilih');
      }
      schedule.id ??= id;
      return schedule;
    } else {
      throw Exception(
          'Gagal memuat jadwal ruangan (HTTP ${response.statusCode})');
    }
  }
}
