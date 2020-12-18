import 'package:emoti_music/main.dart';
import 'package:emoti_music/models/playlist.dart';
import 'package:emoti_music/models/track.dart';
import 'package:emoti_music/models/user.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as spot;

class ListingPage extends StatefulWidget {
  ListingPage({Key key, @required this.snapshot}) : super(key: key);

  final AsyncSnapshot<List<CustomTrack>> snapshot;

  @override
  _ListingPageState createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  spot.SpotifyApi spotify = getIt<spot.SpotifyApi>();
  CustomUser user = getIt<CustomUser>();
  CustomPlaylist playlist = getIt<CustomPlaylist>();

  AsyncSnapshot<List<CustomTrack>> snapshot;

  @override
  void initState() {
    snapshot = widget.snapshot;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ListingPage oldWidget) {
   if (snapshot != widget.snapshot) {
     setState(() {
       snapshot = widget.snapshot;
     });
   }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: snapshot.hasData ? _buildTrackListing(snapshot.data) : Center(child: CircularProgressIndicator()));
  }

  Widget _buildTrackListing(List<CustomTrack> tracks) {
    return tracks.length > 0
        ? ListView.separated(
            itemBuilder: (BuildContext context, int itemPosition) => _buildTrackListTile(context, tracks, itemPosition),
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemCount: tracks.length)
        : _buildNoTracksPage();
  }

  Widget _buildTrackListTile(BuildContext context, List<CustomTrack> tracks, int index) {
    CustomTrack track = tracks.elementAt(index);
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('${track.name}'),
          Text('${track.valence}'),
          Text('${track.energy}'),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildNoTracksPage() {
    return Center(child: Text('No tracks'));
  }
}
