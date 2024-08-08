import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:easy_ringtube/core/consts.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'home_screen_event.dart';
part 'home_screen_state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final yt = YoutubeExplode();
  late Video? video;
  HomeScreenBloc() : super(HomeScreenInitial(video: null)) {
    on<HomeScreenLoadVideoEvent>(_homeScreenLoadVideoEvent);
    on<HomeScreenDownloadAllVideoEvent>(_homeScreenDownloadAllVideoEvent);
    on<HomeScreenDownloadAllAudioEvent>(_homeScreenDownloadAllAudioEvent);
    on<HomeScreenDownloadCutAudioEvent>(_homeScreenDownloadCutAudioEvent);
    on<HomeScreenGetFileToCutEvent>(_homeScreenGetFileToCutEvent);
    on<HomeScreenResetEvent>(_homeScreenResetEvent);
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
    downloadVideoOrAudio(
        isAudio: true, isCut: true, start: event.start, end: event.end);
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

      final StreamManifest manifest =
          await yt.videos.streamsClient.getManifest(video!.id.value);

      dynamic streamInfo = manifest.audioOnly.withHighestBitrate();

      Stream<List<int>> stream = yt.videos.streamsClient.get(streamInfo);

      String filePath = '${downloadsDir.path}/${video!.title}.mp3';
      File file = File(filePath);
      emit(HomeScreenGetFile(video: video, file: file));
    } catch (e) {
      log('Error downloading video or audio: $e');
    }
  }

  void downloadVideoOrAudio(
      {required bool isAudio,
      bool isCut = false,
      String? start,
      String? end}) async {
    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

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
      if (isAudio && isCut) {
        try {
          String cutFilePath =
              '${downloadsDir.path}/${video!.title}_cut.${isAudio ? "mp3" : "mp4"}';

          log("start: 00:$start end: 00:$end");

          int rc = await _flutterFFmpeg.execute(
              '-i "$filePath" -ss 00:$start -to 00:$end "$cutFilePath"');

          if (rc == 0) {
            log("FFmpeg process completed successfully.");
          } else {
            log("FFmpeg process failed with return code $rc.");
          }

          File cutFile = File(cutFilePath);

          if (await cutFile.exists()) {
            log('Cut audio completed: $cutFilePath');
          } else {
            log('Failed to create cut file: $cutFilePath');
          }
        } catch (e) {
          log('Error during cutting process: $e');
        }
      }
      log('Download completed: $filePath');
    } catch (e) {
      log('Error downloading video or audio: $e');
    }
  }

  FutureOr<void> _homeScreenResetEvent(
      HomeScreenResetEvent event, Emitter<HomeScreenState> emit) {
    video = null;
    emit(HomeScreenInitial(video: null));
  }
}
