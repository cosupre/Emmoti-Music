import 'package:emoti_music/main.dart';
import 'package:emoti_music/models/credentials.dart';
import 'package:emoti_music/models/playlist.dart';
import 'package:emoti_music/models/user.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as spot;
import 'package:spotify/spotify.dart';

class ChoosePlaylistPage extends StatefulWidget {
  static const ROUTE_NAME = '/playlist-selection';

  ChoosePlaylistPage({Key key, @required this.choosePlaylistPageArguments}) : super(key: key);

  final ChoosePlaylistPageArguments choosePlaylistPageArguments;

  @override
  _ChoosePlaylistPageState createState() => _ChoosePlaylistPageState();
}

class _ChoosePlaylistPageState extends State<ChoosePlaylistPage> {
  spot.Pages<spot.PlaylistSimple> _playlists;
  bool loading = false;

  spot.SpotifyApi spotify  = getIt<SpotifyApi>();
  CustomUser user = getIt<CustomUser>();
  CustomPlaylist oldPlaylist;

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<CustomPlaylist>()) oldPlaylist = getIt<CustomPlaylist>();
    _playlists = spotify.playlists.me;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Choisissez une playlist'),
        actions: widget.choosePlaylistPageArguments.disconnect != null
            ? [IconButton(icon: Icon(Icons.logout), onPressed: widget.choosePlaylistPageArguments.disconnect)]
            : null,
      ),
      body: loading ? Center(child: CircularProgressIndicator()) : getBody(),
    );
  }

  Widget getBody() {
    return StreamBuilder(
        stream: _playlists.stream(),
        builder: (BuildContext context, AsyncSnapshot<spot.Page<spot.PlaylistSimple>> snapshot) {
          return snapshot.hasData
              ? (snapshot.data.items.length > 0 ? _buildPlaylistListing(snapshot.data.items) : _noPlaylist())
              : Center(child: CircularProgressIndicator());
        });
  }

  Widget _noPlaylist() {
    return Center(child: Text('No playlist'));
  }

  Widget _buildPlaylistListing(Iterable<spot.PlaylistSimple> items) {
    return ListView.separated(
      itemBuilder: (BuildContext context, int itemPosition) => _buildListTile(context, itemPosition, items),
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemCount: items.length,
    );
  }

  Widget _buildListTile(BuildContext context, int itemPosition, Iterable<spot.PlaylistSimple> items) {
    spot.PlaylistSimple playlist = items.elementAt(itemPosition);
    return ListTile(
      title: Text('${playlist.name}'),
      selected: oldPlaylist != null && oldPlaylist.id == playlist.id,
      onTap: () async {
        CustomPlaylist newPlaylist = CustomPlaylist.fromPlaylistSimple(playlist);
        setState(() {
          loading = true;
        });
        await widget.choosePlaylistPageArguments.validate(newPlaylist);
        setState(() {
          loading = false;
        });
      },
    );
  }
}

class ChoosePlaylistPageArguments {
  final Function validate;
  final Function disconnect;

  ChoosePlaylistPageArguments({this.validate, this.disconnect});
}
