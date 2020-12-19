import 'package:emoti_music/main.dart';
import 'package:emoti_music/models/playlist.dart';
import 'package:emoti_music/models/user.dart';
import 'package:emoti_music/ui/choosePlaylistPage.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, @required this.disconnect, @required this.registerPlaylist})
      : super(key: key);

  final Function disconnect;
  final Function registerPlaylist;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final CustomUser user = getIt<CustomUser>();
  CustomPlaylist playlist = getIt<CustomPlaylist>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(user.displayName),
              Text(user.email),
              Text('Playlist choisie: ${playlist.name}'),
              RaisedButton(
                child: Text('Change playlist'),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    ChoosePlaylistPage.ROUTE_NAME,
                    arguments: ChoosePlaylistPageArguments(
                        validate: (CustomPlaylist newPlaylist) async {
                          if (newPlaylist.id != playlist.id) {
                            widget.registerPlaylist(newPlaylist);
                            setState(() {
                              playlist = newPlaylist;
                            });
                          }
                          Navigator.pop(context);
                        },),
                  );
                },
              ),
              RaisedButton(
                child: Text('Log out'),
                onPressed: widget.disconnect,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
