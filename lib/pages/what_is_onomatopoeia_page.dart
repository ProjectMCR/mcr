import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:mcr/models/header_image.dart';

import '../colors.dart';

class WhatIsOnomatopoeiaPage extends StatefulWidget {
  const WhatIsOnomatopoeiaPage({Key? key}) : super(key: key);

  @override
  State<WhatIsOnomatopoeiaPage> createState() => _WhatIsOnomatopoeiaPageState();
}

class _WhatIsOnomatopoeiaPageState extends State<WhatIsOnomatopoeiaPage> {
  List<int> scrollIndicatorDots = [];
  List<QueryDocumentSnapshot<HeaderImage>> snapshots = [];
  int currentScrollIndicatorIndex = 0;

  Query<HeaderImage> headerImageQuery() {
    return FirebaseFirestore.instance
        .collection('headerImages')
        .orderBy('createdAt')
        .withConverter(
          fromFirestore: (snapshot, _) => HeaderImage.fromMap(snapshot.data()!),
          toFirestore: (headerImage, _) => headerImage.toMap(),
        );
  }

  @override
  void initState() => super.initState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                FirestoreQueryBuilder<HeaderImage>(
                  query: headerImageQuery(),
                  builder: (context, snapshot, _) {
                    if (snapshot.isFetching) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    for (var doc in snapshot.docs) {
                      snapshots.add(doc);
                    }
                    scrollIndicatorDots = List<int>.generate(
                      snapshot.docs.length,
                      (index) => index,
                    );
                    return CarouselSlider(
                      items: [
                        Image.network(
                          snapshots[currentScrollIndicatorIndex]
                              .data()
                              .imageUrl,
                        ),
                      ],
                      options: CarouselOptions(
                        onPageChanged: (index, reason) {
                          setState(() {
                            reason;
                            currentScrollIndicatorIndex++;
                          });
                        },
                        height: 240.9,
                        viewportFraction: 1.0,
                        scrollPhysics: scrollIndicatorDots.length <= 1
                            ? const NeverScrollableScrollPhysics()
                            : const PageScrollPhysics(),
                      ),
                    );
                  },
                ),
                if (scrollIndicatorDots.length > 1)
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(0, 0.79),
                      child: _ScrollIndicator(
                        index: currentScrollIndicatorIndex,
                        scrollIndicatorDots: scrollIndicatorDots,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    top: 15,
                  ),
                  child: SizedBox(
                    height: 21,
                    width: 28,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Image.asset('assets/images/home_icon_white.png'),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(flex: 1),
            const Text(
              'オノマトペとは？',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(flex: 1),
            const Text(
              '自由な気持ちでオノマトペ',
              style: TextStyle(
                color: AnimalOnomatopoeiaColor.gray2,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            const Spacer(flex: 1),
            const Divider(
              color: AnimalOnomatopoeiaColor.blue,
              thickness: 2,
              indent: 155,
              endIndent: 155,
            ),
            const Spacer(flex: 1),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 26.8),
              child: Text(
                'オノマトペとは、自然界の音・声、物事の\n状態や動きなどを音(おん)で象徴的に表した\n語。音象徴語。擬音語・擬声語・擬態語など\nを意味します。\nここでは、きこえた音に対して自由な気持ちでオノマトペに置き換えてもらっています。よろしければ、こちらからご参加ください。',
                style: TextStyle(
                  color: AnimalOnomatopoeiaColor.gray2,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const Spacer(flex: 6),
          ],
        ),
      ),
    );
  }
}

class _ScrollIndicator extends StatelessWidget {
  const _ScrollIndicator({
    Key? key,
    required this.scrollIndicatorDots,
    required this.index,
  }) : super(key: key);

  final List scrollIndicatorDots;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: scrollIndicatorDots.map(
        (dotIndex) {
          return dotIndex == index
              ? const _SelectedDot()
              : const _UnSelectedDot();
        },
      ).toList(),
    );
  }
}

class _UnSelectedDot extends StatelessWidget {
  const _UnSelectedDot({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7.0,
      height: 7.0,
      margin: const EdgeInsets.symmetric(
        horizontal: 8.5,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white),
      ),
    );
  }
}

class _SelectedDot extends StatelessWidget {
  const _SelectedDot({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7.0,
      height: 7.0,
      margin: const EdgeInsets.symmetric(
        horizontal: 8.5,
      ),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }
}
