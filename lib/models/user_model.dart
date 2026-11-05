import 'member_model.dart';

class UserModel {
  int? id;
  String? token;
  String? name;
  String? email;
  String? phone;
  String? roles;
  String? photo;
  MemberModel? member;

  UserModel({
    this.token,
    this.id,
    this.name,
    this.email,
    this.phone,
    this.roles,
    this.photo,
    this.member,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      roles: json['roles']?.toString(),
      photo: json['photo']?.toString(),
      token: json['token']?.toString(),
      member: json['member'] != null ? MemberModel.fromJson(json['member']) : null,
    );
  }
}