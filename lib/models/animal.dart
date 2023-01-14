import 'package:cloud_firestore/cloud_firestore.dart';

import 'animal_sound.dart';

class Animal {
  Animal({
    required this.createdAt,
    required this.animalRef,
    required this.name,
    required this.onomatopoeiaVideoUrl,
    required this.informationOnVideo,
    required this.imageUrl,
    required this.index,
    required this.onomatopoeiaList,
    required this.geopoint,
    required this.animalSounds,
  });

  static Future<Animal> fromMap(Map<String, dynamic> data) async {
    final animalRef = data['animalRef'] as DocumentReference;

    final qs = await animalRef.collection('animalSounds').get();

    final animalSounds = qs.docs
        .map((e) => AnimalSound.fromMap(e.data()))
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    return Animal(
      createdAt: data['createdAt'],
      animalRef: data['animalRef'],
      name: data['name'],
      onomatopoeiaVideoUrl: data['onomatopoeiaVideoUrl'],
      informationOnVideo: data['informationOnVideo'],
      imageUrl: data['imageUrl'],
      index: data['index'] ?? -1,
      onomatopoeiaList: data['onomatopoeiaList'],
      geopoint: data['geopoint'],
      animalSounds: animalSounds,
    );
  }

  Timestamp createdAt;
  DocumentReference animalRef;
  String name;
  String onomatopoeiaVideoUrl;
  String informationOnVideo;
  String imageUrl;
  int index;
  List onomatopoeiaList;
  GeoPoint geopoint;
  List<AnimalSound> animalSounds;

  Map<String, dynamic> toMap() => {
        'createdAt': createdAt,
        'animalRef': animalRef,
        'name': name,
        'onomatopoeiaVideoUrl': onomatopoeiaVideoUrl,
        'informationOnVideo': informationOnVideo,
        'imageUrl': imageUrl,
        'index': index,
        'onomatopoeiaList': onomatopoeiaList,
        'geopoint': geopoint,
      };
}
