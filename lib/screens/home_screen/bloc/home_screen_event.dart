part of 'home_screen_bloc.dart';

@immutable
abstract class HomeScreenEvent {}

class HomeScreenLoadVideoEvent extends HomeScreenEvent {
  final String videoUrl;

  HomeScreenLoadVideoEvent({required this.videoUrl});
}

class HomeScreenDownloadAllVideoEvent extends HomeScreenEvent {}

class HomeScreenDownloadAllAudioEvent extends HomeScreenEvent {}

class HomeScreenDownloadCutAudioEvent extends HomeScreenEvent {
  final String start;
  final String end;

  HomeScreenDownloadCutAudioEvent({required this.start, required this.end});
}

class HomeScreenGetFileToCutEvent extends HomeScreenEvent {}
