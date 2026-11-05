import 'package:simaru/models/booking_model.dart';
import 'package:simaru/models/facilities_model.dart';

class ScheduleModel {
  int? id;
  String? name;
  String? floor;
  String? capacity;
  String? image;
  List<FacilitiesModel>? facilities;
  List<BookingModel>? bookings;

  ScheduleModel({
    this.id,
    this.name,
    this.floor,
    this.capacity,
    this.image,
    this.bookings,
    this.facilities,
  });

  List<BookingModel> visibleBookingsAt(DateTime now) {
    final entries = (bookings ?? <BookingModel>[])
        .where((booking) =>
            (booking.idRoom == null || booking.idRoom == id?.toString()) &&
            booking.roomSchedulePhaseAt(now) != null)
        .toList();
    entries.sort((a, b) {
      final start = a.startsAt!.compareTo(b.startsAt!);
      if (start != 0) return start;
      final end = a.endsAt!.compareTo(b.endsAt!);
      return end != 0 ? end : (a.id ?? 0).compareTo(b.id ?? 0);
    });
    return entries;
  }

  ScheduleModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int
        ? json['id']
        : int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
    floor = json['floor']?.toString();
    image = json['image']?.toString();
    capacity = json['capacity']?.toString();
    if (json['room_facilities'] != null && json['room_facilities'] is List) {
      facilities = List<FacilitiesModel>.from((json['room_facilities'] as List)
          .map((roomfacility) => FacilitiesModel.fromJson(roomfacility)));
    } else {
      facilities = [];
    }

    final bookingData =
        json['bookings'] is Map ? json['bookings']['data'] : json['bookings'];
    if (bookingData is List) {
      bookings = List<BookingModel>.from(
          bookingData.map((booking) => BookingModel.fromJson(booking)));
    } else {
      bookings = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['floor'] = floor;
    data['image'] = image;
    data['capacity'] = capacity;
    data['room_facilities'] =
        facilities?.map((facility) => facility.toJson()).toList();
    data['bookings'] = bookings?.map((booking) => booking.toJson()).toList();
    return data;
  }
}
