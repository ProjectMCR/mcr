import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// idからGoogleDriveのDirectDownloadリンクを生成する
Uri generateDirectDownloadUrl(String id) {
  final baseUrl = Uri.parse('https://drive.google.com/uc');
  final resultUrl = baseUrl.replace(
    queryParameters: {
      'export': 'download',
      'id': id,
    },
  );
  return resultUrl;
}

class SampleVideoPage extends StatefulWidget {
  const SampleVideoPage({Key? key}) : super(key: key);
  @override
  _SampleVideoPageState createState() => _SampleVideoPageState();
}

class _SampleVideoPageState extends State<SampleVideoPage> {
  late VideoPlayerController _controller;

  /// コピーした元のリンク
  /// https://drive.google.com/file/d/1k76gmWXK7YPKKjdrtZpf5HMkJSm9QxT6/view?usp=sharing
  static const id = '1k76gmWXK7YPKKjdrtZpf5HMkJSm9QxT6';

  Future<void> initialize() async {
    _controller = VideoPlayerController.network(
      generateDirectDownloadUrl(id).toString(),
    );
    await _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const SizedBox.shrink(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (_controller.value.isPlaying) {
              await _controller.pause();
            } else {
              await _controller.play();
            }
            setState(() {});
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }
}
