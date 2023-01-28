import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mcr/main.dart';
import 'package:path/path.dart' as p;

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
              onPressed: () async {
                await uploadAll();
                showDialog(
                  context: context,
                  builder: (context) {
                    return const AlertDialog(
                      content: Text('アップロードしました'),
                    );
                  },
                );
              },
              child: const Text('全てアップロード'),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          ...answerFiles.map((e) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    p.basename(e.path),
                  ),
                  const Spacer(),
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
            );
          }).toList()
        ],
      ),
    );
  }
}
