import 'package:easy_ringtube/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerCard extends StatefulWidget {
  final Video video;
  const VideoPlayerCard({super.key, required this.video});

  @override
  State<VideoPlayerCard> createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<VideoPlayerCard> {
  late YoutubePlayerController _controller;

  bool _isPlayerReady = false;

  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.id.value,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Container(
      constraints: BoxConstraints(maxHeight: screenSize.height * 0.6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColor.primaryColor,
          progressColors: const ProgressBarColors(
            playedColor: AppColor.primaryColor,
            handleColor: AppColor.shadowColor,
          ),
          onReady: () {},
        ),
      ),
    );
  }
}
