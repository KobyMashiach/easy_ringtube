import 'package:easy_ringtube/core/consts.dart';
import 'package:easy_ringtube/core/text_styles.dart';
import 'package:easy_ringtube/widgets/audio_cutter.dart';
import 'package:easy_ringtube/screens/home_screen/bloc/home_screen_bloc.dart';
import 'package:easy_ringtube/widgets/cards/video_card.dart';
import 'package:easy_ringtube/widgets/design/buttons/app_button.dart';
import 'package:easy_ringtube/widgets/design/fields/app_textfields.dart';
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
  late TextEditingController urlController;

  @override
  void initState() {
    urlController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeScreenBloc(),
      child: BlocBuilder<HomeScreenBloc, HomeScreenState>(
        builder: (context, state) {
          final bloc = context.read<HomeScreenBloc>();
          return Scaffold(
            appBar: appAppBar(
                title: "מסך בית",
                actions: (state is HomeScreenInitial ||
                        state is HomeScreenWrongUrl)
                    ? null
                    : [
                        IconButton(
                            onPressed: () => bloc.add(HomeScreenResetEvent()),
                            icon: Icon(Icons.restart_alt_rounded))
                      ]),
            drawer: appSideMenu(context, index: 0),
            body: state is HomeScreenLoading
                ? const Center(child: CircularProgressIndicator())
                : state is HomeScreenInitial || state is HomeScreenWrongUrl
                    ? putUrlScreen(state, bloc)
                    : videoSelectedScreen(state, bloc),
          );
        },
      ),
    );
  }

  SingleChildScrollView videoSelectedScreen(
      HomeScreenState state, HomeScreenBloc bloc) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: state.video != null
              ? [
                  Text(
                    state.video!.title,
                    style: AppTextStyle().title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    state.video!.author,
                    style: AppTextStyle().description,
                  ),
                  const SizedBox(height: 24),
                  VideoPlayerCard(video: state.video!),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: AppButton(
                            text: "הורד סרטון",
                            unfillColors: true,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            onTap: () =>
                                bloc.add(HomeScreenDownloadAllVideoEvent())),
                      ),
                      Expanded(
                        child: AppButton(
                            text: "הורד אודיו",
                            unfillColors: true,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            onTap: () =>
                                bloc.add(HomeScreenDownloadAllAudioEvent())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                      text: "חיתוך אודיו",
                      onTap: () => bloc.add(HomeScreenGetFileToCutEvent())),
                  if (state is HomeScreenGetFile) ...[
                    const SizedBox(height: 24),
                    AudioCutterWidget(
                      file: state.file,
                      onDoneCut: (points) {
                        final String start = points.$1;
                        final String end = points.$2;
                        bloc.add(HomeScreenDownloadCutAudioEvent(
                            start: start, end: end));
                      },
                    ),
                  ],
                ]
              : [],
        ),
      ),
    );
  }

  Center putUrlScreen(HomeScreenState state, HomeScreenBloc bloc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              "הכנס כתובת URL של סרטון מהיוטיוב",
              style: AppTextStyle().title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            AppTextField(
              hintText: "כתובת URL",
              controller: urlController,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
                onPressed: () => urlController.clear(),
                child: Text("נקה כתובת url")),
            if (state is HomeScreenWrongUrl) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "הסרטון לא נמצא, נא נסה שנית.",
                    style: AppTextStyle().error,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            Text(
              "סרטון דוגמה: אייל גולן - פזמון אחר",
              style: AppTextStyle().description,
            ),
            const SizedBox(height: 12),
            AppButton(
              text: "לחץ כאן לדוגמה",
              unfillColors: true,
              padding: EdgeInsets.symmetric(horizontal: 80),
              onTap: () {
                bloc.add(HomeScreenLoadVideoEvent(videoUrl: tempVideoUrl));
                urlController.clear();
              },
            ),
            Spacer(),
            AppButton(
              text: "אישור",
              padding: EdgeInsets.zero,
              onTap: () {
                bloc.add(
                    HomeScreenLoadVideoEvent(videoUrl: urlController.text));
                urlController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}
