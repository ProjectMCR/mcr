import 'package:cloud_firestore/cloud_firestore.dart';

import 'animal_sound.dart';

/// 保存すべきこと
/// - onomatopoeiaVideoUrl
/// - imageUrl
class Animal {
  Animal({
    required this.createdAt,
    required this.name,
    required this.onomatopoeiaVideoUrl,
    required this.informationOnVideo,
    required this.imageUrl,
    required this.index,
    required this.onomatopoeiaList,
    required this.geopoint,
    required this.animalSounds,
  });

  factory Animal.fromMap(Map<String, dynamic> data) {
    return Animal(
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt']),
      name: data['name'],
      onomatopoeiaVideoUrl: data['onomatopoeiaVideoUrl'],
      informationOnVideo: data['informationOnVideo'],
      imageUrl: data['imageUrl'],
      index: data['index'] ?? -1,
      onomatopoeiaList: (data['onomatopoeiaList'] as List).map((e) => e as String).toList(),
      geopoint: (data['geopoint'] is GeoPoint)
          ? data['geopoint']
          : GeoPoint(
              double.parse((data['geopoint'] as String).split(',')[0]),
              double.parse((data['geopoint'] as String).split(',')[1]),
            ),
      animalSounds: (data['animalSounds'] as List)
          .map(
            (e) => AnimalSound.fromMap(
              Map.from(e),
            ),
          )
          .toList(),
    );
  }

  static Future<Animal> fromFirestore(Map<String, dynamic> data) async {
    final animalRef = data['animalRef'] as DocumentReference;

    final qs = await animalRef.collection('animalSounds').get();

    final animalSounds = qs.docs.map((e) => AnimalSound.fromMap(e.data())).toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    data['animalSounds'] = animalSounds.map((e) => e.toMap()).toList();
    return Animal.fromMap(data);
  }

  DateTime createdAt;
  String name;
  String onomatopoeiaVideoUrl;
  String informationOnVideo;
  String imageUrl;
  int index;
  List<String> onomatopoeiaList;
  GeoPoint geopoint;
  List<AnimalSound> animalSounds;

  Map<String, dynamic> toMap() => {
        'createdAt': createdAt.toIso8601String(),
        'name': name,
        'onomatopoeiaVideoUrl': onomatopoeiaVideoUrl,
        'informationOnVideo': informationOnVideo,
        'imageUrl': imageUrl,
        'index': index,
        'onomatopoeiaList': onomatopoeiaList,
        'geopoint': '${geopoint.latitude},${geopoint.longitude}',
        'animalSounds': animalSounds
            .map(
              (e) => e.toMap(),
            )
            .toList()
      };
}
