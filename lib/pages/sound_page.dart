import 'package:flutter/material.dart';

class SoundPage extends StatelessWidget {
  const SoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Placeholder(),
          SizedBox(height: 34),
          Padding(
            padding: EdgeInsets.only(left: 32),
            child: Text(
              'インドゾウ',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.only(left: 32),
            child: Text(
              '「にげろ」',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'この鳴き声は、敵がいることを、仲間に\n知らせる警戒の声です。\nインドゾウは家族単位で群れを作ります。\n群れは5頭程度から、ときには\n60頭ほどにもなります。',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          )
        ],
      ),
    );
  }
}
