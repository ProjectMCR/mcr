import 'package:flutter/material.dart';
import 'package:mcr/models/animal_sound.dart';

import '../widgets/youtube_player.dart';

class SoundPage extends StatelessWidget {
  const SoundPage({
    Key? key,
    required this.selectedAnimalSound,
  }) : super(key: key);

  final AnimalSound selectedAnimalSound;

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
              height: 350,
              child: YoutubePlayer(
                videoUrl: selectedAnimalSound.videoUrl,
              ),
            ),
            const SizedBox(height: 34),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                selectedAnimalSound.breed,
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
                selectedAnimalSound.subtitle,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: SingleChildScrollView(
                  child: Text(
                    selectedAnimalSound.soundDescription,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
