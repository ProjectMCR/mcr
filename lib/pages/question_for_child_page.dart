import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mcr/pages/question_page.dart';

import '../main.dart';
import '../models/animal.dart';

class QuestionForChildPage extends StatefulWidget {
  const QuestionForChildPage({
    super.key,
    required this.animals,
  });

  final List<Animal> animals;

  @override
  State<QuestionForChildPage> createState() => _QuestionForChildPageState();
}

class _QuestionForChildPageState extends State<QuestionForChildPage> {
  final answers = List<String>.generate(12, (index) => '');

  /// 何歳なのか
  final ageController = TextEditingController();

  /// 最後の自由記述
  final freeController = TextEditingController();

  final whatFactorAnimalFeel = <String>[];

  final options = [
    '動物動画',
    'イラスト',
    '音の波形',
    'タイトル',
    '説明文章',
  ];

  String formattedWhatFactorAnimalFeel() {
    return whatFactorAnimalFeel.join(', ');
  }

  String get generateCSV {
    /// 複数の子供に関するやつ
    // answers[1] = formattedChildrenAnswer();

    /// どれが気持ちを伝える要因になったか
    answers[10] = formattedWhatFactorAnimalFeel();

    var ans = fileName + '\n';

    for (var index = 0; index < answers.length; index++) {
      final answer = answers[index];
      ans += '${index + 1}, $answer\n';
    }

    return ans;
  }

  Future<void> submitAnswers() async {
    log(generateCSV);
    setState(() {
      isProcessing = true;
    });
    try {
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
    } finally {
      setState(() {
        isProcessing = false;
      });
    }

    Navigator.of(context).pop();
  }

  bool isProcessing = false;

  @override
  void dispose() {
    super.dispose();
    ageController.dispose();
    freeController.dispose();
  }

  static final questionsText = [
    '1. あなたは何歳ですか？',
    '2. 水戸ろう学校に通っていますか？',
    '3. 今日のイベントはたのしかったですか？',
    '4. みんなで、いっしょに、たのしめましたか？',
    '5. どうぶつのことをもっと知りたいとおもいましたか？',
    '6. どうぶつの鳴き声をもっと知りたいとおもいましたか？',
    '7. もっといろいろな音をみてみたいとおもいましたか？',
    '8. どうぶつの鳴き声がでてくる絵本を読んだことがありますか？',
    '9. 鳴き声の聞こえ方は聞く人によってちがうとおもいましたか？',
    '10. どうぶつは気持ちによっていろいろな声で鳴くことがわかりましたか？',
    '11. 気持ちによる鳴き声の雰囲気は何で伝わりましたか？（いくつ選んでもかまいません）',
    '12. 感想をじゆうにかいてください。',
  ];

  String get fileName {
    final fileName = '$deviceId-全体-こども用-${DateFormat('HH時mm分ss秒').format(DateTime.now())}.csv';
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    final questions = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTitleText(
            text: questionsText[0],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            width: 80,
            child: TextFormField(
              controller: ageController,
              onChanged: (text) {
                answers[0] = text;
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                suffix: Text('さい'),
                border: OutlineInputBorder(),
              ),
            ),
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTitleText(
            text: questionsText[1],
          ),
          const SizedBox(height: 8),
          LikertScaleFreeQuestions(
            groupValue: answers[1],
            onChanged: (value) {
              answers[1] = value;
              setState(() {});
            },
            questions: const [
              'はい',
              'いいえ',
            ],
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTitleText(
            text: questionsText[2],
          ),
          const SizedBox(height: 8),
          LikertScaleFreeQuestions(
            groupValue: answers[2],
            onChanged: (value) {
              answers[2] = value;
              setState(() {});
            },
            questions: const [
              '×× まったく楽しくない',
              '× 楽しくない',
              '○ 楽しい',
              '○ とても楽しい',
            ],
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTitleText(
            text: questionsText[3],
          ),
          const SizedBox(height: 8),
          LikertScaleFreeQuestions(
            groupValue: answers[3],
            onChanged: (value) {
              answers[3] = value;
              setState(() {});
            },
            questions: const [
              '×× まったく楽しくない',
              '× 楽しくない',
              '○ 楽しい',
              '○ とても楽しい',
            ],
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTitleText(
            text: questionsText[4],
          ),
          const SizedBox(height: 8),
          LikertScaleFreeQuestions(
            groupValue: answers[4],
            onChanged: (value) {
              answers[4] = value;
              setState(() {});
            },
            questions: const [
              '×× まったく思わない',
              '× 思わない',
              '○ 思う',
              '○ とても思う',
            ],
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTitleText(
            text: questionsText[5],
          ),
          const SizedBox(height: 8),
          LikertScaleFreeQuestions(
            groupValue: answers[5],
            onChanged: (value) {
              answers[5] = value;
              setState(() {});
            },
            questions: const [
              '×× まったく思わない',
              '× 思わない',
              '○ 思う',
              '○ とても思う',
            ],
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTitleText(
            text: questionsText[6],
          ),
          const SizedBox(height: 8),
          LikertScaleFreeQuestions(
            groupValue: answers[6],
            onChanged: (value) {
              answers[6] = value;
              setState(() {});
            },
            questions: const [
              '×× まったく思わない',
              '× 思わない',
              '○ 思う',
              '○ とても思う',
            ],
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTitleText(
            text: questionsText[7],
          ),
          const SizedBox(height: 8),
          LikertScaleFreeQuestions(
            groupValue: answers[7],
            onChanged: (value) {
              answers[7] = value;
              setState(() {});
            },
            questions: const [
              '×× まったくない',
              '× ほとんどない',
              '○ ある',
              '○ とてもある',
            ],
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTitleText(
            text: questionsText[8],
          ),
          const SizedBox(height: 8),
          LikertScaleFreeQuestions(
            groupValue: answers[8],
            onChanged: (value) {
              answers[8] = value;
              setState(() {});
            },
            questions: const [
              '×× まったく思わない',
              '× 思わない',
              '○ 思う',
              '○ とても思う',
            ],
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTitleText(
            text: questionsText[9],
          ),
          const SizedBox(height: 8),
          LikertScaleFreeQuestions(
            groupValue: answers[9],
            onChanged: (value) {
              answers[9] = value;
              setState(() {});
            },
            questions: const [
              '×× まったくわからない',
              '× わからない',
              '○ わかる',
              '○ とてもわかる',
            ],
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTitleText(
            text: questionsText[10],
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final option in options)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                OptionsTile(
                                  value: option,
                                  isSelected: whatFactorAnimalFeel.contains(option),
                                  onTap: (option) {
                                    if (whatFactorAnimalFeel.contains(option)) {
                                      whatFactorAnimalFeel.remove(option);
                                    } else {
                                      whatFactorAnimalFeel.add(option);
                                    }
                                    setState(() {});
                                  },
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/questions/sound_image.png',
                            ),
                            Align(
                              alignment: const Alignment(0, -.9),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  color: Colors.black.withOpacity(.7),
                                ),
                                child: const Text(
                                  '動物動画',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: const Alignment(0, -.6),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  color: Colors.black.withOpacity(.7),
                                ),
                                child: const Text(
                                  'イラスト',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: const Alignment(0, -.1),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  color: Colors.black.withOpacity(.7),
                                ),
                                child: const Text(
                                  '音の波形',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: const Alignment(0, .35),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  color: Colors.black.withOpacity(.7),
                                ),
                                child: const Text(
                                  'タイトル',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: const Alignment(0, .55),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  color: Colors.black.withOpacity(.7),
                                ),
                                child: const Text(
                                  '説明文章',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTitleText(
            text: questionsText[11],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: freeController,
            minLines: 5,
            maxLines: 5,
            onChanged: (value) {
              answers[11] = value;
              setState(() {});
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      ElevatedButton(
        onPressed: () {
          submitAnswers();
        },
        child: const Text('提出する'),
      ),
    ];

    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: WillPopScope(
        onWillPop: () async {
          final res = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('回答中のアンケートがあります'),
                content: const Text('回答中のアンケートは削除されますが前のページに戻りますか？'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('アンケートを破棄して戻る'),
                  )
                ],
              );
            },
          );
          return res ?? false;
        },
        child: GestureDetector(
          onTap: () => primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(40.0),
              child: AppBar(
                backgroundColor: Colors.white,
                leadingWidth: 50,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: InkWell(
                    onTap: () async {
                      final res = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('回答中のアンケートがあります'),
                            content: const Text('回答中のアンケートは削除されますが前のページに戻りますか？'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('アンケートを破棄して戻る'),
                              )
                            ],
                          );
                        },
                      );
                      if (res != true) {
                        return;
                      }
                      Navigator.of(context).pop();
                    },
                    child: Image.asset(
                      'assets/images/home_icon.png',
                    ),
                  ),
                ),
              ),
            ),
            body: ListView.separated(
              itemCount: questions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: questions[index],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class QuestionTitleText extends StatelessWidget {
  const QuestionTitleText({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}
