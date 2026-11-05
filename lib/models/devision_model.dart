class DevisionModel {
  final int? id;
  final String? name;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  DevisionModel({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory DevisionModel.fromJson(Map<String, dynamic> json) {
    return DevisionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
    );
  }
}
