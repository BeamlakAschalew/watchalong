import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:watchalong/constants/app_constants.dart';
import 'package:watchalong/models/room.dart';

const secretKey = "niggapleasedontdoanything";

Future<Room?> onCreate(
    {required String roomName,
    required String createdBy,
    required int time,
    required String checksum}) async {
  Room? room;

  try {
    var response = await retryOptions.retry(
      () => http.get(
        Uri.parse(
            'http://watchalong.doniverse.net/rooms/createroom/$roomName/$time/$createdBy/$checksum'),
      ),
      retryIf: (p0) => p0 is SocketException || p0 is TimeoutException,
    );
    print(
        'requesttttttttttttttt http://watchalong.doniverse.net/rooms/createroom/$roomName/$time/$createdBy/$checksum');

    var roomData = json.decode(response.body);
    print('rd: $roomData');
    room = Room.fromJson(roomData);
  } finally {
    client.close();
  }

  return room;
}

Future<Room?> onJoin(
    {required String roomID,
    required String createdBy,
    required int time,
    required String checksum}) async {
  Room? room;

  try {
    var response = await http.get(Uri.parse(
      ('http://watchalong.doniverse.net/rooms/joinroom/$roomID/$createdBy/$time/$checksum'),
    ));
    print(
        'requesttttttttttttttt http://watchalong.doniverse.net/rooms/joinroom/$roomID/$createdBy/$time/$checksum');

    var roomData = json.decode(response.body);
    room = Room.fromJson(roomData);
    print('rd: $roomData');
    return room;
  } catch (error) {
    print(error);
  }

  return null;
}
