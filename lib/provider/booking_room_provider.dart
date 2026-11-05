import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/booking_room_model.dart';
import '../services/booking_service.dart';

class BookingRoomProvider with ChangeNotifier {
  final BookingService _service;
  BookingRoomProvider({BookingService? service})
      : _service = service ?? BookingService();
  String? errorMessage;
  List<BookingRoomModel> _bookingroom = [];
  List<BookingRoomModel> get bookingroom => _bookingroom;

  Future<bool> bookingRoom({
    String? name,
    String? nip,
    int? roomid,
    int? devision,
    String? phone,
    String? description,
    String? participantInternal,
    String? participantExternal,
    String? startDate,
    String? endDate,
    String? attachment,
    Uint8List? attachmentBytes,
    String? attachmentName,
    String? participanttype,
    String? token,
  }) async {
    errorMessage = null;
    try {
      BookingRoomModel booking = await _service.booking(
        token: token,
        startdate: startDate,
        enddate: endDate,
        participanttype: participanttype,
        roomid: roomid,
        name: name,
        nip: nip,
        attachment: attachment,
        attachmentBytes: attachmentBytes,
        attachmentName: attachmentName,
        description: description,
        participantInternal: participantInternal,
        participantExternal: participantExternal,
        devision: devision,
        phone: phone,
      );

      _bookingroom = [booking];
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
