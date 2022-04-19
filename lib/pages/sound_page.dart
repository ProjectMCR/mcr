import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:mcr/models/animal_sound.dart';
import 'package:video_player/video_player.dart';

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
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;

  Future<void> initializeVideoPlayerController() async {
    _videoPlayerController = VideoPlayerController.network(
      generateDirectDownloadUrl(widget.selectedAnimalSound.videoUrl).toString(),
    );
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
    );
    if (mounted) {
      setState(() {});
    }
  }

  /// Google DriveのUrlを引数として、GoogleDriveのDirectDownloadリンクを返す。
  Uri generateDirectDownloadUrl(String url) {
    final splitUrl = url.split('/');
    final id = splitUrl[5];
    final baseUrl = Uri.parse('https://drive.google.com/uc');
    final resultUrl = baseUrl.replace(
      queryParameters: {
        'export': 'download',
        'id': id,
      },
    );
    return resultUrl;
  }

  @override
  void initState() {
    super.initState();
    initializeVideoPlayerController();
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 34),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                widget.selectedAnimalSound.breed,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                widget.selectedAnimalSound.subtitle,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                widget.selectedAnimalSound.soundDescription,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
