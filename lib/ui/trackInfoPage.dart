import 'package:emoti_music/bloc/trackBloc/bloc.dart';
import 'package:emoti_music/models/track.dart';
import 'package:emoti_music/ui/oneEmotionPage.dart';
import 'package:flutter/material.dart';

class TrackInfoPage extends StatefulWidget {
  static const ROUTE_NAME = 'track-info';

  TrackInfoPage({Key key, @required this.trackInfoPageArguments}) : super(key: key);

  final TrackInfoPageArguments trackInfoPageArguments;

  @override
  _TrackInfoPageState createState() => _TrackInfoPageState();
}

class _TrackInfoPageState extends State<TrackInfoPage> {
  CustomTrack track;
  TrackBloc trackBloc;

  @override
  void initState() {
    track = widget.trackInfoPageArguments.track;
    trackBloc = widget.trackInfoPageArguments.trackBloc;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TrackInfoPage oldWidget) {
    if (track != widget.trackInfoPageArguments.track || trackBloc != widget.trackInfoPageArguments.trackBloc) {
      setState(() {
        track = widget.trackInfoPageArguments.track;
        trackBloc = widget.trackInfoPageArguments.trackBloc;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var listTileHeader = ListTile(
      title: Text(
        '${track.name}',
        maxLines: 2,
      ),
      subtitle: Text(
        track.artists.join(', '),
        maxLines: 1,
      ),
      trailing: Column(
        children: [
          Text('${track.valence * 2 - 1}'),
          Text('${track.energy * 2 - 1}'),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              Navigator.pushNamed(context, OneEmotionPage.ROUTE_NAME, arguments: OneEmotionPageArguments(track));
            },
          )
        ],
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return true;
        },
        child: Column(
          children: [
            Container(
              color: Colors.black,
              child: listTileHeader,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(60),
                  child: Image(
                    image: NetworkImage(track.imageUrl),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: kBottomNavigationBarHeight + 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    track.favorite = !track.favorite;
                  });
                  trackBloc.updateTrack(track);
                },
                icon: Icon(
                  track.favorite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(380),
                  color: Colors.white,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrackInfoPageArguments {
  CustomTrack track;
  TrackBloc trackBloc;

  TrackInfoPageArguments(this.track, this.trackBloc);
}
