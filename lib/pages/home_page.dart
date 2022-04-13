import 'package:flutter/material.dart';
import 'package:mcr/pages/animal_page.dart';
import 'package:mcr/pages/onomatopoeia_description_page.dart';

import '../colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnimalOnomatopoeiaColor.yellow,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          child: Column(
            children: [
              const SizedBox(height: 21),
              Image.asset(
                'assets/images/main_title1.png',
                height: 153.51,
                width: 205.95,
              ),
              const SizedBox(height: 16),
              const Text(
                'オノマトペ',
                style: TextStyle(
                  color: AnimalOnomatopoeiaColor.gray1,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AnimalOnomatopoeiaColor.blue,
                  decorationThickness: 2,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                children: [
                  _AnimalTile(
                    animalName: 'らいおん',
                    onTap: () {
                      // TODO(shimizu-saffle): 画面遷移
                    },
                  ),
                  _AnimalTile(
                    animalName: 'ぞう',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AnimalPage(),
                      ),
                    ),
                  ),
                  _AnimalTile(
                    animalName: 'ろば',
                    onTap: () {
                      // TODO(shimizu-saffle): 画面遷移
                    },
                  ),
                  _AnimalTile(
                    animalName: 'からす',
                    onTap: () {
                      // TODO(shimizu-saffle): 画面遷移
                    },
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OnomatopoeiaDescriptionPage(),
                    ),
                  ),
                  child: const Text(
                    'オノマトペとは',
                    style: TextStyle(
                      color: AnimalOnomatopoeiaColor.gray1,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            ],
          ),
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
  }) : super(key: key);

  final void Function() onTap;
  final String animalName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 110,
          width: 150,
          color: AnimalOnomatopoeiaColor.blue,
        ),
        Material(
          type: MaterialType.button,
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 42,
              width: 150,
              child: Center(
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
    );
  }
}
