class RoomBooking {
  int? id;
  int? memberId;
  int? roomId;
  String? bookingDate;
  String? bookingStartDate;
  String? bookingEndDate;
  String? attachment;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? name;
  String? nip;
  String? phone;
  String? description;
  String? status;
  String? participantType;
  int? participantInternal;
  int? participantExternal;
  int? divisionId;
  Member? member;

  RoomBooking({
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
    this.participantInternal,
    this.participantExternal,
    this.divisionId,
    this.member,
  });

  factory RoomBooking.fromJson(Map<String, dynamic> json) {
    return RoomBooking(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      memberId: json['member_id'] is int ? json['member_id'] : int.tryParse(json['member_id']?.toString() ?? ''),
      roomId: json['room_id'] is int ? json['room_id'] : int.tryParse(json['room_id']?.toString() ?? ''),
      bookingDate: json['booking_date']?.toString(),
      bookingStartDate: json['booking_start_date']?.toString(),
      bookingEndDate: json['booking_end_date']?.toString(),
      attachment: json['attachment']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      name: json['name']?.toString(),
      nip: json['nip']?.toString(),
      phone: json['phone']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      participantType: json['participant_type']?.toString(),
      participantInternal: json['participant_internal'] is int
          ? json['participant_internal']
          : int.tryParse(json['participant_internal']?.toString() ?? ''),
      participantExternal: json['participant_external'] is int
          ? json['participant_external']
          : int.tryParse(json['participant_external']?.toString() ?? ''),
      divisionId: json['division_id'] is int ? json['division_id'] : int.tryParse(json['division_id']?.toString() ?? ''),
      member: json['member'] != null ? Member.fromJson(json['member']) : null,
    );
  }
}

class Member {
  int? id;
  int? userId;
  int? divisionId;
  String? name;
  String? gender;
  String? address;
  String? nip;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  Member({
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

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? ''),
      divisionId: json['division_id'] is int ? json['division_id'] : int.tryParse(json['division_id']?.toString() ?? ''),
      name: json['name']?.toString(),
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
      nip: json['nip']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      deletedAt: json['deleted_at'],
    );
  }
}

class RoomData {
  String? message;
  List<Room>? data;

  RoomData({this.message, this.data});

  factory RoomData.fromJson(Map<String, dynamic> json) {
    return RoomData(
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is List
          ? List<Room>.from((json['data'] as List).map((x) => Room.fromJson(x)))
          : [],
    );
  }
}

class Room {
  int? id;
  String? name;
  int? floor;
  int? capacity;
  String? image;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  List<Feedback>? feedbacks;
  List<RoomFacility>? roomFacilities;
  List<RoomBooking>? bookings;

  Room({
    this.id,
    this.name,
    this.floor,
    this.capacity,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.feedbacks,
    this.roomFacilities,
    this.bookings,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      floor: json['floor'] is int ? json['floor'] : int.tryParse(json['floor']?.toString() ?? ''),
      capacity: json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity']?.toString() ?? ''),
      image: json['image']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      deletedAt: json['deleted_at'],
      feedbacks: json['feedbacks'] != null && json['feedbacks'] is List
          ? List<Feedback>.from((json['feedbacks'] as List).map((x) => Feedback.fromJson(x)))
          : [],
      roomFacilities: json['room_facilities'] != null && json['room_facilities'] is List
          ? List<RoomFacility>.from((json['room_facilities'] as List).map((x) => RoomFacility.fromJson(x)))
          : [],
      bookings: json['bookings'] != null && json['bookings'] is List
          ? List<RoomBooking>.from((json['bookings'] as List).map((x) => RoomBooking.fromJson(x)))
          : [],
    );
  }
}

class Feedback {
  int? id;
  int? memberId;
  int? roomId;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  Feedback({
    this.id,
    this.memberId,
    this.roomId,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      memberId: json['member_id'] is int ? json['member_id'] : int.tryParse(json['member_id']?.toString() ?? ''),
      roomId: json['room_id'] is int ? json['room_id'] : int.tryParse(json['room_id']?.toString() ?? ''),
      description: json['description']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      deletedAt: json['deleted_at'],
    );
  }
}

class RoomFacility {
  int? roomId;
  int? facilityId;
  int? id;
  int? quantity;
  Facility? facility;

  RoomFacility({
    this.roomId,
    this.facilityId,
    this.id,
    this.quantity,
    this.facility,
  });

  factory RoomFacility.fromJson(Map<String, dynamic> json) {
    return RoomFacility(
      roomId: json['room_id'] is int ? json['room_id'] : int.tryParse(json['room_id']?.toString() ?? ''),
      facilityId: json['facility_id'] is int ? json['facility_id'] : int.tryParse(json['facility_id']?.toString() ?? ''),
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? ''),
      facility: json['facility'] != null ? Facility.fromJson(json['facility']) : null,
    );
  }
}

class Facility {
  int? id;
  String? name;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  Facility({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      deletedAt: json['deleted_at'],
    );
  }
}
