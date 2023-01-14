import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:mcr/pages/what_is_onomatopoeia_page.dart';

import '../colors.dart';
import '../models/animal.dart';
import 'animal_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Query<Animal> animalQuery() {
    return _firebaseFirestore.collection('animals').withConverter(
          fromFirestore: (snapshot, _) => Animal.fromMap(snapshot.data()!),
          toFirestore: (animal, _) => animal.toMap(),
        );
  }

  List<Animal> animals = [];

  final location = Location();
  bool serviceEnabled = false;
  PermissionStatus? permissionGranted;
  LocationData? locationData;

  StreamSubscription? sub;

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
      if (distance < 20) {
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
    final snapshot = await animalQuery().get();
    animals = snapshot.docs.map((e) => e.data()).toList();
    animals.sort((a, b) => a.index.compareTo(b.index));

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
    const initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        print(response.payload);
        final animal = animals
            .firstWhereOrNull((element) => element.name == response.payload);
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
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AnimalOnomatopoeiaColor.yellow,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 19),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 21),
                    Image.asset(
                      'assets/images/main_title1.png',
                      height: 153.51,
                      width: 205.95,
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
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: animals.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemBuilder: (context, index) {
                        final animal = animals[index];
                        return _AnimalTile(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          imageUrl: animal.imageUrl,
                          animalName: animal.name,
                          onTap: animal.onomatopoeiaVideoUrl
                                  .startsWith('https://')
                              ? () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AnimalPage(selectedAnimal: animal),
                                    ),
                                  )
                              : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (kDebugMode)
              Container(
                color: Colors.grey.withOpacity(.3),
                height: 240,
                child: SingleChildScrollView(
                  child: Text(logs.reversed.join('\n')),
                ),
              )
          ],
        ),
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
    required this.screenHeight,
    required this.screenWidth,
  }) : super(key: key);

  final void Function()? onTap;
  final String animalName;
  final String imageUrl;
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          if (!imageUrl.startsWith('https://'))
            Container(
              height: screenHeight / 6.9,
              width: screenWidth / 2.6,
              color: AnimalOnomatopoeiaColor.blue,
            ),
          if (imageUrl.startsWith('https://'))
            Stack(
              children: [
                Container(
                  height: screenHeight / 6.9,
                  width: screenWidth / 2.6,
                  color: AnimalOnomatopoeiaColor.blue,
                ),
                Image.network(
                  imageUrl,
                  height: screenHeight / 6.9,
                  width: screenWidth / 2.6,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          Container(
            height: screenHeight / 18.1,
            width: screenWidth / 2.6,
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
