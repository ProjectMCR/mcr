import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubePlayer extends StatelessWidget {
  const YoutubePlayer({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  final String videoUrl;

  YoutubePlayerController _youtubePlayerController() {
    final splitUrl = videoUrl.split('/');
    final id = splitUrl[3];
    return YoutubePlayerController(
      initialVideoId: id,
      params: const YoutubePlayerParams(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerControllerProvider(
      controller: _youtubePlayerController(),
      child: const YoutubePlayerIFrame(),
    );
  }
}
