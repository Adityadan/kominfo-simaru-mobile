import 'package:simaru/models/jadwal%20ruangan/search/search_facility.dart';
import 'booking_search_model.dart';

class SearchModel {
  int? id;
  String? name;
  int? floor;
  int? capacity;
  String? image;
  List<BookingSearchModel>? booking;
  List<SearchFacilitiesModel>? facilities;

  SearchModel({
    this.id,
    this.name,
    this.floor,
    this.capacity,
    this.image,
    this.booking,
    this.facilities,
  });

  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      floor: json['floor'] is int ? json['floor'] : int.tryParse(json['floor']?.toString() ?? ''),
      capacity: json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity']?.toString() ?? ''),
      image: json['image']?.toString(),
      facilities: json['room_facilities'] != null && json['room_facilities'] is List
          ? List<SearchFacilitiesModel>.from(
              (json['room_facilities'] as List).map(
                  (facilities) => SearchFacilitiesModel.fromJson(facilities)),
            )
          : [],
      booking: json['bookings'] != null && json['bookings'] is List
          ? List<BookingSearchModel>.from(
              (json['bookings'] as List)
                  .map((bookings) => BookingSearchModel.fromJson(bookings)),
            )
          : [],
    );
  }
}
