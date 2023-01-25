import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mcr/models/animal_sound.dart';
import 'package:video_player/video_player.dart';

import '../main.dart';

class SoundPage extends StatefulWidget {
  const SoundPage({
    Key? key,
    required this.selectedAnimalSound,
  }) : super(key: key);

  final AnimalSound selectedAnimalSound;

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  VideoPlayerController? _videoController;
  //動画の再生、停止用
  bool _onTouch = false;
  Timer? _timer;

  //video player初期化
  Future<void> initializeVideoPlayer() async {
    if (widget.selectedAnimalSound.videoUrl.isEmpty) {
      return;
    }

    _videoController = isOffline
        ? VideoPlayerController.file(
            File(widget.selectedAnimalSound.videoUrl),
          )
        : VideoPlayerController.network(
            widget.selectedAnimalSound.videoUrl,
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
    initializeVideoPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    _videoController?.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          backgroundColor: Colors.white,
          leadingWidth: 50,
          leading: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Image.asset(
                'assets/images/back_icon.png',
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.selectedAnimalSound.videoUrl.isNotEmpty)
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
                  child: SizedBox(
                      height: screenWidth,
                      child: _videoController?.value.isInitialized == true
                          ? Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                VideoPlayer(_videoController!),
                                Visibility(
                                  visible: _onTouch,
                                  child: Center(
                                    child: MaterialButton(
                                      child: Icon(
                                        _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
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
                                          _videoController!.value.isPlaying
                                              ? _videoController?.pause()
                                              : _videoController?.play();
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
                              ],
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            )),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 34),
                    Text(
                      widget.selectedAnimalSound.breed,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      widget.selectedAnimalSound.subtitle,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      widget.selectedAnimalSound.soundDescription,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
