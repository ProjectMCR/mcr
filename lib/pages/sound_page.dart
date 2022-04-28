import 'package:flutter/material.dart';
import 'package:mcr/models/animal_sound.dart';

import '../widgets/youtube_player.dart';

class SoundPage extends StatelessWidget {
  const SoundPage({
    Key? key,
    required this.selectedAnimalSound,
  }) : super(key: key);

  final AnimalSound selectedAnimalSound;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: screenWidth,
                child: YoutubePlayer(
                  videoUrl: selectedAnimalSound.videoUrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 34),
                    Text(
                      selectedAnimalSound.breed,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      selectedAnimalSound.subtitle,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      selectedAnimalSound.soundDescription,
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
