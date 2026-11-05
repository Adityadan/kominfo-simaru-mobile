import 'package:simaru/models/schedule_model.dart';
import 'package:simaru/services/schedule_service.dart';
import 'package:flutter/material.dart';

class ScheduleProvider with ChangeNotifier {
  List<ScheduleModel> _schedule = [];
  List<ScheduleModel> get schedule => _schedule;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;
  String? _error;
  String? get error => _error;

  set schedule(List<ScheduleModel> schedule) {
    _schedule = schedule;
    _hasLoaded = true;
    _error = null;
    notifyListeners();
  }

  Future<void> schedules(
    String? token,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      List<ScheduleModel> schedule = await ScheduleService().schedule(token);
      _schedule = schedule;
      _hasLoaded = true;
    } catch (e) {
      _schedule = [];
      _hasLoaded = false;
      _error = 'Gagal memuat jadwal ruangan';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
