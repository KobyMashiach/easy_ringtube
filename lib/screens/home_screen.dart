import 'package:easy_ringtube/core/consts.dart';
import 'package:easy_ringtube/core/text_styles.dart';
import 'package:easy_ringtube/screens/bloc/home_screen_bloc.dart';
import 'package:easy_ringtube/widgets/cards/video_card.dart';
import 'package:easy_ringtube/widgets/design/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:easy_ringtube/widgets/general/appbar.dart';
import 'package:easy_ringtube/widgets/general/side_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeScreenBloc()
        ..add(HomeScreenLoadVideoEvent(videoUrl: tempVideoUrl)),
      child: BlocBuilder<HomeScreenBloc, HomeScreenState>(
        builder: (context, state) {
          final bloc = context.read<HomeScreenBloc>();
          return Scaffold(
            appBar: appAppBar(title: "מסך בית"),
            drawer: appSideMenu(context, index: 0),
            body: state is! HomeScreenGetVideo
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            state.video.title,
                            style: AppTextStyle().title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            state.video.author,
                            style: AppTextStyle().description,
                          ),
                          const SizedBox(height: 24),
                          VideoPlayerCard(video: state.video),
                          const SizedBox(height: 24),
                          AppButton(
                              text: "הורד סרטון",
                              onTap: () =>
                                  bloc.add(HomeScreenDownloadAllVideoEvent())),
                          const SizedBox(height: 12),
                          AppButton(
                              text: "הורד אודיו",
                              unfillColors: true,
                              onTap: () =>
                                  bloc.add(HomeScreenDownloadAllAudioEvent())),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
