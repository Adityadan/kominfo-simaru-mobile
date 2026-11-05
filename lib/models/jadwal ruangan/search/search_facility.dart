import 'package:simaru/models/facilty_model.dart';

class SearchFacilitiesModel {
  int? id;
  int? quantity;
  int? roomid;
  FacilityModel? facility;

  SearchFacilitiesModel({
    this.id,
    this.roomid,
    this.quantity,
    this.facility,
  });

  SearchFacilitiesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    roomid = json['room_id'] is int ? json['room_id'] : int.tryParse(json['room_id']?.toString() ?? '');
    quantity = json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '');
    facility = json['facility'] != null ? FacilityModel.fromJson(json['facility']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'room_id': roomid,
      'facility': facility?.toJson(),
    };
  }
}
