import 'dart:io';
import 'package:easy_ringtube/core/colors.dart';
import 'package:easy_ringtube/widgets/design/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioCutterWidget extends StatefulWidget {
  final File file;
  final Function((String, String)) onDoneCut;
  final VoidCallback onSetRingtone;
  final bool? onCutDownload;
  const AudioCutterWidget(
      {Key? key,
      required this.file,
      required this.onDoneCut,
      required this.onCutDownload,
      required this.onSetRingtone})
      : super(key: key);

  @override
  State<AudioCutterWidget> createState() => _AudioCutterWidgetState();
}

class _AudioCutterWidgetState extends State<AudioCutterWidget> {
  late File inputFile;
  final player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Duration start = Duration.zero;
  Duration end = Duration.zero;
  bool isCutting = false;

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
        end = d;
      });
    });

    player.onPositionChanged.listen((Duration p) {
      setState(() {
        position = p;
      });

      if (position >= end) {
        player.seek(start);
        player.play(DeviceFileSource(inputFile.path));
      }
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            topButtons(),
            topSlider(),
            Text('${_formatDuration(position)} / ${_formatDuration(end)}'),
            startSlider(),
            endSlider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AppButton(
                  text: "חתוך ושמור",
                  textSize: 16,
                  unfillColors: widget.onCutDownload ?? false,
                  onTap: () => widget.onDoneCut(
                      (_formatDuration(start), _formatDuration(end))),
                ),
                if (widget.onCutDownload ?? false)
                  AppButton(
                    text: "הפוך לצלצול",
                    textSize: 16,
                    onTap: () => widget.onSetRingtone.call(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row endSlider() {
    return Row(
      children: [
        Expanded(flex: 3, child: Text('סיום: ${_formatDuration(end)}')),
        Expanded(
          flex: 7,
          child: Slider(
            value: end.inSeconds.toDouble(),
            min: 0.0,
            max: duration.inSeconds.toDouble(),
            activeColor: AppColor.shadowColor,
            onChanged: (value) {
              setState(() {
                final newEnd = Duration(seconds: value.toInt());
                if (newEnd.inSeconds < start.inSeconds + 5) {
                  end = Duration(seconds: start.inSeconds + 5);
                } else {
                  end = newEnd;
                }
                if (position > end) {
                  position = end;
                  player.seek(position);
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Row startSlider() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text('התחלה: ${_formatDuration(start)}'),
        ),
        Expanded(
          flex: 7,
          child: Slider(
            value: start.inSeconds.toDouble(),
            min: 0.0,
            max: duration.inSeconds.toDouble(),
            activeColor: AppColor.shadowColor,
            onChanged: (value) {
              setState(() {
                final newStart = Duration(seconds: value.toInt());
                if (newStart.inSeconds > end.inSeconds - 5) {
                  start = Duration(seconds: end.inSeconds - 5);
                } else {
                  start = newStart;
                }
                if (position < start) {
                  position = start;
                  player.seek(position);
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Slider topSlider() {
    return Slider(
      value: position.inSeconds.toDouble(),
      min: start.inSeconds.toDouble(),
      max: end.inSeconds.toDouble(),
      activeColor: AppColor.primaryColor,
      onChanged: (value) {
        setState(() {
          position = Duration(seconds: value.toInt());
        });
        player.seek(position);
      },
    );
  }

  Row topButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        Row(
          children: [
            Text(
              isPlaying ? "Pause" : "Play",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: _onPlayPause,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              iconSize: 50,
            ),
          ],
        ),
        IconButton(
          onPressed: _resetDuration,
          icon: Icon(Icons.restart_alt_rounded),
        ),
      ],
    );
  }

  void _resetDuration() {
    start = Duration.zero;
    end = duration;
  }

  void _onPlayPause() {
    if (isPlaying) {
      player.pause();
    } else {
      player.seek(start);

      player.play(DeviceFileSource(inputFile.path));
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
