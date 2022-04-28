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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                              Image.network(
                                headerImage.imageUrl,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                height: screenHeight / 3,
                              ),
                              if (snapshot.docs.length > 1)
                                Column(
                                  children: [
                                    SizedBox(height: screenHeight / 3.5),
                                    _ScrollIndicator(
                                      index: index,
                                      scrollIndicatorDots: _scrollIndicatorDots,
                                    ),
                                  ],
                                ),
                            ],
                          );
                        },
                        options: CarouselOptions(
                          height: screenHeight / 3,
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
              SizedBox(height: screenHeight / 50),
              const Text(
                'オノマトペとは？',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: screenHeight / 30),
              const Text(
                '自由な気持ちでオノマトペ',
                style: TextStyle(
                  color: AnimalOnomatopoeiaColor.gray2,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: screenHeight / 30),
              Divider(
                color: AnimalOnomatopoeiaColor.blue,
                thickness: 2,
                indent: screenWidth / 3,
                endIndent: screenWidth / 3,
              ),
              SizedBox(height: screenHeight / 30),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 26.8),
                child: Text(
                  'オノマトペとは、自然界の音・声、物事の状態や動きなどを音(おん)で象徴的に表した語。音象徴語。擬音語・擬声語・擬態語などを意味します。',
                  style: TextStyle(
                    color: AnimalOnomatopoeiaColor.gray2,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 26.8),
                child: Text(
                  'ここでは、きこえた音に対して自由な気持ちでオノマトペに置き換えてもらっています。よろしければ、こちらからご参加ください。',
                  style: TextStyle(
                    color: AnimalOnomatopoeiaColor.gray2,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScrollIndicator extends StatelessWidget {
  const _ScrollIndicator({
    Key? key,
    required List<int> scrollIndicatorDots,
    required this.index,
  })  : _scrollIndicatorDots = scrollIndicatorDots,
        super(key: key);

  final List<int> _scrollIndicatorDots;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _scrollIndicatorDots.map(
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
