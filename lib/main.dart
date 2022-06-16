import 'dart:io';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'package:window_manager/window_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import '_tray.dart' as tray;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  int hwnd = FindWindow(TEXT('FLUTTER_RUNNER_WIN32_WINDOW'),TEXT('play_audio'));
  tray.addIcon(hWndParent: hwnd);
  launchAtStartup.setup(
    appName: 'play_audio',
    appPath: Platform.resolvedExecutable,
  );
  await launchAtStartup.enable();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '5G哨兵',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '5G哨兵'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  late HttpServer _httpServer;

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();

    HttpServer.bind(
      InternetAddress.anyIPv4,
      8086,
    ).then((httpServer) async {
      AudioPlayer player = AudioPlayer();
      await player.setAsset('assets/warning.mp3');
      player.play();
      _httpServer = httpServer;
      _httpServer.forEach((HttpRequest request) async {
        request.response.write('ok');
        request.response.close();
        await player.setAsset('assets/warning.mp3');
        player.play();
      });
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
    _httpServer.close(force: true);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
    );
  }

  
  @override
  void onWindowFocus() {
    setState(() {});
  }
}
