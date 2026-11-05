import 'package:simaru/services/search_room_service.dart';
import 'package:flutter/material.dart';

import '../models/jadwal ruangan/search/search_model.dart';

class SearchProvider with ChangeNotifier {
  List<SearchModel> _search = [];
  List<SearchModel> get search => _search;

  Future<bool> searchroom({
    String? startDate,
    String? endDate,
    String? token,
  }) async {
    try {
      List<SearchModel> searchroom = await SearchService().searchroom(
        token: token,
        startdate: startDate,
        enddate: endDate,
      );
      _search = searchroom;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
