import 'package:cloud_firestore/cloud_firestore.dart';

class Animal {
  Animal({
    required this.animalRef,
    required this.name,
    required this.onomatopoeiaMovieUrl,
  });

  factory Animal.fromMap(Map<String, dynamic> data) => Animal(
        animalRef: data['animalRef'],
        name: data['name'],
        onomatopoeiaMovieUrl: data['onomatopoeiaMovieUrl'],
      );

  factory Animal.initialData() => Animal(
        animalRef: FirebaseFirestore.instance.collection('animals').doc(),
        name: '',
        onomatopoeiaMovieUrl: '',
      );

  DocumentReference animalRef;
  String name;
  String onomatopoeiaMovieUrl;

  Map<String, dynamic> toMap() => {
        'animalRef': animalRef,
        'name': name,
        'onomatopoeiaMovieUrl': onomatopoeiaMovieUrl,
      };
}
