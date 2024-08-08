part of 'home_screen_bloc.dart';

@immutable
abstract class HomeScreenState {
  final Video? video;

  HomeScreenState({required this.video});
}

final class HomeScreenInitial extends HomeScreenState {
  HomeScreenInitial({required super.video});
}

final class HomeScreenWrongUrl extends HomeScreenState {
  HomeScreenWrongUrl({required super.video});
}

final class HomeScreenLoading extends HomeScreenState {
  HomeScreenLoading({required super.video});
}

final class HomeScreenGetVideo extends HomeScreenState {
  HomeScreenGetVideo({required super.video});
}

final class HomeScreenGetFile extends HomeScreenState {
  final File file;
  final bool doneCut;

  HomeScreenGetFile(
      {required this.file, required super.video, required this.doneCut});
}
