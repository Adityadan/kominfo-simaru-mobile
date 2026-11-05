import 'package:simaru/models/riwayat%20ruangan/riwayat_model.dart';
import 'package:simaru/services/riwayat_service.dart';
import 'package:flutter/material.dart';

class RiwayatProvider with ChangeNotifier {
  List<RiwayatModel> _notifs = [];
  List<RiwayatModel> get notif => _notifs;
  String? _error;
  String? get error => _error;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;

  set notif(List<RiwayatModel> notif) {
    _notifs = notif;
    _hasLoaded = true;
    _error = null;
    notifyListeners();
  }

  Future<void> notifacation(String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      List<RiwayatModel> notif = await RiwayatService().notification(token);
      _notifs = notif;
      _hasLoaded = true;
    } catch (e) {
      _notifs = [];
      _hasLoaded = false;
      _error = 'Gagal memuat riwayat pemesanan';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
