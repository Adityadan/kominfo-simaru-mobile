class MemberModel {
  final int? id;
  final int? userId;
  final int? divisionId;
  final String? name;
  final String? gender;
  final String? address;
  final String? nip;
  final String? createdAt;
  final String? updatedAt;
  final dynamic deletedAt;

  MemberModel({
    this.id,
    this.userId,
    this.divisionId,
    this.name,
    this.gender,
    this.address,
    this.nip,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory MemberModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MemberModel();
    return MemberModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? ''),
      divisionId: json['division_id'] is int ? json['division_id'] : int.tryParse(json['division_id']?.toString() ?? ''),
      name: json['name']?.toString(),
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
      nip: json['nip']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      deletedAt: json['deleted_at'],
    );
  }
}
