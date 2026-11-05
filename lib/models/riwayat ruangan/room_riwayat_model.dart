class RoomRiwayatModel {
  int? id;
  String? name;
  int? floor;
  int? capacity;
  String? image;

  RoomRiwayatModel({
    this.id,
    this.name,
    this.floor,
    this.capacity,
    this.image,
  });

  RoomRiwayatModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
    floor = json['floor'] is int ? json['floor'] : int.tryParse(json['floor']?.toString() ?? '');
    capacity = json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity']?.toString() ?? '');
    image = json['image']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'floor': floor,
      'capacity': capacity,
      'image': image,
    };
  }
}
