part of 'home_screen_bloc.dart';

@immutable
abstract class HomeScreenState {}

final class HomeScreenInitial extends HomeScreenState {}

final class HomeScreenLoading extends HomeScreenState {}

final class HomeScreenGetVideo extends HomeScreenState {
  final Video video;

  HomeScreenGetVideo({required this.video});
}
