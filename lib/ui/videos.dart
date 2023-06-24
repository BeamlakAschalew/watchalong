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

  void socketConn() {
    // Data of the created room
    var roomData = {
      'createdAt': '2:19 PM',
      'roomID': widget.room.roomID,
      'audience': [],
      'romName': widget.room.roomName,
      'time': widget.room.time,
      'createdBy': 'naol',
    };

    // 1️⃣ Configure socket connection
    var socket = IO.io('http://watchalong.doniverse.net');

    // 2️⃣ Establish socket connection
    socket.on('connect', (_) {
      // 3️⃣ If this user is room creator, emit the 'createRoom' event
      // Send roomData alongside
      socket.emit('createRoom', roomData);
    });

    // 4️⃣ 'secondStream' event is emitted as the timer counts
    socket.on('secondStream', (msg) {
      // msg - is an integer - it is the stream of seconds emitted
      // from the server
      // Use it to progress play
      var secondsStream = msg;
    });
  }

  @override
  void initState() {
    super.initState();

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
  }

  @override
  Widget build(BuildContext context) {
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
