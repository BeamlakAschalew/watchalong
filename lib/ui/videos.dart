import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:watchalong/models/room.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Videos extends StatefulWidget {
  const Videos({super.key, required this.filePath, required this.room});
  final String filePath;
  final Room room;

  @override
  State<Videos> createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerControlsConfiguration betterPlayerControlsConfiguration;
  late BetterPlayerBufferingConfiguration betterPlayerBufferingConfiguration =
      const BetterPlayerBufferingConfiguration(
    maxBufferMs: 240000,
    minBufferMs: 120000,
  );

  int? secondsStream;
  IO.Socket socket = IO.io("http://watchalong.doniverse.net",
      IO.OptionBuilder().setTransports(['websocket']).build());

  Timer? _timer;
  int _currentSecond = 0;

  Future<void> socketConn() async {
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
    });

    socket.onConnectError((data) => print('connect failed $data'));
    socket.onDisconnect((data) => print('disconnected $data'));

    socket.on("secondStream", (msg) {
      secondsStream = msg;
    });
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
      BetterPlayerDataSourceType.file, widget.filePath,
      // cacheConfiguration: const BetterPlayerCacheConfiguration(
      //   useCache: true,
      //   preCacheSize: 471859200 * 471859200,
      //   maxCacheSize: 1073741824 * 1073741824,
      //   maxCacheFileSize: 471859200 * 471859200,

      //   ///Android only option to use cached video between app sessions
      //   key: "testCacheKey",
      // ),
      /*bufferingConfiguration: betterPlayerBufferingConfiguration*/
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
    // int dur = _betterPlayerController
    //     .videoPlayerController!.value.duration!.inSeconds;
    // print(dur);
    // _betterPlayerController.addEventsListener((p0) {
    //   print(p0.betterPlayerEventType.name);
    //   _betterPlayerController.videoPlayerController!
    //       .seekTo(Duration(seconds: secondsStream!));
    // });
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _currentSecond = _betterPlayerController
            .videoPlayerController!.value.position.inSeconds;
        print('currrrrrrrr seccccccc: $_currentSecond');
      });
      print('secondsssssssssssss $secondsStream');
      _betterPlayerController.videoPlayerController!
          .seekTo(Duration(seconds: secondsStream!));
    });
  }

  void initVid() async {
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
    socketConn();
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          //child: Container(color: Colors.yellow),
          child: BetterPlayer(
            controller: _betterPlayerController,
          ),
        ),
      ),
    );
  }
}
