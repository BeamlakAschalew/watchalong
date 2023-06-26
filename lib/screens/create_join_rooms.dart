import 'dart:io';
import 'package:better_player/better_player.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:image_picker/image_picker.dart';
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
  XFile? video;

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
        if ((video != null) && checksum == null || videoDuration == null) {
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
          showDialog(
              context: context,
              builder: ((context) {
                return AlertDialog(
                  title: Text('Proceed?'),
                  content: Column(
                    children: [
                      Text('Room name: ${_roomName}'),
                      Text('Filename: ${result!.files.single.name}'),
                      Text('Duration: ${videoDuration}')
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          await onCreate(
                                  roomName: _roomName!,
                                  createdBy: 'createdBy',
                                  time: videoDuration!,
                                  checksum: checksum!)
                              .then((value) {
                            setState(() {
                              room = value;
                              print('gen rooooooooooom ${room}');
                              print(
                                  'pathhhhhhhhhhhhhhhhhhh ${result!.files.single.path!}');
                            });
                          }).then((value) async {
                            return Navigator.push(context,
                                MaterialPageRoute(builder: ((context) {
                              return Videos(room: room!, filePath: video!.path);
                            })));
                          });
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
        title: const Text('Create a room'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text('Pick a video file'),
            ElevatedButton(
              child: const Text('Pick a file'),
              onPressed: () async {
                try {
                  video = await ImagePicker().pickVideo(
                    source: ImageSource.gallery,
                  );
                  if (video != null) {
                    print('vid pathhhhhhhhhhh: ${video!.path}');
                    fileBytes = await File(video!.path).readAsBytes();
                    setState(() {
                      checksum = md5.convert(fileBytes!).toString();
                    });
                  }
                } catch (e) {
                  print(e);
                }
                setState(() {});
              },
            ),
            const Text('Enter room name'),
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

class JoinARoom extends StatelessWidget {
  const JoinARoom({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Text('Pick a video file'),
        ],
      )),
    );
  }
}





 // result =
                  //     await FilePicker.platform.pickFiles(type: FileType.video);
                  // fileBytes =
                  //     await File(result!.files.single.path!).readAsBytes();

                  // var info =
                  //     await videoInfo.getVideoInfo(result!.files.single.path!);
                  // checksum = md5.convert(fileBytes!).toString();
                  // videoDuration =
                  //     Duration(milliseconds: info!.duration!.toInt()).inSeconds;







 // result =
                //     await FilePicker.platform.pickFiles(type: FileType.video);
                // final fileBytes =
                //     await File(result!.files.single.path!).readAsBytes();
                // final checksum = md5.convert(fileBytes).toString();
                // // md5Res = checksum;
                // setState(() {});
                // if (mounted) {
                //   Navigator.push(context,
                //       MaterialPageRoute(builder: ((context) {
                //     return Videos(filePath: result!.files.single.path!);
                //   })));
                // }
