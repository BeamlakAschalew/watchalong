import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:watchalong/constants/theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:watchalong/ui/videos.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Style.themeData(),
      home: const MyHomePage(title: 'Watchalong'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;
  FilePickerResult? result;
  String? md5Res;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: IndexedStack(index: currentIndex, children: [
        Center(
          child: Column(
            children: [
              ElevatedButton(
                child: const Text('Pick a file'),
                onPressed: () async {
                  result =
                      await FilePicker.platform.pickFiles(type: FileType.video);
                  final fileBytes =
                      await File(result!.files.single.path!).readAsBytes();
                  final checksum = md5.convert(fileBytes).toString();
                  md5Res = checksum;
                  setState(() {});
                  // if (mounted) {
                  //   Navigator.push(context, MaterialPageRoute(builder: ((context) {
                  //     return Videos(filePath: result!.files.single.path!);
                  //   })));
                  // }
                },
              ),
              Text(md5Res ?? 'searching')
            ],
          ),
        ),
        const Center(
          child: Text('data1'),
        )
      ]),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.video_file), label: 'Videos'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profie'),
        ],
        selectedIndex: currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            currentIndex = value;
          });
        },
      ),
    );
  }
}
