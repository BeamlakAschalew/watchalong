import 'package:flutter/material.dart';
import 'package:watchalong/constants/theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: IndexedStack(index: currentIndex, children: const [
        Center(
          child: Text('data'),
        ),
        Center(
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
