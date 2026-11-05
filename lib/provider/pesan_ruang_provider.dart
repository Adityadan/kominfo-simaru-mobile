import 'package:simaru/models/pemesanan%20ruangan/ruangan_model.dart';
import 'package:flutter/material.dart';

import '../services/pemesanan_room_service.dart';

class PesanRuangProvider with ChangeNotifier {
  List<RuanganModel> _ruangan = [];
  List<RuanganModel> get ruangan => _ruangan;
  String? _error;
  String? get error => _error;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;

  set ruangan(List<RuanganModel> ruangan) {
    _ruangan = ruangan;
    _hasLoaded = true;
    _error = null;
    notifyListeners();
  }

  Future<void> bookingroom(int? id, String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      List<RuanganModel> ruangan =
          await PemesananRoomService().bookingroom(id, token);
      _ruangan = ruangan;
      _hasLoaded = true;
    } catch (e) {
      _ruangan = [];
      _hasLoaded = false;
      _error = 'Gagal memuat daftar ruangan';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
