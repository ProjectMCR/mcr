import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/animal.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({
    super.key,
    required this.animals,
  });

  final List<Animal> animals;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final answers = List<String>.generate(11, (index) => '');

  final ageControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  final freeController = TextEditingController();

  /// 複数の子供
  final childrenAnswer = List<String>.generate(3, (index) => '');

  final whatFactorAnimalFeel = <String>[];

  final options = [
    '動物動画',
    'イラスト',
    '音の波形',
    'タイトル',
    '説明文章',
  ];

  String formattedChildrenAnswer() {
    var answer = '';
    for (var index = 0; index < 3; index++) {
      answer += '${ageControllers[index].text} ${childrenAnswer[index]}, ';
    }
    return answer;
  }

  String formattedWhatFactorAnimalFeel() {
    return whatFactorAnimalFeel.join(', ');
  }

  String get fileName {
    final fileName = '$deviceId-全体-大人用-${DateFormat('HH時mm分ss秒').format(DateTime.now())}.csv';
    return fileName;
  }

  String get generateCSV {
    /// 複数の子供に関するやつ
    answers[1] = formattedChildrenAnswer();

    /// どれが気持ちを伝える要因になったか
    answers[9] = formattedWhatFactorAnimalFeel();

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
    for (final c in ageControllers) {
      c.dispose();
    }
    freeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questions = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitleText(
            text: '1. イベントは楽しめましたか？',
          ),
          const SizedBox(height: 8),
          LikertScaleQuestions(
            groupValue: answers[0],
            onChanged: (value) {
              answers[0] = value;
              setState(() {});
            },
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitleText(
            text: '2. お子様は楽しんでいるようでしたか？',
          ),
          const Text(
            '（お子様が複数いらっしゃる場合はお子様別にご回答ください）',
            style: TextStyle(
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < 3; index++)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 32,
                      width: 80,
                      child: TextFormField(
                        controller: ageControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    const Text('歳'),
                  ],
                ),
                const SizedBox(height: 8),
                LikertScaleQuestions(
                  groupValue: childrenAnswer[index],
                  onChanged: (value) {
                    childrenAnswer[index] = value;
                    setState(() {});
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitleText(
            text: '3. アプリは家族一緒に動物園を楽しむ助けになりましたか？',
          ),
          const SizedBox(height: 8),
          LikertScaleQuestions(
            groupValue: answers[2],
            onChanged: (value) {
              answers[2] = value;
              setState(() {});
            },
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitleText(
            text: '4. このアプリはお子様が動物に興味を持つきっかけになりそうですか？',
          ),
          const SizedBox(height: 8),
          LikertScaleQuestions(
            groupValue: answers[3],
            onChanged: (value) {
              answers[3] = value;
              setState(() {});
            },
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitleText(
            text: '5. このアプリはお子様が動物の鳴き声に興味を持つきっかけになりそうですか？',
          ),
          const SizedBox(height: 8),
          LikertScaleQuestions(
            groupValue: answers[4],
            onChanged: (value) {
              answers[4] = value;
              setState(() {});
            },
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitleText(
            text: '6. このアプリはお子様が音に興味を持つきっかけになりそうですか？',
          ),
          const SizedBox(height: 8),
          LikertScaleQuestions(
            groupValue: answers[5],
            onChanged: (value) {
              answers[5] = value;
              setState(() {});
            },
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitleText(
            text: '7. 日頃お子様と動物の鳴き声に関する会話をしていますか？\n（動物の鳴き声が出ている絵本を読んだり、そばにいる犬猫を話題にするなど）',
          ),
          const SizedBox(height: 8),
          LikertScaleFreeQuestions(
            groupValue: answers[6],
            onChanged: (value) {
              answers[6] = value;
              setState(() {});
            },
            questions: const [
              '×× 全くしない',
              '× しない',
              '○ する',
              '◎ よくする',
            ],
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitleText(
            text: '8. 鳴き声の受け取り方・聞こえ方は人それぞれだと思いましたか？',
          ),
          const SizedBox(height: 8),
          LikertScaleQuestions(
            groupValue: answers[7],
            onChanged: (value) {
              answers[7] = value;
              setState(() {});
            },
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitleText(
            text: '9. 動物は気持ちや状況に合わせていろいろな声で鳴くことがわかりましたか？',
          ),
          const SizedBox(height: 8),
          LikertScaleQuestions(
            groupValue: answers[8],
            onChanged: (value) {
              answers[8] = value;
              setState(() {});
            },
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitleText(
            text: '10. 気持ちによる鳴き声の雰囲気は何で伝わりましたか？（幾つでも選んでください）',
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
          const QuestionTitleText(
            text: '11. アプリの改善ポイントや感想をご自由にお書きください。',
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: freeController,
            minLines: 5,
            maxLines: 5,
            onChanged: (value) {
              answers[10] = value;
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
                      child: const Text('アンケートを破棄して戻る'))
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
                                  child: const Text('アンケートを破棄して戻る'))
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

class LikertScaleQuestions extends StatelessWidget {
  const LikertScaleQuestions({
    super.key,
    required this.groupValue,
    required this.onChanged,
  });

  final Function(String) onChanged;
  final String groupValue;

  @override
  Widget build(BuildContext context) {
    return LikertScaleFreeQuestions(
      onChanged: onChanged,
      groupValue: groupValue,
      questions: const [
        '×× 全くそう思わない',
        '× そう思わない',
        '○ そう思う',
        '◎ とてもそう思う',
      ],
    );
  }
}

class LikertScaleFreeQuestions extends StatelessWidget {
  const LikertScaleFreeQuestions({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.questions,
  });

  final Function(String) onChanged;
  final String groupValue;
  final List<String> questions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final question in questions)
          OptionsTile(
            value: question,
            isSelected: groupValue == question,
            onTap: onChanged,
          ),
      ],
    );
  }
}

class OptionsTile extends StatelessWidget {
  const OptionsTile({
    super.key,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String value;
  final bool isSelected;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap(value);
      },
      child: Container(
        decoration: BoxDecoration(
          color: !isSelected ? null : Colors.blue[100],
          border: Border.all(
            width: !isSelected ? 1 : 2,
            color: !isSelected ? Colors.black : Colors.blue,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Text(value),
      ),
    );
  }
}
