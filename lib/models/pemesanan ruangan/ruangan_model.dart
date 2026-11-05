import 'booking_fasilitias_model.dart';

class RuanganModel {
  int? id;
  String? name;
  int? floor;
  int? capacity;
  String? image;
  List<RoomFacilitiesModel>? roomFacilities;

  RuanganModel({
    this.id,
    this.name,
    this.floor,
    this.capacity,
    this.image,
    this.roomFacilities,
  });

  factory RuanganModel.fromJson(Map<String, dynamic> json) {
    return RuanganModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      floor: json['floor'] is int ? json['floor'] : int.tryParse(json['floor']?.toString() ?? ''),
      capacity: json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity']?.toString() ?? ''),
      image: json['image']?.toString(),
      roomFacilities: json['room_facilities'] != null && json['room_facilities'] is List
          ? List<RoomFacilitiesModel>.from(
              (json['room_facilities'] as List).map(
                  (facilities) => RoomFacilitiesModel.fromJson(facilities)),
            )
          : [],
    );
  }
}
