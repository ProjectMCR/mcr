import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class AnswerDetailPage extends StatefulWidget {
  const AnswerDetailPage({
    super.key,
    required this.file,
  });

  final File file;

  @override
  State<AnswerDetailPage> createState() => _AnswerDetailPageState();
}

class _AnswerDetailPageState extends State<AnswerDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(p.basename(widget.file.path)),
      ),
      body: InkWell(
        onTap: () {
          Clipboard.setData(
            ClipboardData(text: widget.file.readAsStringSync()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.file.readAsStringSync(),
          ),
        ),
      ),
    );
  }
}
