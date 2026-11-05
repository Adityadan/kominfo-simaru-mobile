import 'package:simaru/models/schedule_model.dart';
import 'package:simaru/services/scheduledetails_service.dart';
import 'package:flutter/material.dart';

class ScheduleDetailsProvider with ChangeNotifier {
  ScheduleModel? _schedule;

  ScheduleModel? get schedule => _schedule;

  set schedule(ScheduleModel? schedule) {
    _schedule = schedule;
    notifyListeners();
  }

  Future<void> schedules(int? id, String? token) async {
    try {
      ScheduleModel schedule =
          await ScheduleDetailsService().schedule(id, token);
      _schedule = schedule;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
