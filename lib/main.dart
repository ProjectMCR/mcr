import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcr/pages/home_page.dart';

/// オフラインモード
bool isOffline = false;

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
