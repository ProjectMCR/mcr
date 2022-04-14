import 'package:flutter/material.dart';
import 'package:mcr/pages/sound_page.dart';
import 'package:video_player/video_player.dart';

import '../colors.dart';
import '../models/animal_sound.dart';

class AnimalPage extends StatefulWidget {
  const AnimalPage({Key? key}) : super(key: key);

  @override
  State<AnimalPage> createState() => _AnimalPageState();
}

class _AnimalPageState extends State<AnimalPage> {
  final Map<String, dynamic> mockData1 = {
    'imageUrl': 'assets/images/elephant/indian_elephant_attention.png',
    'breed': 'インドゾウ',
    'soundDescription': 'てきがいるぞ',
    'soundType': '注意！（ちゅうい）',
  };
  final Map<String, dynamic> mockData2 = {
    'imageUrl': 'assets/images/elephant/indian_elephant_intimidate.png',
    'breed': 'インドゾウ',
    'soundDescription': 'こっちにこないで',
    'soundType': '威嚇（いかく）',
  };
  final Map<String, dynamic> mockData3 = {
    'imageUrl': 'assets/images/elephant/african_elephant_anger.png',
    'breed': 'アフリカゾウ',
    'soundDescription': 'けんかしている',
    'soundType': 'おこる',
  };
  final Map<String, dynamic> mockData4 = {
    'imageUrl': 'assets/images/elephant/african_elephant_spoiled.png',
    'breed': 'アフリカゾウ',
    'soundDescription': 'おかあさんだいすき',
    'soundType': 'あまえる',
  };
  final Map<String, dynamic> mockData5 = {
    'imageUrl': 'assets/images/elephant/naumann_elephant.png',
    'breed': 'ナウマンゾウ',
    'soundDescription': 'もうなかない',
    'soundType': '絶滅（ぜつめつ）',
  };

  late VideoPlayerController _controller;

  /// コピーした元のリンク
  /// https://drive.google.com/file/d/1k76gmWXK7YPKKjdrtZpf5HMkJSm9QxT6/view?usp=sharing
  static const id = '1k76gmWXK7YPKKjdrtZpf5HMkJSm9QxT6';

  /// idからGoogleDriveのDirectDownloadリンクを生成する
  Uri generateDirectDownloadUrl(String id) {
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
    _controller = VideoPlayerController.network(
      generateDirectDownloadUrl(id).toString(),
    );
    await _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mockDataList = [
      mockData1,
      mockData2,
      mockData3,
      mockData4,
      mockData5,
    ];
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
              height: 208,
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const SizedBox.shrink(),
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
            const Text(
              'ぞうさんの気持ちわかるかな？',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.all(11.5),
                itemCount: mockDataList.length,
                itemBuilder: (context, index) {
                  final mockData = mockDataList[index];
                  final AnimalSound animalSound = AnimalSound.fromMap(mockData);
                  return _AnimalSoundTile(
                    image: Image.asset(
                      animalSound.imageUrl,
                      height: 108,
                      width: 108,
                    ),
                    breed: animalSound.breed,
                    title: animalSound.soundType,
                    subtitle: animalSound.soundDescription,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SoundPage(),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (_controller.value.isPlaying) {
              await _controller.pause();
            } else {
              await _controller.play();
            }
            setState(() {});
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
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
