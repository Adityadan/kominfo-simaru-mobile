enum RoomSchedulePhase { finished, ongoing, upcoming }

class BookingModel {
  int? id;
  String? idRoom;
  String? idMember;
  DateTime? bookingDate;
  String? bookingStartDate;
  String? bookingEndDate;
  String? status;
  String? name;
  String? nip;
  String? phone;
  String? description;
  int? participant;
  int? participantInternal;
  int? participantExternal;
  DateTime? completedAt;
  int? devisi;

  BookingModel({
    this.id,
    this.idRoom,
    this.idMember,
    this.bookingDate,
    this.bookingEndDate,
    this.bookingStartDate,
    this.status,
    this.name,
    this.nip,
    this.phone,
    this.description,
    this.participant,
    this.participantInternal,
    this.participantExternal,
    this.completedAt,
    this.devisi,
  });

  BookingModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse((json['booking_id'] ?? json['id'])?.toString() ?? '');
    idRoom = json['room_id']?.toString();
    idMember = json['member_id']?.toString();
    bookingDate = json['booking_date'] != null
        ? DateTime.tryParse(json['booking_date'])
        : null;
    bookingStartDate =
        (json['booking_start_date'] ?? json['start_date'])?.toString();
    bookingEndDate = (json['booking_end_date'] ?? json['end_date'])?.toString();
    status = json['status']?.toString();
    name = json['name'];
    nip = json['nip'];
    phone = json['phone'];
    description = json['description'];
    participant = json['participant'] is int
        ? json['participant']
        : int.tryParse(json['participant']?.toString() ?? '');
    participantInternal =
        int.tryParse(json['participant_internal']?.toString() ?? '');
    participantExternal =
        int.tryParse(json['participant_external']?.toString() ?? '');
    completedAt = DateTime.tryParse(
            (json['completed_at'] ?? json['finished_at'] ?? json['updated_at'])
                    ?.toString() ??
                '')
        ?.toLocal();
    devisi = json['division_id'] is int
        ? json['division_id']
        : int.tryParse(json['division_id']?.toString() ?? '');
  }

  DateTime? get startsAt =>
      DateTime.tryParse(bookingStartDate ?? '')?.toLocal();
  DateTime? get endsAt => DateTime.tryParse(bookingEndDate ?? '')?.toLocal();

  int? get totalParticipants =>
      participantInternal != null || participantExternal != null
          ? (participantInternal ?? 0) + (participantExternal ?? 0)
          : participant;

  RoomSchedulePhase? roomSchedulePhaseAt(DateTime now) {
    final start = startsAt;
    final end = endsAt;
    final normalizedStatus = status?.trim().toUpperCase();
    final done = normalizedStatus == 'DONE';
    if ((!done && normalizedStatus != 'APPROVED') ||
        start == null ||
        end == null ||
        !end.isAfter(start)) {
      return null;
    }
    if (done || !end.isAfter(now)) {
      // DONE can finish a booking before its reserved end time.
      final finished = done && completedAt != null
          ? completedAt!
          : end.isAfter(now)
              ? start
              : end.subtract(const Duration(microseconds: 1));
      final expires = DateTime(finished.year, finished.month, finished.day + 1);
      return now.isBefore(expires) ? RoomSchedulePhase.finished : null;
    }
    return now.isBefore(start)
        ? RoomSchedulePhase.upcoming
        : RoomSchedulePhase.ongoing;
  }

  bool isScheduledAt(DateTime now) {
    final start = startsAt;
    final end = endsAt;
    return status?.toUpperCase() == 'APPROVED' &&
        start != null &&
        end != null &&
        end.isAfter(start) &&
        end.isAfter(now);
  }

  bool isActiveAt(DateTime now) {
    final start = startsAt;
    return isScheduledAt(now) && start != null && !start.isAfter(now);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nip': nip,
      'phone': phone,
      'booking_start_date': bookingStartDate,
      'booking_end_date': bookingEndDate,
      'participant': participant,
      'description': description,
      'member_id': idMember,
      'division_id': devisi,
    };
  }
}
