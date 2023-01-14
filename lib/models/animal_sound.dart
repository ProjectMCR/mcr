// 扱うデータはanimalsコレクションのサブコレクションanimalSoundsコレクションのドキュメント
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalSound {
  AnimalSound({
    required this.createdAt,
    required this.animalSoundRef,
    required this.imageUrl,
    required this.breed,
    required this.title,
    required this.subtitle,
    required this.videoUrl,
    required this.soundDescription,
    required this.index,
  });

  factory AnimalSound.fromMap(Map<String, dynamic> data) => AnimalSound(
        createdAt: data['createdAt'],
        animalSoundRef: data['animalSoundRef'],
        imageUrl: data['imageUrl'],
        breed: data['breed'],
        title: data['title'],
        subtitle: data['subtitle'],
        videoUrl: data['videoUrl'],
        soundDescription: data['soundDescription'],
        index: data['index'] ?? -1,
      );

  Timestamp createdAt;
  DocumentReference? animalSoundRef;
  String imageUrl;
  String breed;
  String title;
  String subtitle;
  String videoUrl;
  String soundDescription;
  int index;

  Map<String, dynamic> toMap() => {
        'createdAt': createdAt,
        'animalSoundRef': animalSoundRef,
        'imageUrl': imageUrl,
        'breed': breed,
        'title': title,
        'subtitle': subtitle,
        'videoUrl': subtitle,
        'soundDescription': soundDescription,
        'index': index,
      };
}
