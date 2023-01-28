import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mcr/main.dart';
import 'package:mcr/models/animal.dart';
import 'package:mcr/pages/animal_question_page.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:video_player/video_player.dart';

import '../colors.dart';
import 'sound_page.dart';

class AnimalPage extends StatefulWidget {
  const AnimalPage({
    Key? key,
    required this.selectedAnimal,
  }) : super(key: key);

  final Animal selectedAnimal;

  @override
  State<AnimalPage> createState() => _AnimalPageState();
}

class _AnimalPageState extends State<AnimalPage> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late VideoPlayerController _videoController;
  late NodeWithSize _rootNode;

  //動画の再生、停止用
  bool _onTouch = false;
  Timer? _timer;

  //鳴き声字幕が入るリスト
  static List onomatopoeiaList = [];

  /// video player初期化
  Future<void> initializeVideoPlayer() async {
    // TODO(kenta-wakasa): ビデオダウンロードと再生の仕組みを見直す
    final filePath = widget.selectedAnimal.onomatopoeiaVideoUrl;
    _videoController = isOffline
        ? VideoPlayerController.file(
            File(filePath),
          )
        : VideoPlayerController.network(
            widget.selectedAnimal.onomatopoeiaVideoUrl.toString(),
          );

    await _videoController.initialize();
    //初期化されたら、自動で再生する
    await _videoController.play();
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

    //  _rootNode = Scene(
    //   Size(
    //     200,
    //     200 / _videoController.value.aspectRatio,
    //   ),
    //   false,
    // );
  }

  var isStop = false;

  var offsetList = <Offset>[];

  final random = Random();

  void generateRandomValue() async {
    for (var index = 0; index < widget.selectedAnimal.onomatopoeiaList.length; index++) {
      offsetList.add(
        Offset(
          1 + random.nextDouble() * 10,
          -1 + 2 * random.nextDouble(),
        ),
      );
    }
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
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  _timer?.cancel();
                  setState(() {
                    _onTouch = !_onTouch;
                  });
                  //3秒したらボタン消える
                  _timer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
                    setState(() {
                      _onTouch = false;
                    });
                  });
                },
                child: AspectRatio(
                  aspectRatio: 16 / 9.5,
                  child: _videoController.value.isInitialized
                      //動画再生部分
                      ? Stack(alignment: Alignment.bottomCenter, children: [
                          VideoPlayer(_videoController),
                          for (var index = 0; index < widget.selectedAnimal.onomatopoeiaList.length; index++)
                            Align(
                              alignment: Alignment(
                                offsetList[index].dx,
                                offsetList[index].dy,
                              ),
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child: OverflowBox(
                                  minWidth: 100,
                                  maxWidth: 400,
                                  child: Stack(
                                    children: [
                                      Text(
                                        widget.selectedAnimal.onomatopoeiaList[index],
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          foreground: Paint()
                                            ..style = PaintingStyle.stroke
                                            ..strokeWidth = 1
                                            ..color = Colors.black,
                                        ),
                                      ),
                                      Text(
                                        widget.selectedAnimal.onomatopoeiaList[index],
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          Visibility(
                            visible: _onTouch,
                            child: Center(
                              child: MaterialButton(
                                child: Icon(
                                  _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 35,
                                ),
                                padding: const EdgeInsets.all(15), //パディング
                                color: Colors.black38, //背景色
                                textColor: Colors.white, //アイコンの色
                                shape: const CircleBorder(), //丸
                                onPressed: () {
                                  _timer?.cancel();

                                  // 再生、停止切り替え
                                  setState(() {
                                    if (_videoController.value.isPlaying) {
                                      _videoController.pause();
                                      isStop = true;
                                    } else {
                                      _videoController.play();
                                      isStop = false;
                                    }
                                  });

                                  // 3秒したらボタン消える
                                  _timer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
                                    setState(() {
                                      _onTouch = false;
                                    });
                                  });
                                },
                              ),
                            ),
                          ),
                          VideoProgressIndicator(_videoController, allowScrubbing: true),
                        ])
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
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        return AnimalQuestion(
                          animal: widget.selectedAnimal,
                          forChild: false,
                        );
                      }));
                    },
                    child: const Text('大人用アンケートに答える'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        return AnimalQuestion(
                          animal: widget.selectedAnimal,
                          forChild: true,
                        );
                      }));
                    },
                    child: const Text('こども用アンケートに答える'),
                  ),
                ],
              ),
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
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.selectedAnimal.animalSounds.length,
                itemBuilder: (context, index) {
                  final animalSound = widget.selectedAnimal.animalSounds[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: _AnimalSoundTile(
                      image: isOffline
                          ? Image.file(
                              File(animalSound.imageUrl),
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              animalSound.imageUrl,
                              fit: BoxFit.cover,
                            ),
                      breed: animalSound.breed,
                      title: animalSound.title,
                      subtitle: animalSound.subtitle,
                      onTap: () async {
                        _videoController.pause();
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SoundPage(selectedAnimalSound: animalSound),
                          ),
                        );
                        _videoController.play();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Scene extends NodeWithSize {
  late List<Label> _animalOnomatopoeiaLabelList;
  final _animalOnomatopoeia = _AnimalPageState.onomatopoeiaList;
  final bool isStop;
  Scene(
    Size size,
    this.isStop,
  ) : super(size) {
    _initialize();
  }

  void _initialize() {
    var _random = Random();
    var _labelIndex = 0.0;
    _animalOnomatopoeiaLabelList = _animalOnomatopoeia.map((text) {
      final label = Label(
        text,
        textAlign: TextAlign.left,
        textStyle: const TextStyle(fontSize: 12, color: Colors.black),
      );
      label.position = Offset(size.width + _labelIndex * 100.0, _random.nextDouble() * 100);
      _labelIndex += 1;

      return label;
    }).toList();

    for (var label in _animalOnomatopoeiaLabelList) {
      addChild(label);
    }
  }

  @override
  void update(double dt) {
    if (isStop) {
      return;
    }
    super.update(dt);
    for (var label in _animalOnomatopoeiaLabelList) {
      label.position = Offset(label.position.dx - 1, label.position.dy);

      if (label.position.dx < -900) {
        label.position = Offset(size.width, label.position.dy);
      }
    }
  }
}

class _AnimalSoundTile extends StatelessWidget {
  const _AnimalSoundTile({
    Key? key,
    required this.image,
    required this.breed,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

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
