import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mcr/models/animal.dart';
import 'package:mcr/pages/animal_question_page.dart';
import 'package:mcr/repositories/animal_repositories.dart';
import 'package:video_player/video_player.dart';

import '../colors.dart';
import 'sound_page.dart';

class AnimalPage extends StatefulWidget {
  const AnimalPage({
    super.key,
    required this.selectedAnimal,
  });

  final Animal selectedAnimal;

  @override
  State<AnimalPage> createState() => _AnimalPageState();
}

class _AnimalPageState extends State<AnimalPage> {
  late VideoPlayerController _videoController;

  //動画の再生、停止用
  bool _onTouch = false;
  Timer? _timer;

  //鳴き声字幕が入るリスト

  /// video player初期化
  Future<void> initializeVideoPlayer() async {
    // TODO(kenta-wakasa): ビデオダウンロードと再生の仕組みを見直す
    final filePath = widget.selectedAnimal.onomatopoeiaVideoUrl;
    _videoController =
        // isOffline
        //     ? VideoPlayerController.file(
        //         File(filePath),
        //       )
        //     :
        VideoPlayerController.network(
      widget.selectedAnimal.onomatopoeiaVideoUrl.toString(),
    );

    await _videoController.initialize();
    //初期化されたら、自動で再生する
    try {
      await _videoController.play();
    } catch (_) {
      // Web ブラウザの自動再生制限などで失敗しても、再生ボタンから操作できる
    }
    if (mounted) {
      setState(() {});
    }
    //ループ再生
    _videoController.setLooping(true);
  }

  @override
  void initState() {
    super.initState();
    initializeVideoPlayer();
    generateRandomValue();
    loop();
  }

  var isStop = false;

  var offsetList = <Offset>[];

  final random = Random();

  void generateRandomValue() async {
    for (var index = 0;
        index < widget.selectedAnimal.onomatopoeiaList.length;
        index++) {
      offsetList.add(_randomOffset());
    }
  }

  /// 画面右外から流れ始める位置をランダムに生成する。
  Offset _randomOffset() {
    return Offset(
      1 + random.nextDouble() * 10,
      -1 + 2 * random.nextDouble(),
    );
  }

  var isPosting = false;

  /// 投稿ダイアログを開いて、入力された鳴き声を追記する。
  Future<void> _showPostDialog() async {
    final controller = TextEditingController();
    try {
      final text = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'きこえた鳴き声を\n投稿してみよう',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'あなたには${widget.selectedAnimal.name}の鳴き声が\nどんなふうにきこえたかな？',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AnimalOnomatopoeiaColor.gray1,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 20,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'れい：パオーン',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) => Navigator.of(context).pop(value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('やめる'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AnimalOnomatopoeiaColor.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(controller.text),
                child: const Text('とうこう'),
              ),
            ],
          );
        },
      );
      if (text != null) {
        await _addOnomatopoeia(text);
      }
    } finally {
      controller.dispose();
    }
  }

  /// 入力された鳴き声を画面と Firestore の両方に追記する。
  Future<void> _addOnomatopoeia(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) {
      return;
    }

    final reference = widget.selectedAnimal.reference;
    if (reference == null) {
      _showSnackBar('いまは投稿できません');
      return;
    }

    // Firestore の arrayUnion と挙動を揃えるため、すでにある言葉は重複追加しない。
    final alreadyExists = widget.selectedAnimal.onomatopoeiaList.contains(text);
    if (alreadyExists) {
      _showSnackBar('その鳴き声はすでに投稿されています');
      return;
    }

    // 先に画面へ反映して、すぐに流れて見えるようにする。
    setState(() {
      isPosting = true;
      widget.selectedAnimal.onomatopoeiaList.add(text);
      offsetList.add(_randomOffset());
    });

    try {
      await AnimalRepository().addOnomatopoeia(
        reference: reference,
        onomatopoeia: text,
      );
      _showSnackBar('とうこうしました！');
    } catch (_) {
      // 失敗したら画面への追記を取り消す。
      setState(() {
        widget.selectedAnimal.onomatopoeiaList.remove(text);
        if (offsetList.isNotEmpty) {
          offsetList.removeLast();
        }
      });
      _showSnackBar('とうこうにしっぱいしました');
    } finally {
      if (mounted) {
        setState(() {
          isPosting = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> loop() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 1));
      if (isStop) {
        continue;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        for (var index = 0; index < offsetList.length; index++) {
          if (offsetList[index].dx < -2) {
            offsetList[index] = Offset(
              1 + random.nextDouble() * 10,
              -1 + 2 * random.nextDouble(),
            );
          } else {
            offsetList[index] = Offset(
              offsetList[index].dx - 0.002,
              offsetList[index].dy,
            );
          }
        }
      });
    }
  }

  /// 再生・停止ボタンの表示を切り替える。表示してから2.5秒で自動的に隠す。
  void _toggleControls() {
    _timer?.cancel();
    setState(() {
      _onTouch = !_onTouch;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      setState(() {
        _onTouch = false;
      });
    });
  }

  /// 動画の再生と停止を切り替える。
  void _togglePlayPause() {
    _timer?.cancel();
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        isStop = true;
      } else {
        _videoController.play();
        isStop = false;
      }
    });
    // 2.5秒したらボタン消える
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      setState(() {
        _onTouch = false;
      });
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnimalOnomatopoeiaColor.yellow,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          backgroundColor: Colors.white,
          leadingWidth: 50,
          leading: Padding(
            padding: const EdgeInsets.only(left: 18),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Image.asset(
                'assets/images/home_icon.png',
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // 広い画面ではコンテンツが横に間延びしないよう最大幅を決めて中央寄せする。
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Column(
                children: [
                  // 動画は画面幅にそのまま追従させず、最大幅を決めて中央に置く。
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: AspectRatio(
                      aspectRatio: 16 / 9.5,
                      child: _videoController.value.isInitialized
                          //動画再生部分
                          ? Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                VideoPlayer(_videoController),
                                // 流れる鳴き声コメント。
                                // ClipRect はプラットフォームビュー(video)上の
                                // オーバーレイ描画に効かないことがあるため、
                                // CustomPaint 内でキャンバスをクリップして
                                // 動画の外へはみ出さないように描画する。
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _FlowingOnomatopoeiaPainter(
                                      comments: widget
                                          .selectedAnimal.onomatopoeiaList,
                                      offsets: offsetList,
                                    ),
                                  ),
                                ),
                                // タップで再生・停止ボタンの表示を切り替える。
                                // Web では video 要素がタップを吸わないよう
                                // index.html 側で pointer-events を無効化している。
                                Positioned.fill(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _toggleControls,
                                  ),
                                ),
                                Visibility(
                                  visible: _onTouch,
                                  child: Center(
                                    child: MaterialButton(
                                      padding: const EdgeInsets.all(15), //パディング
                                      color: Colors.black38, //背景色
                                      textColor: Colors.white, //アイコンの色
                                      shape: const CircleBorder(), //丸
                                      onPressed: _togglePlayPause,
                                      child: Icon(
                                        _videoController.value.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                    ),
                                  ),
                                ),
                                VideoProgressIndicator(_videoController,
                                    allowScrubbing: true),
                              ],
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
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
                  SizedBox(
                    width: 245,
                    child: Text(
                      '動画：${widget.selectedAnimal.informationOnVideo}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AnimalOnomatopoeiaColor.gray1,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isPosting ? null : _showPostDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AnimalOnomatopoeiaColor.blue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AnimalOnomatopoeiaColor.blue.withOpacity(0.5),
                          disabledForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: isPosting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.edit),
                        label: const Text(
                          'きこえた鳴き声を投稿する',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Wrap(
                  //   alignment: WrapAlignment.center,
                  //   spacing: 16,
                  //   children: [
                  //     ElevatedButton(
                  //       onPressed: () async {
                  //         _videoController.pause();
                  //         isStop = true;
                  //         setState(() {});

                  //         await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  //           return AnimalQuestion(
                  //             animal: widget.selectedAnimal,
                  //             forChild: false,
                  //           );
                  //         }));
                  //       },
                  //       child: const Text('大人用アンケートに答える'),
                  //     ),
                  //     ElevatedButton(
                  //       onPressed: () async {
                  //         _videoController.pause();
                  //         isStop = true;
                  //         setState(() {});
                  //         await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  //           return AnimalQuestion(
                  //             animal: widget.selectedAnimal,
                  //             forChild: true,
                  //           );
                  //         }));
                  //       },
                  //       child: const Text('こども用アンケートに答える'),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '${widget.selectedAnimal.name}さんの気持ちわかるかな？',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // 画面幅に応じて列数を切り替える。
                        // 狭い端末では1列、広い画面（600px以上）では2列で表示する。
                        final crossAxisCount =
                            constraints.maxWidth >= 600 ? 2 : 1;
                        const spacing = 20.0;
                        final tileWidth = crossAxisCount == 1
                            ? constraints.maxWidth
                            : (constraints.maxWidth -
                                    spacing * (crossAxisCount - 1)) /
                                crossAxisCount;
                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (final animalSound
                                in widget.selectedAnimal.animalSounds)
                              SizedBox(
                                width: tileWidth,
                                child: _AnimalSoundTile(
                                  image:
                                      // isOffline
                                      //     ? Image.file(
                                      //         File(animalSound.imageUrl),
                                      //         fit: BoxFit.cover,
                                      //       )
                                      //     :
                                      Image.network(
                                    animalSound.imageUrl,
                                    fit: BoxFit.cover,
                                    // Web で Storage の CORS 設定がなくても表示できるようにする
                                    webHtmlElementStrategy:
                                        WebHtmlElementStrategy.fallback,
                                  ),
                                  breed: animalSound.breed,
                                  title: animalSound.title,
                                  subtitle: animalSound.subtitle,
                                  onTap: () async {
                                    _videoController.pause();
                                    isStop = true;
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => SoundPage(
                                            selectedAnimalSound: animalSound),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimalSoundTile extends StatelessWidget {
  const _AnimalSoundTile({
    required this.image,
    required this.breed,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Image image;
  final String breed;
  final String title;
  final String subtitle;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: AnimalOnomatopoeiaColor.clearBlack,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onTap,
                child: image,
              ),
            ),
            const SizedBox(
              width: 40,
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    breed,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      color: AnimalOnomatopoeiaColor.clearWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Text(
                    '音源',
                    style: TextStyle(
                      color: AnimalOnomatopoeiaColor.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 動画の上を流れる鳴き声コメントを描画する。
///
/// ClipRect はプラットフォームビュー(video)上のオーバーレイ描画に
/// 効かないことがあるため、キャンバス自体をクリップして
/// コメントが動画の外へはみ出さないようにする。
class _FlowingOnomatopoeiaPainter extends CustomPainter {
  _FlowingOnomatopoeiaPainter({
    required this.comments,
    required this.offsets,
  });

  final List<String> comments;
  final List<Offset> offsets;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final count = min(comments.length, offsets.length);
    for (var index = 0; index < count; index++) {
      final alignment = offsets[index];

      final fillPainter = TextPainter(
        text: TextSpan(
          text: comments[index],
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 400);
      final strokePainter = TextPainter(
        text: TextSpan(
          text: comments[index],
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 400);

      // 以前の Align + OverflowBox と同じ位置になるように座標を計算する。
      final anchor = Offset(
        (size.width - 32) * (alignment.dx + 1) / 2,
        (size.height - 1) * (alignment.dy + 1) / 2,
      );
      final boxWidth = max(100.0, fillPainter.width);
      final topLeft = Offset(
        anchor.dx + 16 - boxWidth / 2,
        anchor.dy + 0.5 - 40,
      );
      strokePainter.paint(canvas, topLeft);
      fillPainter.paint(canvas, topLeft);
    }
  }

  @override
  bool shouldRepaint(covariant _FlowingOnomatopoeiaPainter oldDelegate) => true;
}
