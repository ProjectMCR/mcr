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
    return _firebaseFirestore.collection('animals').orderBy('createdAt').withConverter(
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                SizedBox(
                  height: 160,
                  child: Image.asset('assets/images/main_title1.png'),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
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
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          crossAxisCount: 2,
                        ),
                        itemBuilder: (context, index) {
                          final animal = snapshot.docs[index].data();
                          return _AnimalTile(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            imageUrl: animal.imageUrl,
                            animalName: animal.name,
                            onTap: animal.onomatopoeiaVideoUrl != null
                                ? () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AnimalPage(selectedAnimal: animal),
                                      ),
                                    )
                                : null,
                          );
                        },
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
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
            AspectRatio(
              aspectRatio: 5 / 4,
              child: Container(
                color: AnimalOnomatopoeiaColor.blue,
              ),
            )
          else
            AspectRatio(
              aspectRatio: 5 / 4,
              child: Stack(
                children: [
                  Container(
                    color: AnimalOnomatopoeiaColor.blue,
                  ),
                  AspectRatio(
                    aspectRatio: 5 / 4,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          AspectRatio(
            aspectRatio: 5 / 1,
            child: Container(
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
          ),
        ],
      ),
    );
  }
}
