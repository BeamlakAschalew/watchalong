import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
// import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
//import 'package:video_player/video_player.dart';
import 'package:watchalong/models/room.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CreatorVideos extends StatefulWidget {
  const CreatorVideos({
    super.key,
    required this.file,
    required this.room,
  });
  final String file;
  final Room room;

  @override
  State<CreatorVideos> createState() => _CreatorVideosState();
}

class _CreatorVideosState extends State<CreatorVideos> {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerControlsConfiguration betterPlayerControlsConfiguration;
  late BetterPlayerBufferingConfiguration betterPlayerBufferingConfiguration =
      const BetterPlayerBufferingConfiguration(
    maxBufferMs: 240000,
    minBufferMs: 120000,
  );
  Timer? _timer;

  IO.Socket socket = IO.io("http://watchalong.doniverse.net",
      IO.OptionBuilder().setTransports(['websocket']).build());

  Future<void> socketConn() async {
    int? secondsStream;

    int _currentSecond = 0;
    Map<String, dynamic> roomData = {
      'createdAt': widget.room.createdBy,
      'roomID': widget.room.roomID,
      'audience': [],
      'romName': widget.room.roomName,
      'time': widget.room.time,
      'createdBy': widget.room.createdBy,
    };

    socket.connect();
    socket.onConnect((_) {
      socket.emit("createRoom", roomData);

      print('connected');
      socket.on("secondStream", (msg) async {
        secondsStream = msg;
        print('Secondsssssssssss $secondsStream');
        if (secondsStream! % 10 == 0) {
          _betterPlayerController.videoPlayerController!
              .seekTo(Duration(seconds: ((secondsStream!))));
        }
      });
    });

    socket.onConnectError((data) => print('connect failed $data'));
    socket.onDisconnect((data) => print('disconnectedddd $data'));
  }

  Future<void> secondSeek() async {
    int seek = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      seek++;
      _betterPlayerController.videoPlayerController!
          .seekTo(Duration(seconds: seek));
    });
  }

  @override
  void dispose() {
    // socket.clearListeners();
    // socket.disconnect();
    // socket.destroy();
    super.dispose();
  }

  Future<void> initPlayer() async {
    betterPlayerControlsConfiguration = const BetterPlayerControlsConfiguration(
      enableFullscreen: true,
      progressBarBackgroundColor: Colors.white,
      pauseIcon: Icons.pause_outlined,
      pipMenuIcon: Icons.picture_in_picture_sharp,
      playIcon: Icons.play_arrow_sharp,
      showControlsOnInitialize: true,
      progressBarBufferedColor: Colors.black45,
    );

    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
            autoDetectFullscreenDeviceOrientation: true,
            fullScreenByDefault: true,
            autoPlay: true,
            fit: BoxFit.contain,
            autoDispose: true,
            controlsConfiguration: betterPlayerControlsConfiguration,
            showPlaceholderUntilPlay: true,
            subtitlesConfiguration: const BetterPlayerSubtitlesConfiguration(
                backgroundColor: Colors.black45,
                fontFamily: 'Poppins',
                fontColor: Colors.white,
                outlineEnabled: false,
                fontSize: 17));

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      widget.file,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
  }

  void initVid() async {
    print(widget.file);
    await initPlayer();
    await socketConn();
  }

  @override
  void initState() {
    super.initState();
    initVid();
  }

  @override
  Widget build(BuildContext context) {
    // socketConn();
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: BetterPlayer(
            controller: _betterPlayerController,
          ),
        ),
      ),
    );
  }
}
