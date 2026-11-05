import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:simaru/data/config.dart';
import 'package:simaru/models/feedback_model.dart';

class FeedbackService {
  Future<FeedbackModel> feedback({
    String? bookingId,
    String? description,
    List<File>? mediaList,
    String? token,
  }) async {
    final url = '$baseUrl/feedbacks';
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'apikey': AppConfig.apiKey,
    };

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(headers)
      ..fields['booking_id'] = bookingId ?? ''
      ..fields['description'] = description ?? '';

    if (mediaList != null && mediaList.isNotEmpty) {
      for (var media in mediaList) {
        final stream = http.ByteStream(Stream.castFrom(media.openRead()));
        final length = await media.length();
        final filename = media.path.split(Platform.pathSeparator).last;
        final mimeType = _getMimeType(media.path);

        final multipartFile = http.MultipartFile(
          'medias[]',
          stream,
          length,
          filename: filename,
          contentType: MediaType('image', mimeType),
        );
        request.files.add(multipartFile);
      }
    }

    final streamedResponse =
        await request.send().timeout(AppConfig.uploadTimeout);
    final response = await http.Response.fromStream(streamedResponse)
        .timeout(AppConfig.uploadTimeout);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body)['data'];
      return FeedbackModel.fromJson(jsonData);
    } else {
      final responseJson = jsonDecode(response.body);
      final errorMessage = responseJson['message'] ?? 'Terjadi kesalahan';

      if (response.statusCode == 422) {
        throw response;
      } else {
        throw Exception(errorMessage);
      }
    }
  }

  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'png';
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      default:
        return 'jpeg';
    }
  }
}
