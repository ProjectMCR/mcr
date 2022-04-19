import 'package:flutter/material.dart';
import 'package:mcr/models/animal_sound.dart';

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
            const Placeholder(),
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
