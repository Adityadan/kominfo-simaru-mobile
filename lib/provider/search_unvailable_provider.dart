import 'package:flutter/material.dart';
import 'package:simaru/services/search_unvailaible_service.dart';

import '../models/jadwal ruangan/search/search_model.dart';

class SearchUnvailableProvider with ChangeNotifier {
  List<SearchModel> _searchunvailable = [];
  List<SearchModel> get searchunvailable => _searchunvailable;

  Future<bool> searchunvailableroom({
    String? search,
    String? token,
  }) async {
    try {
      List<SearchModel> searchunvailableroom = await SearchUnvailableService().searchunvailableroom(
        token: token,
        search: search,
      );
      _searchunvailable = searchunvailableroom;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
