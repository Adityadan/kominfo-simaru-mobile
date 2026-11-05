class MediasModel {
  int? id;
  String? attachment;

  MediasModel({
    this.id,
    this.attachment,
  });

  MediasModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    attachment = json['attachment']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attachment': attachment,
    };
  }
}
