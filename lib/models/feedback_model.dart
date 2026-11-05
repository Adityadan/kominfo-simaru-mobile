import 'package:simaru/models/media_model.dart';

class FeedbackModel {
  int? id;
  String? bookingId;
  String? description;
  List<MediasModel>? medias;

  FeedbackModel({this.id, this.bookingId, this.description, this.medias});

  FeedbackModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    bookingId = json['booking_id']?.toString();
    description = json['description']?.toString();
    if (json['medias'] != null && json['medias'] is List) {
      medias = (json['medias'] as List)
          .map((v) => MediasModel.fromJson(v))
          .toList();
    } else {
      medias = [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'description': description,
      'medias': medias?.map((media) => media.toJson()).toList()
    };
  }
}
