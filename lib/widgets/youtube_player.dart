import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubePlayer extends StatelessWidget {
  const YoutubePlayer({
    Key? key,
    required this.videoUrl,
    this.aspectRatio,
  }) : super(key: key);

  final String videoUrl;
  final double? aspectRatio;

  YoutubePlayerController _youtubePlayerController() {
    final splitUrl = videoUrl.split('/');
    final id = splitUrl[3];
    return YoutubePlayerController(
      initialVideoId: id,
      params: YoutubePlayerParams(
        loop: true,
        playlist: [id],
        interfaceLanguage: 'ja',
        autoPlay: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerControllerProvider(
      controller: _youtubePlayerController(),
      child: YoutubePlayerIFrame(
        aspectRatio: aspectRatio ?? 16 / 9,
      ),
    );
  }
}
