import 'package:flutter/material.dart';
import '../models/update_model.dart';
import '../services/update_attachment_service.dart';

class UpdateProvider with ChangeNotifier {
  List<UpdateBookingModel> _bookingroom = [];
  List<UpdateBookingModel> get bookingroom => _bookingroom;

  Future<bool> updateAttachment({
    int? id,
    String? attachment,
    String? token,
  }) async {
    try {
      UpdateBookingModel updatedBooking =
          await UpdateBookingAttachmentService().updateBookingAttachment(
        bookingId: id,
        token: token,
        attachment: attachment,
      );
      _bookingroom = [updatedBooking];
      notifyListeners();
      return true;
    } catch (error) {
      print('Provider updateAttachment error: $error');
      return false;
    }
  }
}
