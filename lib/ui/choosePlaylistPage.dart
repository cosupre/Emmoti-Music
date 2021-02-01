import 'package:emoti_music/main.dart';
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

  spot.SpotifyApi spotify = getIt<SpotifyApi>();
  CustomUser user = getIt<CustomUser>();
  CustomPlaylist oldPlaylist;

  String newPlaylistName = '';

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
    return ListView.builder(
      itemBuilder: (BuildContext context, int itemPosition) => _buildListTile(context, itemPosition, items),
      itemCount: items.length + 1,
    );
  }

  Widget _buildCreatePlaylist(BuildContext context) {
    return Container(
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: null,
              backgroundColor: Colors.white24,
            ),
            Icon(
              Icons.add,
              size: 41,
              color: Colors.white,
            ),
          ],
        ),
        title: Text('Créer une playlist'),
        onTap: () {
          final _formKey = GlobalKey<FormState>();
          showDialog(
            context: context,
            child: AlertDialog(
              contentPadding: const EdgeInsets.all(8.0),
              content: Row(
                children: [
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        validator: (label) {
                          if (label == null || label.isEmpty) return 'Ce nom ne peut pas être vide';
                          return null;
                        },
                        onSaved: (label) {
                          newPlaylistName = label;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Annuler'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      Navigator.pop(context);
                      _formKey.currentState.save();

                      setState(() {
                        loading = true;
                      });

                      try {
                        Playlist playlist = await spotify.playlists.createPlaylist(user.id, newPlaylistName);
                        CustomPlaylist newPlaylist = CustomPlaylist.fromPlaylistSimple(playlist);

                        await widget.choosePlaylistPageArguments.validate(newPlaylist);
                      } catch (e) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Connection impossible'),
                          ),
                        );
                      }
                      setState(() {
                        loading = false;
                      });
                    }
                  },
                  child: Text('Valider'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildListTile(BuildContext context, int itemPosition, Iterable<spot.PlaylistSimple> items) {
    if (itemPosition == 0) {
      return _buildCreatePlaylist(context);
    }
    itemPosition -= 1;

    spot.PlaylistSimple playlist = items.elementAt(itemPosition);

    bool isCurrentPlaylist = oldPlaylist != null && oldPlaylist.id == playlist.id;
    return ListTile(
      title: Text('${playlist.name}'),
      selectedTileColor: Colors.grey[900],
      selected: isCurrentPlaylist,
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
