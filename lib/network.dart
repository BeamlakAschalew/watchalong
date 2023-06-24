import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:watchalong/models/room.dart';

const secretKey = "niggapleasedontdoanything";

Future<Room?> onCreate(
    {required String roomName,
    required String createdBy,
    required int time,
    required String checksum}) async {
  Room? room;
  Map<String, dynamic> createRoomData = {
    "roomName": roomName,
    "createdBy": createdBy,
    "time": time,
    "checksum": checksum
  };

  var key = utf8.encode(secretKey);
  var bytes = utf8.encode(json.encode(createRoomData));

  var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
  var digest = hmacSha256.convert(bytes);
  print('digestttttttttttttttttttt ${digest.toString()}');

  try {
    var response = await http.post(
      Uri.parse('http://watchalong.doniverse.net/rooms/createroom'),
      body:
          'U2FsdGVkX18HiMnf97vV/phCj8hAq0IDRDYFxDpwg0GC2Cv+1FvoxaDhiUVjEpCP0xdEAsKaLanPKtxyXAZtlAPEJEPuP8PS0QAw1jOwB44oek02ZN9zJxnLEMHBNDJ1',
      headers: {
        "Content-Type": "text/plain",
      },
    );

    var roomData = json.decode(response.body);
    print('rooooooooooooooooooooooooooooom ${roomData}');
    room = Room.fromJson(roomData);
    return room;
  } catch (error) {
    print(error);
  }

  return null;
}
