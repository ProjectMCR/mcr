import 'package:flutter/material.dart';
import 'package:mcr/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'どうぶつオノマトペ',
      home: HomePage(),
    );
  }
}
