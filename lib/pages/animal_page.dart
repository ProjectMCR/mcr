import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mcr/models/animal.dart';
import 'package:mcr/models/animal_sound.dart';
import 'package:video_player/video_player.dart';
import 'package:spritewidget/spritewidget.dart';


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
  VideoPlayerController? _videoController;
  late NodeWithSize _rootNode;

  //動画の再生、停止用
  bool _onTouch = false;
  Timer? _timer;

  // static List<String> list = ["a"];

  Query<AnimalSound> animalSoundQuery(Animal selectedAnimal) {
    return _firebaseFirestore
        .collection('animals')
        .doc(selectedAnimal.animalRef.id)
        .collection('animalSounds')
        .withConverter(
          fromFirestore: (snapshot, _) => AnimalSound.fromMap(snapshot.data()!),
          toFirestore: (animalSound, _) => animalSound.toMap(),
        );
  }

  List<AnimalSound> animalSounds = [];

  Future<void> fetchAnimalSounds() async {
    final snapshot = await animalSoundQuery(widget.selectedAnimal).get();
    animalSounds = snapshot.docs.map((e) => e.data()).toList();
    animalSounds.sort(((a, b) => a.index.compareTo(b.index)));
    setState(() {});
  }


//video player初期化
  Future<void> initializeVideoPlayer() async {
    _videoController = VideoPlayerController.network(
      widget.selectedAnimal.onomatopoeiaVideoUrl.toString(),
    );

    await _videoController?.initialize();
    //初期化されたら、自動で再生する
   await _videoController?.play();
    if (mounted) {
      setState(() {});
    }
     //ループ再生
    _videoController?.setLooping(true);

  }

  @override
  void initState() {
    super.initState();
    fetchAnimalSounds();
    initializeVideoPlayer();

    _rootNode = Scene(
      Size(
        200,
        200 / _videoController!.value.aspectRatio,
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AnimalOnomatopoeiaColor.yellow,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(30.0),
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
                  child:  _videoController != null && _videoController!.value.isInitialized
                  //動画再生部分
                      ? Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayer(_videoController!),
                            SpriteWidget(
                              _rootNode,
                              transformMode: SpriteBoxTransformMode.fixedWidth,
                            ),
                            Visibility(
                              visible: _onTouch,
                              child: Center(
                                child: MaterialButton(
                                  child: Icon(
                                    _videoController!.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                  padding: const EdgeInsets.all(15),//パディング
                                  color: Colors.black38, //背景色
                                  textColor: Colors.white, //アイコンの色
                                  shape: const CircleBorder(),//丸
                                  onPressed: () {
                                    _timer?.cancel();

                                    // 再生、停止切り替え
                                    setState(() {
                                      _videoController!.value.isPlaying ?
                                      _videoController!.pause() :
                                      _videoController!.play();
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
                            VideoProgressIndicator(_videoController!, allowScrubbing: true),
                          ])
                      : const Center(child: CircularProgressIndicator(),),
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
              Divider(
                color: AnimalOnomatopoeiaColor.blue,
                thickness: 2,
                indent: screenWidth / 3,
                endIndent: screenWidth / 3,
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
                itemCount: animalSounds.length,
                itemBuilder: (context, index) {
                  final animalSound = animalSounds[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: _AnimalSoundTile(
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      image: Image.network(
                        animalSound.imageUrl,
                        fit: BoxFit.cover,
                        height: screenHeight / 7.02777778,
                        width: screenWidth / 3.63888889,
                      ),
                      breed: animalSound.breed,
                      title: animalSound.title,
                      subtitle: animalSound.subtitle,
                      onTap: () => Navigator.of(context).push(
                        // print(widget.selectedAnimal.)
                        MaterialPageRoute(
                          builder: (context) =>
                              SoundPage(selectedAnimalSound: animalSound),
                        ),
                      ),
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
  // final _animalOnomatopoeia = _AnimalPageState.list;
  final _animalOnomatopoeia =
  ["むむーん","ふぉぉん","フェーン","エーン","ぱおーーん","プァーン","ふぅーふぅー","えんえーん","ピェオー　ピェオー","パオーン　パオーン"];

  Scene(Size size,) : super(size) {
    _initialize();
  }

  void _initialize() {
    final random = Random();
    var labelIndex = 0.0;
    _animalOnomatopoeiaLabelList = _animalOnomatopoeia.map((text) {
      final label = Label(
        text,
        textAlign: TextAlign.left,
        textStyle: const TextStyle(fontSize: 12, color: Colors.black),
      );
      label.position =
          Offset(size.width + labelIndex * 100.0, random.nextDouble() * 100 );
      labelIndex += 1;

      return label;
    }).toList();

    for (var label in _animalOnomatopoeiaLabelList) {
      addChild(label);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (var label in _animalOnomatopoeiaLabelList) {
      label.position = Offset(label.position.dx - 1, label.position.dy);

      if (label.position.dx <  - 900) {
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
    required this.screenHeight,
    required this.screenWidth,
  }) : super(key: key);

  final Image image;
  final String breed;
  final String title;
  final String subtitle;
  final void Function() onTap;
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight / 6.325,
      width: screenWidth / 1.12931034,
      color: AnimalOnomatopoeiaColor.clearBlack,
      child: Row(
        children: [
          const Spacer(flex: 6),
          InkWell(
            onTap: onTap,
            child: image,
          ),
          const Spacer(flex: 58),
          Expanded(
            flex: 136,
            child: InkWell(
              onTap: onTap,
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
          ),
          const Spacer(flex: 40),
        ],
      ),
    );
  }
}
