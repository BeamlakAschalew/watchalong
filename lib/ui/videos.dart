import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
// import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
//import 'package:video_player/video_player.dart';
import 'package:watchalong/models/room.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Videos extends StatefulWidget {
  const Videos({super.key, required this.file, required this.room});
  final String file;
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
        //   print("Emitted second: ${secondsStream}");

        // _betterPlayerController.videoPlayerController!
        //     .seekTo(Duration(seconds: secondsStream! - 1));
        // print(DateTime.now());
        // print(secondsStream!);
        // if (chewieController != null) {
        //   chewieController!.seekTo(Duration(seconds: (secondsStream! - 2)));
        // }
        print('Secondsssssssssss $secondsStream');
        // Duration? difference = Duration(seconds: secondsStream!) -
        //     (await _betterPlayerController.videoPlayerController!.position)!;
        if (secondsStream! % 10 == 0) {
          _betterPlayerController.videoPlayerController!
              .seekTo(Duration(seconds: ((secondsStream!))));
        }
        //    _betterPlayerController.videoPlayerController!.seekTo(difference);
      });
    });

    socket.onConnectError((data) => print('connect failed $data'));
    socket.onDisconnect((data) => print('disconnected $data'));

    // socket.on("secondStream", (msg) {
    //   _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    //     secondsStream = msg;
    //     print("Emitted second: $secondsStream");

    //     if (secondsStream % 2 == 0) {
    //       _betterPlayerController.videoPlayerController!
    //           .seekTo(Duration(seconds: secondsStream!));
    //     }
    //   });
    // });

    // _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    //   print('timer');
    // });
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
    // videoPlayerController!.dispose();
    // chewieController!.dispose();
    socket.clearListeners();
    socket.disconnect();
    socket.destroy();
    super.dispose();
  }

  // ChewieController? chewieController;
  // VideoPlayerController? videoPlayerController;

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

    // videoPlayerController = VideoPlayerController.file(widget.file);

    // await videoPlayerController!.initialize();

    // setState(() {
    //   chewieController = ChewieController(
    //     videoPlayerController: videoPlayerController!,
    //     autoPlay: true,
    //     looping: true,
    //   );
    // });
  }

  void initVid() async {
    print(widget.file);
    await initPlayer();
    await socketConn();
    // await secondSeek();
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
          //child: Container(color: Colors.yellow),
          // child: chewieController == null
          //     ? Center(child: CircularProgressIndicator())
          //     : Chewie(
          //         controller: chewieController!,
          //       ),
          child: BetterPlayer(
            controller: _betterPlayerController,
          ),
        ),
      ),
    );
  }
}
