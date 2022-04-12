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
  final List<Widget> _carouselSliderItems = [
    Image.asset('assets/images/landscape1.png'),
    const Placeholder(color: Colors.tealAccent),
    const Placeholder(color: Colors.purple),
    const Placeholder(color: Colors.green),
    const Placeholder(color: Colors.pink),
    const Placeholder(color: Colors.red),
    const Placeholder(color: Colors.orangeAccent),
  ];
  final _dotsIndex = [0, 1, 2, 3, 4, 5, 6];
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 240.9,
                    viewportFraction: 1.0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                  items: _carouselSliderItems,
                ),
                Positioned.fill(
                  child: Align(
                    alignment: const Alignment(0, 0.79),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _dotsIndex.map(
                        (dotIndex) {
                          return dotIndex == _currentImageIndex
                              ? const _SelectedDot()
                              : const _UnSelectedDot();
                        },
                      ).toList(),
                    ),
                  ),
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
                      onTap: () {
                        // TODO(shimizu-saffle): HomePageに戻る
                      },
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
