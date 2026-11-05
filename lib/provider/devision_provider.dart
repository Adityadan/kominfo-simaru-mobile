import 'package:flutter/foundation.dart';
import '../models/devision_model.dart';
import '../services/devision_service.dart';

class DivisionDetailsProvider with ChangeNotifier {
  final DivisionDetailsService _service = DivisionDetailsService();

  DevisionModel? _devision;
  DevisionModel? get devision => _devision;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadDevision({
    int? id,
    String? token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _devision = await _service.fetchDevisionDetail(id: id, token: token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
