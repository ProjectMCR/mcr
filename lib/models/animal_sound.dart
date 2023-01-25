// 扱うデータはanimalsコレクションのサブコレクションanimalSoundsコレクションのドキュメント
import 'package:cloud_firestore/cloud_firestore.dart';

/// 保存すべきこと
/// - imageUrl
/// - videoUrl
class AnimalSound {
  AnimalSound({
    required this.createdAt,
    required this.imageUrl,
    required this.breed,
    required this.title,
    required this.subtitle,
    required this.videoUrl,
    required this.soundDescription,
    required this.index,
  });

  factory AnimalSound.fromMap(Map<String, dynamic> data) => AnimalSound(
        createdAt: (data['createdAt'] is Timestamp)
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.parse(data['createdAt']),
        imageUrl: data['imageUrl'],
        breed: data['breed'],
        title: data['title'],
        subtitle: data['subtitle'],
        videoUrl: data['videoUrl'],
        soundDescription: data['soundDescription'],
        index: data['index'] ?? -1,
      );

  DateTime createdAt;
  String imageUrl;
  String breed;
  String title;
  String subtitle;
  String videoUrl;
  String soundDescription;
  int index;

  Map<String, dynamic> toMap() => {
        'createdAt': createdAt.toIso8601String(),
        'imageUrl': imageUrl,
        'breed': breed,
        'title': title,
        'subtitle': subtitle,
        'videoUrl': videoUrl,
        'soundDescription': soundDescription,
        'index': index,
      };
}
