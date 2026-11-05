class BookingRoomModel {
  int? id;
  int? idRoom;
  int? idMember;
  DateTime? bookingDate;
  String? status;
  String? bookingStartDate;
  String? bookingEndDate;
  String? name;
  String? nip;
  String? phone;
  String? description;
  String? participantInternal;
  String? participantExternal;
  int? devisi;
  String? participanttype;
  String? attachment;

  BookingRoomModel({
    this.id,
    this.idRoom,
    this.idMember,
    this.bookingDate,
    this.bookingEndDate,
    this.bookingStartDate,
    this.name,
    this.nip,
    this.status,
    this.phone,
    this.participanttype,
    this.description,
    this.participantInternal,
    this.participantExternal,
    this.devisi,
    this.attachment,
  });

  BookingRoomModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int
        ? json['id']
        : int.tryParse(json['id']?.toString() ?? '');
    idRoom = json['room_id'] is int
        ? json['room_id']
        : int.tryParse(json['room_id']?.toString() ?? '');
    idMember = json['member_id'] is int
        ? json['member_id']
        : int.tryParse(json['member_id']?.toString() ?? '');
    bookingStartDate = json['start_date'] ?? json['booking_start_date'];
    bookingEndDate = json['end_date'] ?? json['booking_end_date'];
    name = json['name'];
    nip = json['nip'];
    phone = json['phone'];
    status = json['status'];
    participanttype = json['participant_type'];
    description = json['description'];
    participantInternal = json['participant_internal']?.toString();
    participantExternal = json['participant_external']?.toString();
    devisi = json['division_id'] is int
        ? json['division_id']
        : int.tryParse(json['division_id']?.toString() ?? '');
    attachment = json['attachment'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nip': nip,
      'phone': phone,
      'start_date': bookingStartDate,
      'end_date': bookingEndDate,
      'participant_internal': participantInternal,
      'participant_external': participantExternal,
      'status': status,
      'description': description,
      'member_id': idMember,
      'room_id': idRoom,
      'participant_type': participanttype,
      'division_id': devisi,
      'attachment': attachment,
    };
  }
}
