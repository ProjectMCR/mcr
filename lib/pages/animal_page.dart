import 'package:flutter/material.dart';

import '../colors.dart';

class AnimalPage extends StatelessWidget {
  const AnimalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AnimalOnomatopoeiaColor.yellow,
        body: Column(
          children: [
            const SizedBox(
              height: 208,
              child: Placeholder(),
            ),
            const SizedBox(height: 14),
            const Text(
              'こんなふうにきこえたよ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              'この鳴き声オノマトペは聞いた人が\nきこえた感じを自由に言葉にしたものです',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AnimalOnomatopoeiaColor.gray1,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              '動画：日立市かみね動物園園長先生撮影',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AnimalOnomatopoeiaColor.gray1,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 15),
            const Divider(
              color: AnimalOnomatopoeiaColor.blue,
              thickness: 2,
              indent: 155,
              endIndent: 155,
            ),
            const SizedBox(height: 30),
            const Text(
              'ぞうさんの気持ちわかるかな？',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(11.5),
              children: [
                Container(
                  height: 120,
                  width: 348,
                  color: AnimalOnomatopoeiaColor.clearBlack,
                  child: Row(
                    children: [
                      const SizedBox(width: 6),
                      Image.asset(
                        'assets/images/elephant/indian_elephant_attention.png',
                        height: 108,
                        width: 108,
                      ),
                      Column(
                        children: const [
                          Text('インドゾウ'),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
