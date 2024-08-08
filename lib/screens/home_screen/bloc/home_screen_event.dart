part of 'home_screen_bloc.dart';

@immutable
abstract class HomeScreenEvent {}

class HomeScreenLoadVideoEvent extends HomeScreenEvent {
  final String videoUrl;

  HomeScreenLoadVideoEvent({required this.videoUrl});
}

class HomeScreenResetEvent extends HomeScreenEvent {}

class HomeScreenDownloadAllVideoEvent extends HomeScreenEvent {}

class HomeScreenDownloadAllAudioEvent extends HomeScreenEvent {}

class HomeScreenDownloadCutAudioEvent extends HomeScreenEvent {
  final BuildContext context;

  final String start;
  final String end;

  HomeScreenDownloadCutAudioEvent(
      {required this.start, required this.end, required this.context});
}

class HomeScreenGetFileToCutEvent extends HomeScreenEvent {}

class HomeScreenSetRingtoneEvent extends HomeScreenEvent {
  final BuildContext context;

  HomeScreenSetRingtoneEvent({required this.context});
}
