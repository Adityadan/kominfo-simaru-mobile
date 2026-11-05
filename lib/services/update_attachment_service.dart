import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:simaru/data/config.dart';
import 'package:simaru/models/update_model.dart';

class UpdateBookingAttachmentService {
  Future<UpdateBookingModel> updateBookingAttachment({
    int? bookingId,
    String? attachment,
    String? token,
    String uploadMode = 'raw',
  }) async {
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'apikey': AppConfig.apiKey,
    };

    String? attachmentUrl;

    if (uploadMode == 'raw' && attachment != null && attachment.isNotEmpty) {
      final file = File(attachment);
      final fileBytes = await file.readAsBytes();
      final filename = file.uri.pathSegments.last;

      final rawUploadResponse = await http
          .post(
            Uri.parse('$baseUrl/booking/upload-raw'),
            headers: {
              ...headers,
              'Content-Type': 'application/octet-stream',
              'X-Filename': filename,
            },
            body: fileBytes,
          )
          .timeout(AppConfig.uploadTimeout);
      if (rawUploadResponse.statusCode == 200) {
        final jsonData = jsonDecode(rawUploadResponse.body);
        attachmentUrl = jsonData['data']['url'];
        if (kDebugMode) {
          print('Attachment URL: $attachmentUrl');
        }
      } else {
        throw Exception(
            'Gagal upload file (raw): ${rawUploadResponse.statusCode} - ${rawUploadResponse.body}');
      }

      final body = jsonEncode({
        'attachment': attachmentUrl,
      });

      final response = await http
          .put(
            Uri.parse('$baseUrl/booking/$bookingId?_method=PUT'),
            headers: {
              ...headers,
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(AppConfig.requestTimeout);

      if (kDebugMode) {
        print('Response: ${response.statusCode} => ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = jsonDecode(response.body)['data'];
        return UpdateBookingModel.fromJson(data);
      } else {
        throw Exception(
            'Gagal update attachment (raw). Status code: ${response.statusCode}');
      }
    }

    final url = '$baseUrl/booking/$bookingId?_method=PUT';
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);

    if (attachment != null && attachment.isNotEmpty) {
      String ext = attachment.split('.').last.toLowerCase();
      String mimeType = _getMimeType(ext);
      List<String> parts = mimeType.split('/');

      request.files.add(await http.MultipartFile.fromPath(
        'attachment',
        attachment,
        contentType: MediaType(parts[0], parts[1]),
      ));
    }

    var response = await http.Response.fromStream(
      await request.send().timeout(AppConfig.uploadTimeout),
    ).timeout(AppConfig.uploadTimeout);

    if (kDebugMode) {
      print(response.body);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = jsonDecode(response.body)['data'];
      return UpdateBookingModel.fromJson(data);
    } else {
      throw Exception(
          'Failed to update booking attachment. Status code: ${response.statusCode}');
    }
  }

  String _getMimeType(String ext) {
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      default:
        return 'application/octet-stream';
    }
  }
}
