import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:watchalong/models/room.dart';

const secretKey = "niggapleasedontdoanything";

Future<Room?> onCreate(
    {required String roomName,
    required String createdBy,
    required int time,
    required String checksum}) async {
  Room? room;

  try {
    var response = await http.get(
      Uri.parse(
          'http://watchalong.doniverse.net/rooms/createroom/$roomName/$time/$createdBy/$checksum'),
    );
    print(
        'requesttttttttttttttt http://watchalong.doniverse.net/rooms/createroom/$roomName/$time/$createdBy/$checksum');

    var roomData = json.decode(response.body);
    room = Room.fromJson(roomData);
    return room;
  } catch (error) {
    print(error);
  }

  return null;
}
