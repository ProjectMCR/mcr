import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  Future<void> fetchAnimals() async {
    final snapshot = await animalQuery().get();
    animals = snapshot.docs.map((e) => e.data()).toList();
    animals.sort((a, b) => a.index.compareTo(b.index));
    setState(() {});
  }

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
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void initState() {
    super.initState();
    fetchAnimals();
    // Fired whenever a location is recorded
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      print('[location] - $location');
      final latitude = location.coords.latitude;
      final longitude = location.coords.longitude;

      const latitudeDestination = 35.1224305;
      const longitudeDestination = 136.2814251;

      final distance = distanceBetween(
          latitude, longitude, latitudeDestination, longitudeDestination);

      logs.add('[$distance location ${DateTime.now()}] - $location');
      setState(() {});

      if (distance < 10) {
        _flutterLocalNotificationsPlugin.show(
          0,
          '上山町集落センター',
          '到着しました！',
          null,
        );
      }
    });

    // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      print('[motionchange] - $location');
      logs.add('[motionchange ${DateTime.now()}] - $location');
      setState(() {});
    });

    // Fired whenever the state of location-services changes.  Always fired at boot
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      print('[providerchange] - $event');
      logs.add('[providerchange ${DateTime.now()}] - $event');
      setState(() {});
    });

    ////
    // 2.  Configure the plugin
    //
    bg.BackgroundGeolocation.ready(bg.Config(
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
            distanceFilter: 10.0,
            stopOnTerminate: false,
            startOnBoot: true,
            debug: true,
            logLevel: bg.Config.LOG_LEVEL_VERBOSE))
        .then((bg.State state) {
      if (!state.enabled) {
        ////
        // 3.  Start the plugin.
        //
        bg.BackgroundGeolocation.start();
      }
    });
    _initializeNotification();
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
            Container(
              color: Colors.grey.withOpacity(.3),
              height: 240,
              child: SingleChildScrollView(
                child: Text(logs.reversed.join('/')),
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
  double latitude1,
  double longitude1,
  double latitude2,
  double longitude2,
) {
  toRadians(double degree) => degree * pi / 180;
  const double r = 6378137.0; // 地球の半径
  final double f1 = toRadians(latitude1);
  final double f2 = toRadians(latitude2);
  final double l1 = toRadians(longitude1);
  final double l2 = toRadians(longitude2);
  final num a = pow(sin((f2 - f1) / 2), 2);
  final double b = cos(f1) * cos(f2) * pow(sin((l2 - l1) / 2), 2);
  final double d = 2 * r * asin(sqrt(a + b));
  return d;
}
