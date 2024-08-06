import 'dart:async';
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
    PermissionStatus status = await Permission.storage.status;
    if (status.isDenied) {
      Permission.storage.request();
    }
    PermissionStatus statusAfter = await Permission.storage.status;
    if (statusAfter.isGranted) {
      final Directory? downloadsDir = await getDownloadsDirectory();

      final StreamManifest manifest =
          await yt.videos.streamsClient.getManifest(video!.id.value);
      dynamic streamInfo = isAudio
          ? manifest.audioOnly.withHighestBitrate()
          : manifest.muxed.withHighestBitrate();
      Stream<List<int>> stream = yt.videos.streamsClient.get(streamInfo);
      File file = File('${downloadsDir!.path}/${video!.title}.mp4');
      IOSink fileStream = file.openWrite();

      await stream.pipe(fileStream);
      await fileStream.flush();
      await fileStream.close();
    }
  }
}
