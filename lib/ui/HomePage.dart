import 'package:emoti_music/bloc/trackBloc/bloc.dart';
import 'package:emoti_music/main.dart';
import 'package:emoti_music/models/playlist.dart';
import 'package:emoti_music/models/track.dart';
import 'package:emoti_music/ui/ListingPage.dart';
import 'package:emoti_music/ui/SettingsPage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, @required this.disconnect, @required this.registerPlaylist}) : super(key: key);

  final Function disconnect;
  final Function registerPlaylist;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> pagesBuilder;
  final List<List<dynamic>> bottomBarItems = [
    [Icon(Icons.list), 'Musiques'],
    [Icon(Icons.map), 'Carte'],
    [Icon(Icons.settings), 'Settings']
  ];

  List<List<Widget>> actions;
  int pageIndex = 0;

  TrackBloc trackBloc;
  CustomPlaylist playlist = getIt<CustomPlaylist>();

  @override
  void initState() {
    trackBloc = TrackBloc(playlist.id);
    trackBloc.syncTracks(playlist.id).catchError((e) => print);
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
    CustomPlaylist playlist = getIt<CustomPlaylist>();
    actions = [
      [
        IconButton(icon: Icon(Icons.refresh), onPressed: () => trackBloc.syncTracks(playlist.id)),
      ],
      null,
      null
    ];

    return StreamBuilder(
      stream: trackBloc.tracks,
      builder: (BuildContext context, AsyncSnapshot<List<CustomTrack>> snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Emoti\' Music'),
            actions: actions[pageIndex],
          ),
          body: Builder(builder: (BuildContext context) {
            pagesBuilder = [
              ListingPage(snapshot: snapshot),
              ListingPage(snapshot: snapshot),
              SettingsPage(disconnect: widget.disconnect, registerPlaylist: registerPlaylist)
            ];
            return pagesBuilder[pageIndex];
          }),
          bottomNavigationBar: BottomNavigationBar(
              items: bottomBarItems.map((list) => BottomNavigationBarItem(icon: list[0], label: list[1])).toList(),
              currentIndex: pageIndex,
              selectedItemColor: Colors.blueAccent,
              onTap: (index) {
                setState(() {
                  pageIndex = index;
                });
              }),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
