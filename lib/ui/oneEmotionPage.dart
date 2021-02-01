import 'package:emoti_music/models/track.dart';
import 'package:emoti_music/ui/widgets/emotionCircle.dart';
import 'package:flutter/material.dart';

class OneEmotionPage extends StatelessWidget {
  static const ROUTE_NAME = 'track-circle-one';

  OneEmotionPage({Key key, this.oneEmotionPageArguments}) : super(key: key);

  final OneEmotionPageArguments oneEmotionPageArguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return true;
        },
        child: Center(
          child: EmotionCircle(
            tracks: [oneEmotionPageArguments.track],
            onTap: (track) => {},
          ),
        ),
      ),
    );
  }
}

class OneEmotionPageArguments {
  final CustomTrack track;

  OneEmotionPageArguments(this.track);
}
