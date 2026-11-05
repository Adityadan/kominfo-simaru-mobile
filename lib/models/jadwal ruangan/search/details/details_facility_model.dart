import 'package:simaru/models/facilty_model.dart';

class DetailsFacilityModel {
  int? id;
  int? quantity;
  FacilityModel? facility;

  DetailsFacilityModel({
    this.id,
    this.quantity,
    this.facility,
  });

  DetailsFacilityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    quantity = json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '');
    facility = json['facility'] != null ? FacilityModel.fromJson(json['facility']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'facility': facility?.toJson(),
    };
  }
}
