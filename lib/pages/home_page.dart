import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:mcr/pages/what_is_onomatopoeia_page.dart';

import '../colors.dart';
import '../models/animal.dart';
import 'animal_page.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Query<Animal> animalQuery() {
    return _firebaseFirestore
        .collection('animals')
        .orderBy('createdAt')
        .withConverter(
          fromFirestore: (snapshot, _) => Animal.fromMap(snapshot.data()!),
          toFirestore: (animal, _) => animal.toMap(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AnimalOnomatopoeiaColor.yellow,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 21),
                Image.asset(
                  'assets/images/main_title1.png',
                  height: 153.51,
                  width: 205.95,
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WhatIsOnomatopoeiaPage(),
                    ),
                  ),
                  child: const Text(
                    'オノマトペとは',
                    style: TextStyle(
                      color: AnimalOnomatopoeiaColor.gray1,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AnimalOnomatopoeiaColor.blue,
                      decorationThickness: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                FirestoreQueryBuilder<Animal>(
                  query: animalQuery(),
                  builder: (context, snapshot, _) {
                    if (snapshot.isFetching) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.docs.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemBuilder: (context, index) {
                          final animal = snapshot.docs[index].data();
                          return _AnimalTile(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            imageUrl: animal.imageUrl,
                            animalName: animal.name,
                            onTap: animal.onomatopoeiaVideoUrl
                                    .startsWith('https://')
                                ? () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AnimalPage(selectedAnimal: animal),
                                      ),
                                    )
                                : null,
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimalTile extends StatelessWidget {
  const _AnimalTile({
    Key? key,
    required this.onTap,
    required this.animalName,
    required this.imageUrl,
    required this.screenHeight,
    required this.screenWidth,
  }) : super(key: key);

  final void Function()? onTap;
  final String animalName;
  final String imageUrl;
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          if (!imageUrl.startsWith('https://'))
            Container(
              height: screenHeight / 6.9,
              width: screenWidth / 2.6,
              color: AnimalOnomatopoeiaColor.blue,
            ),
          if (imageUrl.startsWith('https://'))
            Stack(
              children: [
                Container(
                  height: screenHeight / 6.9,
                  width: screenWidth / 2.6,
                  color: AnimalOnomatopoeiaColor.blue,
                ),
                Image.network(
                  imageUrl,
                  height: screenHeight / 6.9,
                  width: screenWidth / 2.6,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          Container(
            height: screenHeight / 18.1,
            width: screenWidth / 2.6,
            color: Colors.white,
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  animalName,
                  style: const TextStyle(
                    color: AnimalOnomatopoeiaColor.gray1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
