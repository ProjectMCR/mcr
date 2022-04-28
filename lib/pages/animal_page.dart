import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:mcr/models/animal.dart';
import 'package:mcr/models/animal_sound.dart';

import '../colors.dart';
import '../widgets/youtube_player.dart';
import 'sound_page.dart';

class AnimalPage extends StatelessWidget {
  AnimalPage({
    Key? key,
    required this.selectedAnimal,
  }) : super(key: key);

  final Animal selectedAnimal;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Query<AnimalSound> animalSoundQuery(Animal selectedAnimal) {
    return _firebaseFirestore
        .collection('animals')
        .doc(selectedAnimal.animalRef.id)
        .collection('animalSounds')
        .orderBy('createdAt')
        .withConverter(
          fromFirestore: (snapshot, _) => AnimalSound.fromMap(snapshot.data()!),
          toFirestore: (animalSound, _) => animalSound.toMap(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 222.5,
                child: YoutubePlayer(
                  videoUrl: selectedAnimal.onomatopoeiaVideoUrl,
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
                  '動画：${selectedAnimal.informationOnVideo}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AnimalOnomatopoeiaColor.gray1,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${selectedAnimal.name}さんの気持ちわかるかな？',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FirestoreListView<AnimalSound>(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                query: animalSoundQuery(selectedAnimal),
                itemBuilder: (context, snapshot) {
                  final animalSound = snapshot.data();
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
