import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mcr/models/animal.dart';
import 'package:mcr/models/animal_sound.dart';
import 'package:video_player/video_player.dart';

import '../colors.dart';

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
  // final Map<String, dynamic> mockData1 = {
  //   'imageUrl': 'assets/images/elephant/indian_elephant_attention.png',
  //   'breed': 'インドゾウ',
  //   'subtitle': 'てきがいるぞ',
  //   'title': '注意！（ちゅうい）',
  // };
  // final Map<String, dynamic> mockData2 = {
  //   'imageUrl': 'assets/images/elephant/indian_elephant_intimidate.png',
  //   'breed': 'インドゾウ',
  //   'subtitle': 'こっちにこないで',
  //   'title': '威嚇（いかく）',
  // };
  // final Map<String, dynamic> mockData3 = {
  //   'imageUrl': 'assets/images/elephant/african_elephant_anger.png',
  //   'breed': 'アフリカゾウ',
  //   'subtitle': 'けんかしている',
  //   'title': 'おこる',
  // };
  // final Map<String, dynamic> mockData4 = {
  //   'imageUrl': 'assets/images/elephant/african_elephant_spoiled.png',
  //   'breed': 'アフリカゾウ',
  //   'subtitle': 'おかあさんだいすき',
  //   'title': 'あまえる',
  // };
  // final Map<String, dynamic> mockData5 = {
  //   'imageUrl': 'assets/images/elephant/naumann_elephant.png',
  //   'breed': 'ナウマンゾウ',
  //   'subtitle': 'もうなかない',
  //   'title': '絶滅（ぜつめつ）',
  // };
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;

  /// サンプルのベタ書きUrl（象の動画）
  static const url =
      'https://drive.google.com/file/d/1Yppowk62uJyV-u7UUqta3eIc802GrSNx/view?usp=sharing';

  /// Google DriveのUrlを引数として、GoogleDriveのDirectDownloadリンクを返す。
  Uri generateDirectDownloadUrl(String url) {
    final splitUrl = url.split('/');
    final id = splitUrl[5];
    // 引数を共有リンクにして、共有リンクからidを抽出する処理を加える
    final baseUrl = Uri.parse('https://drive.google.com/uc');
    final resultUrl = baseUrl.replace(
      queryParameters: {
        'export': 'download',
        'id': id,
      },
    );
    return resultUrl;
  }

  Future<void> initialize() async {
    _videoPlayerController = VideoPlayerController.network(
      generateDirectDownloadUrl(url).toString(),
    );
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
    );
    if (mounted) {
      setState(() {});
    }
  }

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

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final mockDataList = [
    //   mockData1,
    //   mockData2,
    //   mockData3,
    //   mockData4,
    //   mockData5,
    // ];
    return SafeArea(
      child: Scaffold(
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
        body: Column(
          children: [
            SizedBox(
              height: 193.5,
              width: MediaQuery.of(context).size.width,
              child: _videoPlayerController.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: Chewie(controller: _chewieController),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
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
            const SizedBox(height: 20),
            Text(
              '${widget.selectedAnimal.name}さんの気持ちわかるかな？',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const Expanded(
              child: Placeholder(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalSoundTile extends StatelessWidget {
  const _AnimalSoundTile({
    Key? key,
    required this.image,
    required this.breed,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  }) : super(key: key);

  final Image image;
  final String breed;
  final String title;
  final String subtitle;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 348,
      color: AnimalOnomatopoeiaColor.clearBlack,
      child: Row(
        children: [
          const SizedBox(width: 6),
          image,
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                breed,
                style: const TextStyle(
                  color: AnimalOnomatopoeiaColor.clearWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onPressed,
                child: const Text(
                  '音源',
                  style: TextStyle(
                    color: AnimalOnomatopoeiaColor.blue,
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
