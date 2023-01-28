import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:mcr/main.dart';
import 'package:mcr/pages/question_page.dart';
import 'package:mcr/pages/settings_page.dart';
import 'package:mcr/pages/what_is_onomatopoeia_page.dart';
import 'package:mcr/repositories/animal_repositories.dart';

import '../colors.dart';
import '../models/animal.dart';
import 'animal_page.dart';
import 'question_for_child_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Animal> animals = [];

  final location = Location();
  bool serviceEnabled = false;
  PermissionStatus? permissionGranted;
  LocationData? locationData;

  StreamSubscription? sub;

  var isLoading = false;

  Future<void> _subscribeCurrentLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.enableBackgroundMode(enable: true);

    sub = location.onLocationChanged.listen((LocationData currentLocation) {
      pushNotificationForAnimal(currentLocation);
    });
  }

  Future<void> pushNotificationForAnimal(LocationData currentLocation) async {
    final currentLatitude = currentLocation.latitude;
    final currentLongitude = currentLocation.longitude;

    if (currentLatitude == null || currentLongitude == null) {
      return;
    }
    final currentGeoPoint = GeoPoint(
      currentLatitude,
      currentLongitude,
    );
    for (final animal in animals) {
      final distance = distanceBetween(
        currentGeoPoint,
        animal.geopoint,
      );
      logs.add('${animal.name} distance: $distance');
      setState(() {});
      if (distance < 15) {
        /// 中に入っている間は出さない
        if (inAnimalPointMap[animal] == false) {
          await showLocalNotification(
            title: '${animal.name}の近くです',
            body: 'アプリを開いて動画を見てみましょう',
            payload: animal.name,
          );
        }
        inAnimalPointMap[animal] = true;
      } else {
        inAnimalPointMap[animal] = false;
      }
    }
  }

  Future<void> _fetchAnimals() async {
    animals = await AnimalRepository().fetchAnimal();

    inAnimalPointMap = animals.asMap().map(
          (key, value) => MapEntry(value, false),
        );
    setState(() {});
  }

  var inAnimalPointMap = <Animal, bool>{};

  List<String> logs = [];

  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> _initializeNotification() async {
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettingsAndroid = AndroidInitializationSettings('ic_notification');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    final enable = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    if (enable == false) {
      return;
    }
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        print(response.payload);
        final animal = animals.firstWhereOrNull((element) => element.name == response.payload);
        if (animal == null) {
          return;
        }

        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return AnimalPage(selectedAnimal: animal);
        }));
      },
    );
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      null,
      payload: payload,
    );
  }

  Future<void> init() async {
    await _fetchAnimals();
    await _initializeNotification();
    await _subscribeCurrentLocation();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AnimalOnomatopoeiaColor.yellow,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 21),
                      SizedBox(
                        height: 120,
                        child: Image.asset(
                          'assets/images/main_title1.png',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WhatIsOnomatopoeiaPage(),
                          ),
                        ),
                        child: const Text(
                          'オノマトペとは',
                          style: TextStyle(
                            color: AnimalOnomatopoeiaColor.gray1,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: AnimalOnomatopoeiaColor.blue,
                            decorationThickness: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: screenWidth * 0.8,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: animals.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                          itemBuilder: (context, index) {
                            final animal = animals[index];
                            return _AnimalTile(
                              imageUrl: animal.imageUrl,
                              animalName: animal.name,
                              onTap: animal.onomatopoeiaVideoUrl.isNotEmpty
                                  ? () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => AnimalPage(selectedAnimal: animal),
                                        ),
                                      )
                                  : null,
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 48,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return QuestionForChildPage(
                                    animals: animals,
                                  );
                                }),
                              );
                            },
                            child: const Text('こども用アンケートに答える'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return QuestionPage(
                                    animals: animals,
                                  );
                                }),
                              );
                            },
                            child: const Text('大人用アンケートに答える'),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return const SettingsPage();
                          },
                        ),
                      );

                      // setState(() {
                      //   isLoading = true;
                      // });
                      // try {
                      //   await AnimalRepository().saveAnimals(animals);
                      // } catch (_) {
                      // } finally {
                      //   setState(() {
                      //     isLoading = false;
                      //   });
                      // }
                    },
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black38,
              alignment: Alignment.center,
              child: const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }
}

class _AnimalTile extends StatelessWidget {
  const _AnimalTile({
    Key? key,
    required this.onTap,
    required this.animalName,
    required this.imageUrl,
  }) : super(key: key);

  final void Function()? onTap;
  final String animalName;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: imageUrl.isNotEmpty
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: AnimalOnomatopoeiaColor.blue,
                      ),
                      if (isOffline)
                        Image.file(
                          File(imageUrl),
                          fit: BoxFit.cover,
                        )
                      else
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                    ],
                  )
                : Container(
                    color: AnimalOnomatopoeiaColor.blue,
                  ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    animalName,
                    style: const TextStyle(
                      color: AnimalOnomatopoeiaColor.gray1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double distanceBetween(
  GeoPoint geoPoint1,
  GeoPoint geoPoint2,
) {
  toRadians(double degree) => degree * pi / 180;
  const double r = 6378137.0; // 地球の半径
  final double f1 = toRadians(geoPoint1.latitude);
  final double f2 = toRadians(geoPoint2.latitude);
  final double l1 = toRadians(geoPoint1.longitude);
  final double l2 = toRadians(geoPoint2.longitude);
  final num a = pow(sin((f2 - f1) / 2), 2);
  final double b = cos(f1) * cos(f2) * pow(sin((l2 - l1) / 2), 2);
  final double d = 2 * r * asin(sqrt(a + b));
  return d;
}
