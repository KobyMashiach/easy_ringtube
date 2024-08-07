import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_ringtube/core/colors.dart';
import 'package:easy_ringtube/core/text_styles.dart';
import 'package:flutter/material.dart';

class AudioCutterWidget extends StatefulWidget {
  final File file;
  const AudioCutterWidget({Key? key, required this.file}) : super(key: key);

  @override
  State<AudioCutterWidget> createState() => _AudioCutterWidgetState();
}

class _AudioCutterWidgetState extends State<AudioCutterWidget> {
  late File inputFile;
  final player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    inputFile = widget.file;
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    player.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    player.onDurationChanged.listen((Duration d) {
      setState(() {
        duration = d;
      });
    });

    player.onPositionChanged.listen((Duration p) {
      setState(() {
        position = p;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _onPlayPause,
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 50,
              ),
              Text(
                isPlaying ? "עצור" : "נגן",
                style: AppTextStyle().cardTitle,
              ),
            ],
          ),
          Slider(
            value: position.inSeconds.toDouble(),
            min: 0.0,
            max: duration.inSeconds.toDouble(),
            activeColor: AppColor.primaryColor,
            onChanged: (value) {
              setState(() {
                position = Duration(seconds: value.toInt());
              });
              player.seek(position);
            },
          ),
          Text('${_formatDuration(position)} / ${_formatDuration(duration)}'),
        ],
      ),
    );
  }

  void _onPlayPause() {
    if (isPlaying) {
      player.pause();
    } else {
      player.play(DeviceFileSource(inputFile.path));
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
