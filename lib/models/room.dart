class Room {
  Room(
      {required this.createdBy,
      required this.roomID,
      required this.roomName,
      required this.time,
      required this.checksum});

  String? roomID;
  String? roomName;
  String? createdBy;
  String? time;
  String? checksum;

  Room.fromJson(Map<String, dynamic> json) {
    createdBy = json['createdBy'];
    roomID = json['roomID'];
    roomName = json['roomName'];
    time = json['time'];
    checksum = json['checksum'];
  }
}
