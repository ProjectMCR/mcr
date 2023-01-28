import 'package:flutter/material.dart';
import 'package:mcr/pages/answer_list_page.dart';
import 'package:mcr/repositories/animal_repositories.dart';
import 'package:mcr/repositories/settings_repository.dart';

import '../models/animal.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.animals,
  });

  final List<Animal> animals;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> downloadAssets() async {
    if (SettingsRepository.instance.getOffline()) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('オンラインモードにしてください。'),
          );
        },
      );
      return;
    }
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return DownloadDialog(animals: widget.animals);
      },
    );
    await SettingsRepository.instance.putHasAssets(true);
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: Text('ダウンロードが完了しました。'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('アンケート結果の確認'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const AnswerListPage();
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_for_offline_outlined),
            title: const Text('アセットのダウンロード'),
            subtitle: SettingsRepository.instance.getHasAssets() ? const Text('ダウンロード済み') : const Text('未ダウンロード'),
            trailing: const Icon(Icons.download),
            onTap: () async {
              await downloadAssets();
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('オフラインモード'),
            subtitle: const Text('アセットの事前ダウンロードが必要です'),
            trailing: Switch(
              value: SettingsRepository.instance.getOffline(),
              onChanged: (value) async {
                if (value) {
                  if (!SettingsRepository.instance.getHasAssets()) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          content: Text('アセットのダウンロードをおこなってください。'),
                        );
                      },
                    );

                    return;
                  }
                  await SettingsRepository.instance.putOffline(true);
                  setState(() {});
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        content: Text('アプリの再起動をお願いします。'),
                      );
                    },
                  );
                } else {
                  await SettingsRepository.instance.putOffline(false);
                  setState(() {});
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        content: Text('アプリの再起動をお願いします。'),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}



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