import 'dart:io';
import 'package:simaru/services/feedback_service.dart';
import 'package:simaru/models/feedback_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedbackProvider with ChangeNotifier {
  FeedbackModel? _feedback;
  String? _responseBody;
  String? _errorMessage;

  FeedbackModel? get followup => _feedback;
  String? get responseBody => _responseBody;
  String? get errorMessage => _errorMessage;

  set followup(FeedbackModel? followup) {
    _feedback = followup;
    notifyListeners();
  }

  Future<bool> feedback({
    String? bookingId,
    String? description,
    List<File>? mediaList,
    String? token,
  }) async {
    try {
      _errorMessage = null;
      FeedbackModel feedback = await FeedbackService().feedback(
        token: token,
        bookingId: bookingId,
        description: description,
        mediaList: mediaList,
      );

      _feedback = feedback;
      _responseBody = feedback.toString();
      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      if (e is http.Response) {
        try {
          final body = jsonDecode(e.body);
          if (body['errors'] != null) {
            final errors = body['errors'] as Map<String, dynamic>;
            _errorMessage = errors.values
                .map((value) => (value as List).join(', '))
                .join('\n');
          } else {
            _errorMessage = body['message'] ?? 'Terjadi kesalahan.';
          }
        } catch (_) {
          _errorMessage = 'Gagal mengurai pesan kesalahan dari server.';
        }
      } else {
        _errorMessage = e.toString().replaceFirst('Exception: ', '').trim();
      }
      notifyListeners();

      return false;
    }
  }
}
