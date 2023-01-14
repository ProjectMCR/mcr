import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

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

  final answer2List = List<String>.generate(3, (index) => '');

  String formattedAnswer2() {
    var answer = '';
    for (var index = 0; index < 3; index++) {
      answer += '${ageControllers[index]} ${answer2List[index]},';
    }
    return answer;
  }

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
          groupValue: groupValue,
          onTap: () {
            onChanged('×× 全くそう思わない');
          },
        ),
        const SizedBox(height: 8),
        OptionsTile(
          value: '× そう思わない',
          groupValue: groupValue,
          onTap: () {
            onChanged('× そう思わない');
          },
        ),
        const SizedBox(height: 8),
        OptionsTile(
          value: '○ そう思う',
          groupValue: groupValue,
          onTap: () {
            onChanged('○ そう思う');
          },
        ),
        const SizedBox(height: 8),
        OptionsTile(
          value: '◎ とてもそう思う',
          groupValue: groupValue,
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
  final String groupValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: groupValue != value ? null : Colors.blue[100],
          border: Border.all(
            width: groupValue != value ? 1 : 2,
            color: groupValue != value ? Colors.black : Colors.blue,
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
