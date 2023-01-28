import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mcr/main.dart';
import 'package:mcr/repositories/settings_repository.dart';
import 'package:path/path.dart' as p;

import 'answer_detail_page.dart';

class AnswerListPage extends StatefulWidget {
  const AnswerListPage({super.key});

  @override
  State<AnswerListPage> createState() => _AnswerListPageState();
}

class _AnswerListPageState extends State<AnswerListPage> {
  List<File> get answerFiles => answerDir.listSync().whereType<File>().toList();

  Future<void> uploadAll() async {
    final answerRef = FirebaseStorage.instance.ref('answer');

    await Future.forEach(
      answerFiles,
      (file) => answerRef.child(p.basename(file.path)).putFile(file),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アンケート確認'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
              ),
              onPressed: SettingsRepository.instance.getOffline()
                  ? null
                  : () async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Center(
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                      await uploadAll();
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            content: Text('アップロードしました'),
                          );
                        },
                      );
                    },
              child: const Text('アップロード'),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          ...answerFiles.map((e) {
            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return AnswerDetailPage(file: e);
                  }),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        p.basename(e.path),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: const Text('本当に削除しますか？'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('キャンセル'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      e.delete();
                                      setState(() {});
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('削除'),
                                  ),
                                ],
                              );
                            });
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            );
          }).toList()
        ],
      ),
    );
  }
}
