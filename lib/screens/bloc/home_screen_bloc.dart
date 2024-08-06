import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'home_screen_event.dart';
part 'home_screen_state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final yt = YoutubeExplode();
  late Video? video;
  HomeScreenBloc() : super(HomeScreenInitial()) {
    on<HomeScreenLoadVideoEvent>(_homeScreenLoadVideoEvent);
    on<HomeScreenDownloadAllVideoEvent>(_homeScreenDownloadAllVideoEvent);
    on<HomeScreenDownloadAllAudioEvent>(_homeScreenDownloadAllAudioEvent);
  }

  FutureOr<void> _homeScreenLoadVideoEvent(
      HomeScreenLoadVideoEvent event, Emitter<HomeScreenState> emit) async {
    emit(HomeScreenLoading());
    video = await yt.videos.get(event.videoUrl);
    emit(HomeScreenGetVideo(video: video!));
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

  void downloadVideoOrAudio({required bool isAudio}) async {
    final storageStatus = await Permission.storage.request();
    await requestStoragePermission();
    if (storageStatus.isGranted) {
      final Directory? downloadsDir = await getDownloadsDirectory();

      final StreamManifest manifest =
          await yt.videos.streamsClient.getManifest(video!.id.value);
      dynamic streamInfo = isAudio
          ? manifest.audioOnly.withHighestBitrate()
          : manifest.muxed.withHighestBitrate();
      Stream<List<int>> stream = yt.videos.streamsClient.get(streamInfo);
      File file = File(
          '${downloadsDir!.path}/${video!.title}.${isAudio ? "mp3" : "mp4"}');
      IOSink fileStream = file.openWrite();

      await stream.pipe(fileStream);
      await fileStream.flush();
      await fileStream.close();
    }
  }

  Future<void> requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      log(name: "permission", "Permission granted");
    } else if (status.isDenied) {
      log(name: "permission", "Permission denied");
    } else if (status.isPermanentlyDenied) {
      log(name: "permission", "Permission permanently denied");
      // Open app settings to allow user to grant permission
      await openAppSettings();
    }
  }
}
