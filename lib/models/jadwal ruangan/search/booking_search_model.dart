import '../../member_model.dart';

class BookingSearchModel {
  int? id;
  int? memberId;
  int? roomId;
  String? bookingDate;
  String? bookingStartDate;
  String? bookingEndDate;
  String? attachment;
  String? createdAt;
  String? updatedAt;
  String? name;
  String? nip;
  String? phone;
  String? description;
  String? status;
  String? participantType;
  int? particpant;
  int? divisionId;
  MemberModel? member;

  BookingSearchModel({
    this.id,
    this.memberId,
    this.roomId,
    this.bookingDate,
    this.bookingStartDate,
    this.bookingEndDate,
    this.attachment,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.nip,
    this.phone,
    this.description,
    this.status,
    this.participantType,
    this.particpant,
    this.divisionId,
    this.member,
  });

  factory BookingSearchModel.fromJson(Map<String, dynamic> json) {
    return BookingSearchModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      memberId: json['member_id'] is int ? json['member_id'] : int.tryParse(json['member_id']?.toString() ?? ''),
      roomId: json['room_id'] is int ? json['room_id'] : int.tryParse(json['room_id']?.toString() ?? ''),
      bookingDate: json['booking_date']?.toString(),
      bookingStartDate: json['booking_start_date']?.toString(),
      bookingEndDate: json['booking_end_date']?.toString(),
      attachment: json['attachment']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      name: json['name']?.toString(),
      nip: json['nip']?.toString(),
      phone: json['phone']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      participantType: json['participant_type']?.toString(),
      particpant: json['participant'] is int ? json['participant'] : int.tryParse(json['participant']?.toString() ?? ''),
      divisionId: json['division_id'] is int ? json['division_id'] : int.tryParse(json['division_id']?.toString() ?? ''),
      member: json['member'] != null ? MemberModel.fromJson(json['member']) : null,
    );
  }
}
