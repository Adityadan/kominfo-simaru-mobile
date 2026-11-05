class ObjectFacilityModel {
  int? id;
  String? name;

  ObjectFacilityModel({
    this.id,
    this.name,
  });

  factory ObjectFacilityModel.fromJson(Map<String, dynamic> json) {
    return ObjectFacilityModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
    );
  }
}
