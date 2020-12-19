import 'package:emoti_music/bloc/trackBloc/bloc.dart';
import 'package:emoti_music/main.dart';
import 'package:emoti_music/models/playlist.dart';
import 'package:emoti_music/models/track.dart';
import 'package:emoti_music/ui/ListingPage.dart';
import 'package:emoti_music/ui/SettingsPage.dart';
import 'package:emoti_music/ui/widgets/emotionCircle.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, @required this.disconnect, @required this.registerPlaylist}) : super(key: key);

  final Function disconnect;
  final Function registerPlaylist;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Function> pagesBuilder;
  final List<List<dynamic>> bottomBarItems = [
    [(BuildContext context, pageIndex) => Icon(pageIndex == 0 ? Icons.view_list : Icons.list), 'Playlist'],
    [(BuildContext context, pageIndex) => Icon(pageIndex == 1 ? Icons.map : Icons.map_outlined), 'Carte'],
    [(BuildContext context, pageIndex) => Icon(pageIndex == 2 ? Icons.settings : Icons.settings_outlined), 'Settings']
  ];
  List<Function> actions;

  int pageIndex = 0;

  TrackBloc trackBloc;
  CustomPlaylist playlist = getIt<CustomPlaylist>();
  bool favoriteFirst = false;

  @override
  void initState() {
    trackBloc = TrackBloc(playlist.id);
    trackBloc.syncTracks(playlist.id).catchError((e) => print);

    pagesBuilder = [
      (BuildContext context, snapshot, trackBloc, favoriteFirst) => ListingPage(
            snapshot: snapshot,
            trackBloc: trackBloc,
            favoriteFirst: favoriteFirst,
          ),
      (BuildContext context, snapshot, trackBloc, favoriteFirst) => EmotionCircle(
            snapshot: snapshot,
            trackBloc: trackBloc,
            favoriteFirst: favoriteFirst,
          ),
      (BuildContext context, snapshot, trackBloc, favoriteFirst) =>
          SettingsPage(disconnect: widget.disconnect, registerPlaylist: registerPlaylist),
    ];

    actions = [
      (favorite) => [
            IconButton(
                icon: Icon(favoriteFirst ? Icons.favorite : Icons.favorite_border_outlined),
                onPressed: () => setState(() {
                      favoriteFirst = !favorite;
                    })),
            IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    playlist = getIt<CustomPlaylist>();
                  });
                  trackBloc.syncTracks(playlist.id);
                }),
          ],
      (favorite) => [
            IconButton(
                icon: Icon(favoriteFirst ? Icons.favorite : Icons.favorite_border_outlined),
                onPressed: () => setState(() {
                      favoriteFirst = !favorite;
                    })),
            IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    playlist = getIt<CustomPlaylist>();
                  });
                  trackBloc.syncTracks(playlist.id);
                }),
          ],
      (favorite) => null
    ];

    super.initState();
  }

  void registerPlaylist(CustomPlaylist newPlaylist) async {
    if (newPlaylist.id != playlist.id) {
      await trackBloc.syncTracks(newPlaylist.id);
      widget.registerPlaylist(newPlaylist);
      setState(() {
        playlist = newPlaylist;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: trackBloc.tracks,
      builder: (BuildContext context, AsyncSnapshot<List<CustomTrack>> snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Emoti\' Music'),
            actions: actions[pageIndex](favoriteFirst),
          ),
          body: Builder(
              builder: (BuildContext context) => pagesBuilder[pageIndex](context, snapshot, trackBloc, favoriteFirst)),
          bottomNavigationBar: BottomNavigationBar(
            items: bottomBarItems
                .map((list) => BottomNavigationBarItem(
                    icon: Builder(builder: (BuildContext context) => list[0](context, pageIndex)), label: list[1]))
                .toList(),
            currentIndex: pageIndex,
            selectedItemColor: Colors.white,
            onTap: (index) {
              setState(() {
                pageIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}
