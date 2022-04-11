class AnimalSound {
  AnimalSound({
    required this.imageUrl,
    required this.breed,
    required this.soundDescription,
    required this.soundType,
  });

  factory AnimalSound.fromMap(Map<String, dynamic> data) => AnimalSound(
        imageUrl: data['imageUrl'],
        breed: data['breed'],
        soundDescription: data['soundDescription'],
        soundType: data['soundType'],
      );

  factory AnimalSound.initialData() => AnimalSound(
        imageUrl: 'imageUrl',
        breed: 'breed',
        soundDescription: 'soundDescription',
        soundType: 'soundType',
      );

  String imageUrl;
  String breed;
  String soundDescription;
  String soundType;

  Map<String, dynamic> toMap() => {
        'imageUrl': imageUrl,
        'breed': breed,
        'soundDescription': soundDescription,
        'soundType': soundType,
      };
}
