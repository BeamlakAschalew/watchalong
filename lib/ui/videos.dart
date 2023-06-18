import 'dart:io';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
//import 'package:video_viewer/video_viewer.dart';

class Videos extends StatefulWidget {
  const Videos({super.key, required this.filePath});
  final String filePath;

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
