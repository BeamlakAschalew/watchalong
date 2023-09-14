import 'dart:io';
import 'package:better_player/better_player.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:watchalong/network.dart';
import 'package:watchalong/ui/videos.dart';

import '../constants/app_constants.dart';
import '../models/room.dart';
import '../services/global_method.dart';

class CreateARoom extends StatefulWidget {
  const CreateARoom({super.key});

  @override
  State<CreateARoom> createState() => _CreateARoomState();
}

class _CreateARoomState extends State<CreateARoom> {
  final formKey = GlobalKey<FormState>();
  GlobalMethods globalMethods = GlobalMethods();
  bool isLoading = false;
  final FocusNode _usernameFocusNode = FocusNode();
  String? _roomName;
  String? checksum;
  int? videoDuration;
  List<int>? fileBytes;
  FilePickerResult? result;
  String? dirPath;

  Room? room;
  final videoInfo = FlutterVideoInfo();

  void submitForm() async {
    final isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid && mounted) {
      setState(() {
        isLoading = true;
      });
      formKey.currentState!.save();
      try {
        if (result == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Pick a file',
                maxLines: 3,
                style: kTextSmallBodyStyle,
              ),
              duration: Duration(seconds: 3),
            ),
          );
        } else if ((result!.files.single.path != null) && checksum == null ||
            videoDuration == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Wait for checksum to be generated',
                maxLines: 3,
                style: kTextSmallBodyStyle,
              ),
              duration: Duration(seconds: 3),
            ),
          );
        } else if (result!.files.single.path == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pick a video file')),
          );
        } else {
          print(checksum!);
          await onCreate(
                  roomName: _roomName!,
                  createdBy: 'createdBy',
                  time: videoDuration!,
                  checksum: checksum!)
              .then((value) {
            setState(() {
              room = value;
              print('gen rooooooooooom ${room}');
              print('pathhhhhhhhhhhhhhhhhhh ${result!.files.single.path!}');
            });
          }).then((value) {
            showDialog(
                context: context,
                builder: ((context) {
                  return AlertDialog(
                    title: Text('Proceed?'),
                    content: Column(
                      children: [
                        Text('Room name: ${_roomName}'),
                        Text('Filename: ${result!.files.single.name}'),
                        Text('Duration: ${videoDuration}'),
                        // Text('Room id: ${room!.roomID} coming from server'),
                        // Text('Room name: ${room!.roomName} coming form server'),
                        // Text('Room time: ${room!.time} coming form server'),
                        // Text(
                        //     'Room checksum: ${room!.checksum} coming form server'),
                        // Text(
                        //     'Room creator: ${room!.createdBy} coming form server'),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () async {
                            Navigator.push(context,
                                MaterialPageRoute(builder: ((context) {
                              return Videos(
                                  isCreator: true,
                                  room: room!,
                                  file: result!.files.single.path!);
                            })));
                          },
                          child: Text('Goto player')),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'))
                    ],
                  );
                }));
          });
        }
      } on Exception catch (error) {
        print('error occured $error}');
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //  print(dirPath);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a room'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Pick a video file',
              style: TextStyle(fontSize: 25),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            ElevatedButton(
              child: const Text('Pick a file'),
              onPressed: () async {
                try {
                  result =
                      await FilePicker.platform.pickFiles(type: FileType.video);
                  print(result!.files.single.path!);
                  fileBytes =
                      await File(result!.files.single.path!).readAsBytes();

                  var info =
                      await videoInfo.getVideoInfo(result!.files.single.path!);
                  setState(() {
                    checksum = md5.convert(fileBytes!).toString();
                    videoDuration =
                        Duration(milliseconds: info!.duration!.toInt())
                            .inSeconds;
                  });
                } catch (e) {
                  print(e);
                }
              },
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            const Text(
              'Enter room name',
              style: TextStyle(fontSize: 25),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            Form(
              key: formKey,
              child: TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('^[a-zA-Z0-9_]*')),
                ],
                key: const ValueKey('room_name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Room name cannot be empty';
                  } else if (value.length < 3 || value.length > 30) {
                    return 'Room name is either too short or too long';
                  } else if (!value.contains(RegExp('^[a-zA-Z0-9_]*'))) {
                    return 'Only alphanumeric and underscores are allowed in room name';
                  }
                  return null;
                },
                focusNode: _usernameFocusNode,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    errorMaxLines: 3,
                    border: const UnderlineInputBorder(),
                    filled: true,
                    prefixIcon: const Icon(Icons.person),
                    labelText: 'Roomname',
                    fillColor: Theme.of(context).colorScheme.background),
                onSaved: (value) {
                  _roomName = value!;
                },
                onChanged: (value) {
                  _roomName = value;
                },
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(const Size(150, 50)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            )),
                        onPressed: () {
                          submitForm();
                        },
                        child: const Text(
                          'Create a room',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 17),
                        )),
              ],
            ),
          ],
        ),
      )),
    );
  }
}

class JoinARoom extends StatefulWidget {
  const JoinARoom({super.key});

  @override
  State<JoinARoom> createState() => _JoinARoomState();
}

class _JoinARoomState extends State<JoinARoom> {
  final formKey = GlobalKey<FormState>();
  GlobalMethods globalMethods = GlobalMethods();
  bool isLoading = false;
  final FocusNode _usernameFocusNode = FocusNode();
  String? _roomID;
  String? checksum;
  int? videoDuration;
  List<int>? fileBytes;
  FilePickerResult? result;
  String? dirPath;

  Room? room;
  final videoInfo = FlutterVideoInfo();

  void submitForm() async {
    final isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid && mounted) {
      setState(() {
        isLoading = true;
      });
      formKey.currentState!.save();
      try {
        if (result == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Pick a file',
                maxLines: 3,
                style: kTextSmallBodyStyle,
              ),
              duration: Duration(seconds: 3),
            ),
          );
        } else if ((result!.files.single.path != null) && checksum == null ||
            videoDuration == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Wait for checksum to be generated',
                maxLines: 3,
                style: kTextSmallBodyStyle,
              ),
              duration: Duration(seconds: 3),
            ),
          );
        } else if (result!.files.single.path == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pick a video file')),
          );
        } else {
          await onJoin(
                  roomID: _roomID!,
                  createdBy: 'createdBy',
                  time: videoDuration!,
                  checksum: checksum!)
              .then((value) {
            setState(() {
              room = value;
              print('gen rooooooooooom ${room}');
              print('pathhhhhhhhhhhhhhhhhhh ${result!.files.single.path!}');
            });
          }).then((value) {
            showDialog(
                context: context,
                builder: ((context) {
                  return AlertDialog(
                    title: Text('Proceed?'),
                    content: Column(
                      children: [
                        Text('Room name: ${_roomID}'),
                        Text('Filename: ${result!.files.single.name}'),
                        Text('Duration: ${videoDuration}'),
                        Text('Room id: ${room!.roomID} coming from server'),
                        Text('Room name: ${room!.roomName} coming form server'),
                        Text('Room time: ${room!.time} coming form server'),
                        Text(
                            'Room checksum: ${room!.checksum} coming form server'),
                        Text(
                            'Room creator: ${room!.createdBy} coming form server'),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () async {
                            // if (room!.checksum == '') {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(content: Text('Mismatched files')),
                            //   );
                            // } else {
                            Navigator.push(context,
                                MaterialPageRoute(builder: ((context) {
                              return Videos(
                                  isCreator: false,
                                  room: room!,
                                  file: result!.files.single.path!);
                            })));
                            // }
                          },
                          child: Text('Goto player')),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'))
                    ],
                  );
                }));
          });
        }
      } on Exception catch (error) {
        print('error occured $error}');
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a room'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Pick a video file',
                style: TextStyle(fontSize: 25),
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              ElevatedButton(
                child: const Text('Pick a file'),
                onPressed: () async {
                  try {
                    result = await FilePicker.platform
                        .pickFiles(type: FileType.video);
                    print(result!.files.single.path!);
                    fileBytes =
                        await File(result!.files.single.path!).readAsBytes();

                    var info = await videoInfo
                        .getVideoInfo(result!.files.single.path!);
                    setState(() {
                      checksum = md5.convert(fileBytes!).toString();
                      videoDuration =
                          Duration(milliseconds: info!.duration!.toInt())
                              .inSeconds;
                    });
                  } catch (e) {
                    print(e);
                  }
                },
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              const Text(
                'Enter room ID',
                style: TextStyle(fontSize: 25),
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              Form(
                key: formKey,
                child: TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('^[a-zA-Z0-9_]*')),
                  ],
                  key: const ValueKey('room_name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Room ID cannot be empty';
                    } else if (value.length < 3 || value.length > 30) {
                      return 'Room ID is either too short or too long';
                    } else if (!value.contains(RegExp('^[a-zA-Z0-9_]*'))) {
                      return 'Only alphanumeric and underscores are allowed in room ID';
                    }
                    return null;
                  },
                  focusNode: _usernameFocusNode,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      errorMaxLines: 3,
                      border: const UnderlineInputBorder(),
                      filled: true,
                      prefixIcon: const Icon(Icons.person),
                      labelText: 'Room ID',
                      fillColor: Theme.of(context).colorScheme.background),
                  onSaved: (value) {
                    _roomID = value!;
                  },
                  onChanged: (value) {
                    _roomID = value;
                  },
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(
                                  const Size(150, 50)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              )),
                          onPressed: () {
                            submitForm();
                          },
                          child: const Text(
                            'Join a room',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 17),
                          )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



//STM9Zorx