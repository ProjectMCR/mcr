import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:mcr/main.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../models/animal.dart';

class AnimalRepository {
  FutureOr<List<Animal>> fetchAnimal() async {
    List<Animal> animals;
    if (isOffline) {
      animals = animalBox.values.map((e) {
        return Animal.fromMap(Map.from(e));
      }).toList();
    } else {
      final qs = await FirebaseFirestore.instance.collection('animals').get();
      animals = await Future.wait(
        qs.docs.map(
          (e) => Animal.fromFirestore(
            e.data(),
          ),
        ),
      );
    }
    animals.sort((a, b) => a.index.compareTo(b.index));
    return animals;
  }

  Future<void> saveAnimals(List<Animal> animals) async {
    final newAnimals = await saveAssets(animals);

    await Future.forEach(newAnimals, (e) async {
      final map = e.toMap();
      return animalBox.add(map);
    });
  }

  Future<List<Animal>> saveAssets(List<Animal> animals) async {
    final appDocDir = await getApplicationDocumentsDirectory();

    for (final animal in animals) {
      animal.imageUrl = (File(
        join(
          (appDocDir.path),
          animal.name,
          'animalImageUrl',
        ),
      )
            ..create(recursive: true)
            ..writeAsBytes(
              (await get(
                Uri.parse(
                  animal.imageUrl,
                ),
              ))
                  .bodyBytes,
            ))
          .path;

      animal.onomatopoeiaVideoUrl = (File(
        join(
          (appDocDir.path),
          animal.name,
          'onomatopoeiaVideoUrl',
        ),
      )
            ..create(recursive: true)
            ..writeAsBytes((await get(
              Uri.parse(
                animal.onomatopoeiaVideoUrl,
              ),
            ))
                .bodyBytes))
          .path;

      for (final sound in animal.animalSounds) {
        sound.imageUrl = (File(
          join(
            (appDocDir.path),
            animal.name,
            sound.title,
            'soundImageUrl',
          ),
        )
              ..create(recursive: true)
              ..writeAsBytes(
                (await get(
                  Uri.parse(sound.imageUrl),
                ))
                    .bodyBytes,
              ))
            .path;

        if (sound.videoUrl.isNotEmpty) {
          sound.videoUrl = (File(
            join(
              (appDocDir.path),
              animal.name,
              sound.title,
              'soundVideoUrl',
            ),
          )
                ..create(recursive: true)
                ..writeAsBytes(
                  (await get(
                    Uri.parse(sound.videoUrl),
                  ))
                      .bodyBytes,
                ))
              .path;
        }
      }
    }
    return animals;
  }
}
