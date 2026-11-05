import 'package:simaru/models/riwayat%20ruangan/room_riwayat_model.dart';

class RiwayatModel {
  int? idBooking;
  int? idMember;
  int? idRoom;
  String? bookingDate;
  String? bookingStartDate;
  String? bookingEndDate;
  String? attachment;
  String? name;
  String? nip;
  String? phone;
  String? description;
  String? status;
  String? participantType;
  int? participantInternal;
  int? participantExternal;
  int? devisi;
  String? divisionName;
  RoomRiwayatModel? room;

  RiwayatModel({
    this.idBooking,
    this.idMember,
    this.idRoom,
    this.bookingDate,
    this.bookingStartDate,
    this.bookingEndDate,
    this.attachment,
    this.name,
    this.nip,
    this.phone,
    this.description,
    this.status,
    this.participantInternal,
    this.participantType,
    this.participantExternal,
    this.devisi,
    this.divisionName,
    this.room,
  });

  RiwayatModel.fromJson(Map<String, dynamic> json) {
    idBooking = json['booking_id'] is int
        ? json['booking_id']
        : int.tryParse(json['booking_id']?.toString() ?? '');
    idRoom = json['room_id'] is int
        ? json['room_id']
        : int.tryParse(json['room_id']?.toString() ?? '');
    idMember = json['member_id'] is int
        ? json['member_id']
        : int.tryParse(json['member_id']?.toString() ?? '');
    bookingDate = json['booking_date']?.toString();
    bookingStartDate =
        (json['booking_start_date'] ?? json['start_date'])?.toString();
    bookingEndDate = (json['booking_end_date'] ?? json['end_date'])?.toString();
    attachment = json['attachment']?.toString();
    name = json['name']?.toString();
    nip = json['nip']?.toString();
    phone = json['phone']?.toString();
    description = json['description']?.toString();
    status = json['status']?.toString();
    participantType = json['participant_type']?.toString();
    participantInternal = json['participant_internal'] is int
        ? json['participant_internal']
        : int.tryParse(json['participant_internal']?.toString() ?? '');
    participantExternal = json['participant_external'] is int
        ? json['participant_external']
        : int.tryParse(json['participant_external']?.toString() ?? '');
    devisi = json['division_id'] is int
        ? json['division_id']
        : int.tryParse(json['division_id']?.toString() ?? '');
    idBooking ??= int.tryParse(json['id']?.toString() ?? '');
    final division = json['division'];
    divisionName =
        (json['division_name'] ?? (division is Map ? division['name'] : null))
            ?.toString();
    room =
        json['room'] != null ? RoomRiwayatModel.fromJson(json['room']) : null;
  }

  String get statusLabel => switch (status) {
        'PENDING' => 'Menunggu',
        'APPROVED' => 'Disetujui',
        'DONE' => 'Selesai',
        'CANCELED' || 'CANCELLED' => 'Dibatalkan',
        'REJECTED' => 'Ditolak',
        _ => status ?? '-',
      };

  bool get canUpdateAttachment {
    final start = DateTime.tryParse(bookingStartDate ?? '');
    return idBooking != null &&
        (status == 'PENDING' || status == 'APPROVED') &&
        start != null &&
        DateTime.now().isBefore(start);
  }

  bool get canReview {
    return idBooking != null && status == 'DONE';
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': idBooking,
      'member_id': idMember,
      'room_id': idRoom,
      'name': name,
      'nip': nip,
      'phone': phone,
      'status': status,
      'booking_date': bookingDate,
      'booking_start_date': bookingStartDate,
      'booking_end_date': bookingEndDate,
      'participant_type': participantType,
      'participant_internal': participantInternal,
      'participant_external': participantExternal,
      'attachment': attachment,
      'description': description,
      'division_id': devisi,
      'division_name': divisionName,
      'room': room?.toJson(),
    };
  }
}
