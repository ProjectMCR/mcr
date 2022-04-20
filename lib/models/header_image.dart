import 'package:cloud_firestore/cloud_firestore.dart';

class HeaderImage {
  HeaderImage({
    required this.docRef,
    required this.createdAt,
    required this.imageUrl,
  });

  factory HeaderImage.fromMap(Map<String, dynamic> data) => HeaderImage(
      docRef: data['docRef'],
      createdAt: data['createdAt'],
      imageUrl: data['imageUrl']);

  factory HeaderImage.initialData() => HeaderImage(
        docRef: FirebaseFirestore.instance.collection('headerImages').doc(),
        createdAt: Timestamp.now(),
        imageUrl: '',
      );

  DocumentReference docRef;
  Timestamp createdAt;
  String imageUrl;

  Map<String, dynamic> toMap() => {
        'docRef': docRef,
        'createdAt': createdAt,
        'imageUrl': imageUrl,
      };
}
