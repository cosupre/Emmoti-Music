import 'package:emoti_music/bloc/trackBloc/bloc.dart';
import 'package:emoti_music/models/track.dart';
import 'package:emoti_music/ui/trackInfoPage.dart';
import 'package:emoti_music/ui/widgets/emotionCircle.dart';
import 'package:flutter/material.dart';

class EmotionMapPage extends StatefulWidget {
  EmotionMapPage({Key key, @required this.snapshot, @required this.trackBloc, this.favoriteFirst = false})
      : super(key: key);

  final AsyncSnapshot<List<CustomTrack>> snapshot;
  final TrackBloc trackBloc;
  final bool favoriteFirst;

  @override
  _EmotionMapPageState createState() => _EmotionMapPageState();
}

class _EmotionMapPageState extends State<EmotionMapPage> {
  AsyncSnapshot<List<CustomTrack>> snapshot;
  TrackBloc trackBloc;
  bool favoriteFirst = false;

  @override
  void initState() {
    snapshot = widget.snapshot;
    trackBloc = widget.trackBloc;
    favoriteFirst = widget.favoriteFirst;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant EmotionMapPage oldWidget) {
    if (snapshot != widget.snapshot || trackBloc != widget.trackBloc || favoriteFirst != widget.favoriteFirst) {
      setState(() {
        trackBloc = widget.trackBloc;
        snapshot = widget.snapshot;
        favoriteFirst = widget.favoriteFirst;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return true;
        },
        child: Center(
          child: snapshot.hasData
              ? Builder(
                  builder: (BuildContext context) {
                    var tracks = snapshot.data;
                    if (favoriteFirst) {
                      tracks = List.from(snapshot.data);
                      tracks.removeWhere((element) => !element.favorite);
                    }

                    return EmotionCircle(
                      tracks: tracks,
                      onTap: (track) => Navigator.pushNamed(context, TrackInfoPage.ROUTE_NAME,
                          arguments: TrackInfoPageArguments(track, trackBloc)),
                    );
                  },
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}
