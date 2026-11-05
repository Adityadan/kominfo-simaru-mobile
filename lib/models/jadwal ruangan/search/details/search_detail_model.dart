import 'package:simaru/models/booking_model.dart';
import 'package:simaru/models/jadwal%20ruangan/search/details/details_facility_model.dart';

class SearchModelDetails {
  int? id;
  String? name;
  int? floor;
  int? capacity;
  String? image;
  List<DetailsFacilityModel>? facilities;
  List<BookingModel>? bookings;

  SearchModelDetails({
    this.id,
    this.name,
    this.floor,
    this.capacity,
    this.image,
    this.bookings,
    this.facilities,
  });

  SearchModelDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
    floor = json['floor'] is int ? json['floor'] : int.tryParse(json['floor']?.toString() ?? '');
    image = json['image']?.toString();
    capacity = json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity']?.toString() ?? '');
    if (json['room_facilities'] != null && json['room_facilities'] is List) {
      facilities = List<DetailsFacilityModel>.from((json['room_facilities'] as List)
          .map((roomfacility) => DetailsFacilityModel.fromJson(roomfacility)));
    } else {
      facilities = [];
    }

    if (json['bookings'] != null && json['bookings'] is List) {
      bookings = List<BookingModel>.from(
          (json['bookings'] as List).map((booking) => BookingModel.fromJson(booking)));
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
    data['bookings'] =
        bookings?.map((booking) => booking.toJson()).toList();
    return data;
  }
}
