import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcr/pages/home_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

/// オフラインモード
bool isOffline = true;

late Box<Map> animalBox;
late Box<bool> settingBox;

Future<void> hiveSetup() async {
  await Hive.initFlutter();
  animalBox = await Hive.openBox<Map>('animalBox');
  settingBox = await Hive.openBox<bool>('settingBox');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  await hiveSetup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // Android  のステータスバーアイコンの色が変更される
        statusBarIconBrightness: Brightness.light,
        // iOS のステータスバーの文字色が変更される
        statusBarBrightness: Brightness.light,
      ),
      child: MaterialApp(
        title: 'どうぶつオノマトペ',
        home: HomePage(),
      ),
    );
  }
}

class DownloadAndPlayMoviePage extends StatefulWidget {
  const DownloadAndPlayMoviePage({super.key});

  @override
  State<DownloadAndPlayMoviePage> createState() => _DownloadAndPlayMoviePageState();
}

class _DownloadAndPlayMoviePageState extends State<DownloadAndPlayMoviePage> {
  static const videoURL =
      'https://firebasestorage.googleapis.com/v0/b/animal-onomatope.appspot.com/o/movies%2Fanimal_emotion%2Felephant%2Felephant_sand.mp4?alt=media&token=c3228f47-9b54-4dc8-ab32-d2c436c934d8';

  File? file;

  VideoPlayerController? controller;

  Future<void> downloadFile() async {
    final dio = Dio();
    try {
      var dir = await getApplicationDocumentsDirectory();
      final path = dir.path;
      final directory = Directory('$path/video/');

      await directory.create(recursive: true);
      file = File('${dir.path}/demo.mp4');
      await dio.download(videoURL, "${dir.path}/demo.mp4", onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");
        print(((rec / total) * 100).toStringAsFixed(0) + "%");
      });

      controller = VideoPlayerController.file(file!);
      await controller?.initialize();
      controller?.play();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    downloadFile();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        if (controller?.value.isInitialized == true)
          AspectRatio(
            aspectRatio: controller!.value.aspectRatio,
            child: VideoPlayer(controller!),
          )
      ],
    ));
  }
}
