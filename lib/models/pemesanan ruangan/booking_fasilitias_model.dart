import 'objek_facility_model.dart';

class RoomFacilitiesModel {
  int? roomId;
  int? facilityId;
  int? id;
  int? quantity;
  ObjectFacilityModel? facility;

  RoomFacilitiesModel({
    this.roomId,
    this.facilityId,
    this.id,
    this.quantity,
    this.facility,
  });

  factory RoomFacilitiesModel.fromJson(Map<String, dynamic> json) {
    return RoomFacilitiesModel(
      roomId: json['room_id'] is int ? json['room_id'] : int.tryParse(json['room_id']?.toString() ?? ''),
      facilityId: json['facility_id'] is int ? json['facility_id'] : int.tryParse(json['facility_id']?.toString() ?? ''),
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? ''),
      facility: json['facility'] != null ? ObjectFacilityModel.fromJson(json['facility']) : null,
    );
  }
}
