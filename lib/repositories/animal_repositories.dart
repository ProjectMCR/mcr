import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
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
    await animalBox.clear();
    final newAnimals = await saveAssets(animals);

    await Future.forEach(newAnimals, (e) async {
      final map = e.toMap();
      return animalBox.add(map);
    });
  }

  final dio = Dio();

  Future<File> downloadMovie({
    required String url,
    required File file,
  }) async {
    await file.parent.create(recursive: true);
    await dio.download(url, file.path, onReceiveProgress: (rec, total) {
      print("Rec: $rec , Total: $total");
      print(((rec / total) * 100).toStringAsFixed(0) + "%");
    });

    return file;
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

      animal.onomatopoeiaVideoUrl = (await downloadMovie(
        url: animal.onomatopoeiaVideoUrl,
        file: File(
          join(
            (appDocDir.path),
            animal.name,
            'movie.mp4',
          ),
        ),
      ))
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
          sound.videoUrl = (await downloadMovie(
            url: sound.videoUrl,
            file: File(
              join(
                (appDocDir.path),
                animal.name,
                sound.title,
                'movie.mp4',
              ),
            ),
          ))
              .path;
        }
      }
    }
    return animals;
  }
}
