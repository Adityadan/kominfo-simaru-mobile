class UpdateBookingModel {
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
  int? participantInternal;
  int? participantExternal;
  int? devisi;
  String? participanttype;
  String? attachment;

  UpdateBookingModel({
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

  UpdateBookingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    idRoom = json['room_id'] is int ? json['room_id'] : int.tryParse(json['room_id']?.toString() ?? '');
    idMember = json['member_id'] is int ? json['member_id'] : int.tryParse(json['member_id']?.toString() ?? '');
    bookingStartDate = json['booking_start_date'];
    bookingEndDate = json['booking_end_date'];
    name = json['name'];
    nip = json['nip'];
    phone = json['phone'];
    status = json['status'];
    participanttype = json['participant_type'];
    description = json['description'];
    participantInternal = json['participant_internal'] is int
        ? json['participant_internal']
        : int.tryParse(json['participant_internal']?.toString() ?? '');
    participantExternal = json['participant_external'] is int
        ? json['participant_external']
        : int.tryParse(json['participant_external']?.toString() ?? '');
    devisi = json['division_id'] is int ? json['division_id'] : int.tryParse(json['division_id']?.toString() ?? '');
    attachment = json['attachment'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nip': nip,
      'phone': phone,
      'booking_start_date': bookingStartDate,
      'booking_end_date': bookingEndDate,
      'participant_internal': participantInternal,
      'participant_external': participantExternal,
      'status': status,
      'description': description,
      'member_id': idMember,
      'participant_type': participanttype,
      'division_id': devisi,
      'attachment': attachment,
    };
  }
}
