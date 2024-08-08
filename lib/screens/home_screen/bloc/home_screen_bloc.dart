import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:easy_ringtube/core/consts.dart';
import 'package:easy_ringtube/tests/ringtone_dialog.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'home_screen_event.dart';
part 'home_screen_state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final yt = YoutubeExplode();
  late Video? video;
  late File? file;
  HomeScreenBloc() : super(HomeScreenInitial(video: null)) {
    on<HomeScreenLoadVideoEvent>(_homeScreenLoadVideoEvent);
    on<HomeScreenDownloadAllVideoEvent>(_homeScreenDownloadAllVideoEvent);
    on<HomeScreenDownloadAllAudioEvent>(_homeScreenDownloadAllAudioEvent);
    on<HomeScreenDownloadCutAudioEvent>(_homeScreenDownloadCutAudioEvent);
    on<HomeScreenGetFileToCutEvent>(_homeScreenGetFileToCutEvent);
    on<HomeScreenResetEvent>(_homeScreenResetEvent);
    on<HomeScreenSetRingtoneEvent>(_homeScreenSetRingtoneEvent);
  }

  FutureOr<void> _homeScreenLoadVideoEvent(
      HomeScreenLoadVideoEvent event, Emitter<HomeScreenState> emit) async {
    emit(HomeScreenLoading(video: null));
    try {
      video = await yt.videos.get(event.videoUrl);
      emit(HomeScreenGetVideo(video: video!));
    } catch (e) {
      emit(HomeScreenWrongUrl(video: null));
    }
  }

  FutureOr<void> _homeScreenDownloadAllVideoEvent(
      HomeScreenDownloadAllVideoEvent event,
      Emitter<HomeScreenState> emit) async {
    downloadVideoOrAudio(isAudio: false);
  }

  FutureOr<void> _homeScreenDownloadAllAudioEvent(
      HomeScreenDownloadAllAudioEvent event,
      Emitter<HomeScreenState> emit) async {
    downloadVideoOrAudio(isAudio: true);
  }

  FutureOr<void> _homeScreenDownloadCutAudioEvent(
      HomeScreenDownloadCutAudioEvent event,
      Emitter<HomeScreenState> emit) async {
    // Create a completer to handle the asynchronous completion
    final completer = Completer<void>();

    // Perform the asynchronous operation
    await downloadVideoOrAudio(
      isAudio: true,
      isCut: true,
      start: event.start,
      end: event.end,
      doneCut: () {
        emit(HomeScreenGetFile(video: video, file: file!, doneCut: true));
        completer.complete();
      },
    );

    await completer.future;
  }

  FutureOr<void> _homeScreenGetFileToCutEvent(
      HomeScreenGetFileToCutEvent event, Emitter<HomeScreenState> emit) async {
    try {
      final storageStatus = await Permission.manageExternalStorage.request();
      if (!storageStatus.isGranted) {
        log('Storage permission not granted');
        return;
      }

      final Directory? downloadsDir = Directory(downloadPath);

      if (downloadsDir == null) {
        log('Downloads directory not found');
        return;
      }
      downloadVideoOrAudio(isAudio: true);

      String filePath = '${downloadsDir.path}/${video!.title}.mp3';
      file = File(filePath);
      emit(HomeScreenGetFile(video: video, file: file!, doneCut: false));
    } catch (e) {
      log('Error downloading video or audio: $e');
    }
  }

  Future<void> downloadVideoOrAudio({
    required bool isAudio,
    bool isCut = false,
    String? start,
    String? end,
    VoidCallback? doneCut,
  }) async {
    try {
      final storageStatus = await Permission.manageExternalStorage.request();
      if (!storageStatus.isGranted) {
        log('Storage permission not granted');
        return;
      }

      final Directory? downloadsDir = Directory(downloadPath);

      if (downloadsDir == null) {
        log('Downloads directory not found');
        return;
      }

      final StreamManifest manifest =
          await yt.videos.streamsClient.getManifest(video!.id.value);

      dynamic streamInfo = isAudio
          ? manifest.audioOnly.withHighestBitrate()
          : manifest.muxed.withHighestBitrate();

      Stream<List<int>> stream = yt.videos.streamsClient.get(streamInfo);

      String filePath =
          '${downloadsDir.path}/${video!.title}.${isAudio ? "mp3" : "mp4"}';
      File file = File(filePath);

      IOSink fileStream = file.openWrite();
      await stream.pipe(fileStream);
      await fileStream.flush();
      await fileStream.close();
      log('Download completed: $filePath');

      if (isAudio && isCut) {
        try {
          log("start: 00:$start end: 00:$end");
          String cutFilePath =
              '${downloadsDir.path}/${cutFilePathWithoutFinish(video!.title)}';

          log(cutFilePath);

          final command =
              '-i "$filePath" -ss 00:$start -to 00:$end "$cutFilePath".mp3';

          FFmpegKit.execute(command).then((session) async {
            final returnCode = await session.getReturnCode();

            if (ReturnCode.isSuccess(returnCode)) {
              log("FFmpeg process completed successfully.");
              doneCut!.call();
            } else if (ReturnCode.isCancel(returnCode)) {
              log("FFmpeg process cancel with return code $returnCode.");
            } else {
              log("FFmpeg process failed with return code $returnCode.");
            }
          });
        } catch (e) {
          log('Error during cutting process: $e');
        }
      }
    } catch (e) {
      log('Error downloading video or audio: $e');
    }
  }

  FutureOr<void> _homeScreenResetEvent(
      HomeScreenResetEvent event, Emitter<HomeScreenState> emit) {
    video = null;
    emit(HomeScreenInitial(video: null));
  }

  FutureOr<void> _homeScreenSetRingtoneEvent(
      HomeScreenSetRingtoneEvent event, Emitter<HomeScreenState> emit) {
    final filePath = '$downloadPath/${video!.title}.mp3';
    showRingtoneOptionsDialog(event.context, filePath);
  }
}
