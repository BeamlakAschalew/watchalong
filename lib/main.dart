import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:watchalong/constants/theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:watchalong/screens/create_join_rooms.dart';
import 'screens/user_info.dart';
import 'screens/user_state.dart';

final Future<FirebaseApp> _initialization = Firebase.initializeApp();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Style.themeData(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Error occurred'),
                ),
              ),
            );
          }

          return const MaterialApp(
            home: UserState(),
          );
        });
  }
}

class WatchAlongHomeScreen extends StatefulWidget {
  const WatchAlongHomeScreen({super.key, required this.title});

  final String title;

  @override
  State<WatchAlongHomeScreen> createState() => _WatchAlongStateHomeScreen();
}

class _WatchAlongStateHomeScreen extends State<WatchAlongHomeScreen> {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => CreateARoom()))),
                  child: Text('Create a room')),
              ElevatedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => JoinARoom()))),
                  child: Text('Join a room')),
            ],
          ),
        ),
        const UserInfo()
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
