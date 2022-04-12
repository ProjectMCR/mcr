import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../colors.dart';

class OnomatopoeiaDescriptionPage extends StatefulWidget {
  const OnomatopoeiaDescriptionPage({Key? key}) : super(key: key);

  @override
  State<OnomatopoeiaDescriptionPage> createState() =>
      _OnomatopoeiaDescriptionPageState();
}

class _OnomatopoeiaDescriptionPageState
    extends State<OnomatopoeiaDescriptionPage> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  final List<Widget> carouselSliderItems = [
    const Placeholder(color: Colors.black),
    const Placeholder(color: Colors.tealAccent),
    const Placeholder(color: Colors.purple),
    const Placeholder(color: Colors.green),
    const Placeholder(color: Colors.pink),
    const Placeholder(color: Colors.red),
    const Placeholder(color: Colors.orangeAccent),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                  height: 198.0,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }),
              items: carouselSliderItems,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [1, 2, 3, 4, 5, 6, 7].asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                            .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                  ),
                );
              }).toList(),
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
