import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcr/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // Android のステータスバーアイコンの色が変更される
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
