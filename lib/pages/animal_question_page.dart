import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcr/main.dart';
import 'package:mcr/pages/question_page.dart';
import 'package:mcr/pages/sound_page.dart';

import '../models/animal.dart';

class AnimalQuestion extends StatefulWidget {
  const AnimalQuestion({
    super.key,
    required this.animal,
    required this.forChild,
  });

  final Animal animal;
  final bool forChild;

  @override
  State<AnimalQuestion> createState() => _AnimalQuestionState();
}

class _AnimalQuestionState extends State<AnimalQuestion> {
  Animal get animal => widget.animal;

  static const titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  final answer = List.generate(5, (index) => '');

  String get generateCSV {
    String res = '$fileName\n';

    res += '${answer[0]}\n';

    res += answer.sublist(1, 5).join(',');

    return res;
  }

  String get fileName {
    final fileName =
        '$deviceId-${animal.name}-${widget.forChild ? 'こども用' : '大人用'}-${DateFormat('HH時mm分ss秒').format(DateTime.now())}.csv';
    return fileName;
  }

  Future<void> submitAnswer() async {
    log(generateCSV);
    final file = File('${answerDir.path}/$fileName');
    await file.writeAsString(generateCSV);
    await showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: Text('提出しました'),
        );
      },
    );
    Navigator.of(context).pop();
  }

  // late final thumbnail = VideoThumbnail.thumbnailData(video: animal.onomatopoeiaVideoUrl);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${animal.name}アンケート'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.forChild)
                  const Text(
                    'どうぶつといっしょに出てくる文字を見て、「そんな鳴き声なの？！」とおもいましたか？',
                    style: titleStyle,
                  )
                else
                  const Text(
                    '動物の動画に出てくる文字を見て、「そんな鳴き声なの？！」と思いましたか？',
                    style: titleStyle,
                  ),
                const SizedBox(height: 16),
                LikertScaleQuestions(
                  groupValue: answer[0],
                  onChanged: (text) {
                    answer[0] = text;
                    setState(() {});
                  },
                ),
                const SizedBox(
                  height: 48,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.forChild
                          ? 'なきごえの感じが良くつたわったのはどれですか？（いくつ選んでもかまいません）'
                          : '鳴き声の感じが良くつたわったのはどれですか？（いくつ選んでもかまいません）',
                      style: titleStyle,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: animal.animalSounds.sublist(0, 4).map((e) {
                        final index = animal.animalSounds.indexOf(e);
                        return Expanded(
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (answer[index + 1] == e.subtitle) {
                                    answer[index + 1] = '';
                                  } else {
                                    answer[index + 1] = e.subtitle;
                                  }
                                  setState(() {});
                                },
                                child: Stack(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: isOffline ? Image.file(File(e.imageUrl)) : Image.network(e.imageUrl),
                                        ),
                                        if (answer[index + 1] == e.subtitle)
                                          Container(
                                            width: 32,
                                            height: 32,
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.red,
                                                width: 4,
                                              ),
                                            ),
                                          )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                        e.subtitle,
                                        style: const TextStyle(
                                          backgroundColor: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 32,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return SoundPage(
                                            selectedAnimalSound: e,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    '動画を見る',
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: answer[0].isEmpty ? null : submitAnswer,
                    child: const Text('この内容で提出する'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
