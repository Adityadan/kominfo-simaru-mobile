class FacilityModel {
  int? id;
  String? name;

  FacilityModel({
    this.id,
    this.name,
  });

  FacilityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
