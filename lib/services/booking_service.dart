import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import 'package:simaru/data/config.dart';
import 'package:simaru/models/booking_room_model.dart';

const maxBookingAttachmentBytes = 5 * 1024 * 1024;

MediaType bookingAttachmentType(String filename) {
  final extension = filename.split('.').last.toLowerCase();
  return switch (extension) {
    'pdf' => MediaType('application', 'pdf'),
    'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
    'png' => MediaType('image', 'png'),
    'doc' => MediaType('application', 'msword'),
    'docx' => MediaType('application',
        'vnd.openxmlformats-officedocument.wordprocessingml.document'),
    'xls' => MediaType('application', 'vnd.ms-excel'),
    'xlsx' => MediaType(
        'application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
    'ppt' => MediaType('application', 'vnd.ms-powerpoint'),
    'pptx' => MediaType('application',
        'vnd.openxmlformats-officedocument.presentationml.presentation'),
    _ => MediaType('application', 'octet-stream'),
  };
}

class BookingService {
  final http.Client? client;
  BookingService({this.client});
  Future<http.Response> _post(Uri uri,
          {Map<String, String>? headers, Object? body}) =>
      (client != null
              ? client!.post(uri, headers: headers, body: body)
              : http.post(uri, headers: headers, body: body))
          .timeout(const Duration(seconds: 30));
  Future<BookingRoomModel> booking({
    String? startdate,
    String? enddate,
    String? token,
    String? name,
    String? nip,
    String? phone,
    int? devision,
    int? roomid,
    String? participantInternal,
    String? participantExternal,
    String? participanttype,
    String? attachment,
    Uint8List? attachmentBytes,
    String? attachmentName,
    String? description,
    String uploadMode =
        'default', // Multipart; raw hanya jika diminta eksplisit.
  }) async {
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'apikey': AppConfig.apiKey,
    };

    final bytes = attachmentBytes ??
        (attachment != null ? await File(attachment).readAsBytes() : null);
    final filename =
        attachmentName ?? attachment?.replaceAll('\\', '/').split('/').last;
    if (bytes == null ||
        bytes.isEmpty ||
        filename == null ||
        filename.isEmpty) {
      throw Exception('Lampiran wajib diunggah sebelum memesan ruangan.');
    }
    if (bytes.length >= maxBookingAttachmentBytes) {
      throw Exception('Ukuran lampiran harus kurang dari 5 MB.');
    }
    if (uploadMode != 'raw' && uploadMode != 'default') {
      throw Exception('Mode upload tidak didukung.');
    }
    String? attachmentUrl;

    // --- MODE RAW: Upload file terpisah ke /upload-raw ---
    if (uploadMode == 'raw') {
      final rawUploadResponse = await _post(
        Uri.parse('$baseUrl/booking/upload-raw'),
        headers: {
          ...headers,
          'Content-Type': 'application/octet-stream',
          'X-Filename': filename,
        },
        body: bytes,
      );
      final uploadData = _data(rawUploadResponse);
      final url = uploadData is Map ? uploadData['url'] : null;
      if (url is! String || url.isEmpty) {
        throw Exception('Upload gagal: URL lampiran tidak tersedia.');
      }
      attachmentUrl = url;
    }

    // --- Kirim data booking ---
    if (uploadMode == 'default') {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/booking'),
      )
        ..headers.addAll(headers)
        ..fields['start_date'] = startdate ?? ''
        ..fields['end_date'] = enddate ?? ''
        ..fields['name'] = name ?? ''
        ..fields['room_id'] = roomid?.toString() ?? ''
        ..fields['division_id'] = devision?.toString() ?? ''
        ..fields['nip'] = nip ?? ''
        ..fields['phone'] = phone ?? ''
        ..fields['description'] = description ?? ''
        ..fields['participant_internal'] =
            (participantInternal != null && participantInternal.isNotEmpty)
                ? participantInternal
                : '0'
        ..fields['participant_external'] =
            (participantExternal != null && participantExternal.isNotEmpty)
                ? participantExternal
                : '0'
        ..fields['participant_type'] = participanttype ?? '';

      request.files.add(http.MultipartFile.fromBytes('attachment', bytes,
          filename: filename, contentType: bookingAttachmentType(filename)));
      final streamedResponse =
          await (client != null ? client!.send(request) : request.send())
              .timeout(AppConfig.uploadTimeout);
      final response = await http.Response.fromStream(streamedResponse)
          .timeout(AppConfig.uploadTimeout);
      return _handleResponse(response);
    } else {
      final body = jsonEncode({
        'start_date': startdate,
        'end_date': enddate,
        'name': name,
        'nip': nip,
        'phone': phone,
        'room_id': roomid,
        'division_id': devision,
        'description': description,
        'participant_internal':
            (participantInternal != null && participantInternal.isNotEmpty)
                ? participantInternal
                : '0',
        'participant_external':
            (participantExternal != null && participantExternal.isNotEmpty)
                ? participantExternal
                : '0',
        'participant_type': participanttype,
        'attachment': attachmentUrl,
      });

      final response = await _post(
        Uri.parse('$baseUrl/booking'),
        headers: {
          ...headers,
          'Content-Type': 'application/json',
        },
        body: body,
      );

      return _handleResponse(response);
    }
  }

  dynamic _data(http.Response response) {
    if (response.statusCode == 413) {
      throw Exception(
          'Server menolak ukuran unggahan (HTTP 413), meskipun berkas di bawah 5 MB. Batas unggah pada server perlu diperiksa.');
    }
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Respons server tidak valid (${response.statusCode}).');
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        (body is Map && body['success'] == false)) {
      final errors = body is Map ? body['errors'] : null;
      if (errors is Map && errors.isNotEmpty) {
        throw Exception(errors.values
            .map((e) => e is List ? e.join('\n') : e.toString())
            .join('\n'));
      }
      throw Exception(body is Map
          ? body['message'] ?? 'Permintaan gagal.'
          : 'Permintaan gagal.');
    }
    return body is Map ? body['data'] : null;
  }

  BookingRoomModel _handleResponse(http.Response response) {
    final data = _data(response);
    if (data is! Map<String, dynamic>) {
      throw Exception('Format hasil booking tidak sesuai.');
    }
    return BookingRoomModel.fromJson(data);
  }
}
