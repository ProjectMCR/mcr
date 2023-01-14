import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mcr/pages/sound_page.dart';

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
  final answers = List<String>.generate(14, (index) => '');

  final ageControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  /// 複数の子供
  final answer2List = List<String>.generate(3, (index) => '');

  /// 複数の鳴き声
  final answer8List = List<String>.generate(4, (index) => '');

  /// 閲覧した鳴き声
  final answer11List = List<List<String>>.generate(
    4,
    (index) => <String>[],
  );

  /// そう思うと思った鳴き声
  final answer12List = List<List<String>>.generate(
    4,
    (index) => <String>[],
  );

  final answer13List = <String>[];

  final options = [
    '動物動画',
    'イラスト',
    '音の波形',
    'タイトル',
    '説明文章',
  ];

  String formattedAnswer2() {
    var answer = '';
    for (var index = 0; index < 3; index++) {
      answer += '${ageControllers[index].text} ${answer2List[index]}, ';
    }
    return answer;
  }

  String formattedAnswer8() {
    var answer = '';
    for (var index = 0; index < 4; index++) {
      answer += '${widget.animals[index].name} ${answer8List[index]}, ';
    }
    return answer;
  }

  String formattedAnswer11() {
    var answer = '';
    for (var index = 0; index < 4; index++) {
      answer +=
          '${widget.animals[index].name} [${answer11List[index].join('|')}], ';
    }
    return answer;
  }

  String formattedAnswer12() {
    var answer = '';
    for (var index = 0; index < 4; index++) {
      answer +=
          '${widget.animals[index].name} [${answer12List[index].join('|')}], ';
    }
    return answer;
  }

  String formattedAnswer13() {
    return answer13List.join(', ');
  }

  void submitAnswers() async {
    setState(() {
      isProcessing = true;
    });
    try {
      answers[1] = formattedAnswer2();
      answers[7] = formattedAnswer8();
      answers[10] = formattedAnswer11();
      answers[11] = formattedAnswer12();
      final completeText = answers.join('\n');
      final now = DateTime.now();

      final fileName = '${DateFormat('yyyy-MM-dd-HH-mm-ss').format(now)}.csv';

      await FirebaseStorage.instance
          .ref('test/$fileName')
          .putString(completeText);
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
                  groupValue: answer2List[index],
                  onChanged: (value) {
                    answer2List[index] = value;
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
            text: '7. 日頃お子様と動物の鳴き声に関する会話をしていますか？',
          ),
          const SizedBox(height: 8),
          LikertScaleQuestions(
            groupValue: answers[6],
            onChanged: (value) {
              answers[6] = value;
              setState(() {});
            },
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitleText(
            text: '8. 動物動画に出てくる文字を見て、「そんな鳴き声なの？！」と思いましたか？',
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < 4; index++)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('（${index + 1}） ${widget.animals[index].name}'),
                // TODO(kenta-wakasa): それぞれの動物の画像を添付する。
                const SizedBox(height: 8),
                LikertScaleQuestions(
                  groupValue: answer8List[index],
                  onChanged: (value) {
                    answer8List[index] = value;
                    setState(() {});
                  },
                ),
                const SizedBox(height: 24),
              ],
            )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitleText(
            text: '9. 鳴き声の受け取り方・聞こえ方は人それぞれだと思いましたか？',
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
            text: '10. 動物は気持ちや状況に合わせていろいろな声で鳴くことがわかりましたか？',
          ),
          const SizedBox(height: 8),
          LikertScaleQuestions(
            groupValue: answers[9],
            onChanged: (value) {
              answers[9] = value;
              setState(() {});
            },
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitleText(
            text: '11. 閲覧した動物の気持ちはどれですか？（見たものいくつでもチェック）',
          ),
          const SizedBox(height: 8),
          for (final animal in widget.animals)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(animal.name),
                Row(
                  children: animal.animalSounds.sublist(0, 4).map((e) {
                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          final index = widget.animals.indexOf(animal);
                          if (answer11List[index].contains(e.subtitle)) {
                            answer11List[index].remove(e.subtitle);
                          } else {
                            answer11List[index].add(e.subtitle);
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
                                  child: Image.network(e.imageUrl),
                                ),
                                if (answer11List[widget.animals.indexOf(animal)]
                                    .contains(e.subtitle))
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
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitleText(
            text:
                '12. アプリの動物の気持ちを改めてもう一度見てください。「鳴き声の雰囲気がわかる」と思ったものはどれですか？（そう思うものを全てチェックしてください）',
          ),
          const SizedBox(height: 8),
          for (final animal in widget.animals)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(animal.name),
                Row(
                  children: animal.animalSounds.sublist(0, 4).map((e) {
                    return Expanded(
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              final index = widget.animals.indexOf(animal);
                              if (answer12List[index].contains(e.subtitle)) {
                                answer12List[index].remove(e.subtitle);
                              } else {
                                answer12List[index].add(e.subtitle);
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
                                      child: Image.network(e.imageUrl),
                                    ),
                                    if (answer12List[
                                            widget.animals.indexOf(animal)]
                                        .contains(e.subtitle))
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
            )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionTitleText(
            text: '13. 気持ちによる鳴き声の雰囲気は何で伝わりましたか？（幾つでも選んでください）',
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
                                  groupValue: answer13List.contains(option),
                                  onTap: () {
                                    if (answer13List.contains(option)) {
                                      answer13List.remove(option);
                                    } else {
                                      answer13List.add(option);
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
                            Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/animal-onomatope.appspot.com/o/soundpageImage.png?alt=media&token=029fc9a0-842b-425e-9334-df22ee7dfef0',
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
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: const Alignment(0, .6),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  color: Colors.black.withOpacity(.7),
                                ),
                                child: const Text(
                                  '説明文章',
                                  style: TextStyle(
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
            text: '14. アプリの改善ポイントや感想をご自由にお書きください。',
          ),
          const SizedBox(height: 8),
          TextFormField(
            minLines: 5,
            maxLines: 5,
            onChanged: (value) {
              answers[13] = value;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionsTile(
          value: '×× 全くそう思わない',
          groupValue: groupValue == '×× 全くそう思わない',
          onTap: () {
            onChanged('×× 全くそう思わない');
          },
        ),
        const SizedBox(height: 8),
        OptionsTile(
          value: '× そう思わない',
          groupValue: groupValue == '× そう思わない',
          onTap: () {
            onChanged('× そう思わない');
          },
        ),
        const SizedBox(height: 8),
        OptionsTile(
          value: '○ そう思う',
          groupValue: groupValue == '○ そう思う',
          onTap: () {
            onChanged('○ そう思う');
          },
        ),
        const SizedBox(height: 8),
        OptionsTile(
          value: '◎ とてもそう思う',
          groupValue: groupValue == '◎ とてもそう思う',
          onTap: () {
            onChanged('◎ とてもそう思う');
          },
        ),
      ],
    );
  }
}

class OptionsTile extends StatelessWidget {
  const OptionsTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  final String value;
  final bool groupValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: !groupValue ? null : Colors.blue[100],
          border: Border.all(
            width: !groupValue ? 1 : 2,
            color: !groupValue ? Colors.black : Colors.blue,
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
