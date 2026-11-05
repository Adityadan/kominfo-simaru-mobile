import 'package:simaru/models/pemesanan%20ruangan/ruangan_model.dart';
import 'package:flutter/material.dart';
import '../services/ruangan_service.dart';

class RuanganProvider with ChangeNotifier {
  List<RuanganModel> _ruangan = [];
  List<RuanganModel> get ruangan => _ruangan;
  String? _error;
  String? get error => _error;

  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  set ruangan(List<RuanganModel> ruangan) {
    _ruangan = ruangan;
    notifyListeners();
  }

  Future<void> bookingroom(int? id, String? token) async {
    try {
      List<RuanganModel> ruangan =
          await RuanganService().bookingroom(id, token);
      _ruangan = ruangan;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
