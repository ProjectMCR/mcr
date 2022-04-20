import 'package:cloud_firestore/cloud_firestore.dart';

class Animal {
  Animal({
    required this.createdAt,
    required this.animalRef,
    required this.name,
    required this.onomatopoeiaVideoUrl,
    required this.informationOnVideo,
  });

  factory Animal.fromMap(Map<String, dynamic> data) => Animal(
        createdAt: data['createdAt'],
        animalRef: data['animalRef'],
        name: data['name'],
        onomatopoeiaVideoUrl: data['onomatopoeiaVideoUrl'],
        informationOnVideo: data['informationOnVideo'],
      );

  factory Animal.initialData() => Animal(
        createdAt: Timestamp.now(),
        animalRef: FirebaseFirestore.instance.collection('animals').doc(),
        name: '',
        onomatopoeiaVideoUrl: '',
        informationOnVideo: '',
      );

  Timestamp createdAt;
  DocumentReference animalRef;
  String name;
  String onomatopoeiaVideoUrl;
  String informationOnVideo;

  Map<String, dynamic> toMap() => {
        'createdAt': createdAt,
        'animalRef': animalRef,
        'name': name,
        'onomatopoeiaVideoUrl': onomatopoeiaVideoUrl,
        'informationOnVideo': informationOnVideo,
      };
}
