import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:mcr/models/header_image.dart';

import '../colors.dart';

class WhatIsOnomatopoeiaPage extends StatelessWidget {
  const WhatIsOnomatopoeiaPage({Key? key}) : super(key: key);

  Query<HeaderImage> get headerImageQuery {
    return FirebaseFirestore.instance
        .collection('headerImages')
        .orderBy('createdAt', descending: true)
        .withConverter(
          fromFirestore: (snapshot, _) => HeaderImage.fromMap(snapshot.data()!),
          toFirestore: (headerImage, _) => headerImage.toMap(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                FirestoreQueryBuilder<HeaderImage>(
                  pageSize: 7,
                  query: headerImageQuery,
                  builder: (context, snapshot, _) {
                    if (snapshot.isFetching) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return CarouselSlider.builder(
                      itemCount: snapshot.docs.length,
                      itemBuilder: (context, index, _) {
                        final _scrollIndicatorDots = List.generate(
                            snapshot.docs.length, (index) => index);
                        final headerImage = snapshot.docs[index].data();
                        return Stack(
                          children: [
                            Image.network(headerImage.imageUrl),
                            if (snapshot.docs.length > 1)
                              Positioned.fill(
                                child: Align(
                                  alignment: const Alignment(0, 0.79),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: _scrollIndicatorDots.map(
                                      (dotIndex) {
                                        return dotIndex == index
                                            ? const _SelectedDot()
                                            : const _UnSelectedDot();
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                      options: CarouselOptions(
                        height: 240.9,
                        viewportFraction: 1.0,
                        scrollPhysics: snapshot.docs.length <= 1
                            ? const NeverScrollableScrollPhysics()
                            : const PageScrollPhysics(),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    top: 6,
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
