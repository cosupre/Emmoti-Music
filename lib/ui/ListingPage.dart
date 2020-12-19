import 'package:emoti_music/bloc/trackBloc/bloc.dart';
import 'package:emoti_music/main.dart';
import 'package:emoti_music/models/playlist.dart';
import 'package:emoti_music/models/track.dart';
import 'package:emoti_music/models/user.dart';
import 'package:flutter/material.dart';

class ListingPage extends StatefulWidget {
  ListingPage({Key key, @required this.snapshot, @required this.trackBloc, this.favoriteFirst = false})
      : super(key: key);

  final AsyncSnapshot<List<CustomTrack>> snapshot;
  final TrackBloc trackBloc;
  final bool favoriteFirst;

  @override
  _ListingPageState createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  CustomUser user = getIt<CustomUser>();
  CustomPlaylist playlist = getIt<CustomPlaylist>();

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
  void didUpdateWidget(covariant ListingPage oldWidget) {
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
        body: snapshot.hasData ? _buildTrackListing(snapshot.data) : Center(child: CircularProgressIndicator()));
  }

  Widget _buildTrackListing(List<CustomTrack> tracks) {
    if (favoriteFirst) {
      tracks = List.from(tracks);
      tracks.removeWhere((element) => !element.favorite);
    }
    return ListView.builder(
        itemBuilder: (BuildContext context, int itemPosition) => _buildTrackListTile(context, tracks, itemPosition),
        itemCount: tracks.length + 1);
  }

  Widget _buildTrackListTile(BuildContext context, List<CustomTrack> tracks, int index) {
    if (index == 0) {
      return Container(
        child: ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: null,
                backgroundColor: Colors.white24,
              ),
              Icon(
                Icons.add,
                size: 51,
                color: Colors.white,
              ),
            ],
          ),
          title: Text('Ajouter une musique'),
          subtitle: Text('via url spotify'),
          onTap: () {},
        ),
      );
    }
    index -= 1;

    CustomTrack track = tracks.elementAt(index);
    return Container(
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(track.imageUrl),
          backgroundColor: Colors.transparent,
        ),
        trailing: IconButton(
          onPressed: () {
            track.favorite = !track.favorite;
            trackBloc.updateTrack(track);
          },
          icon: Icon(
            track.favorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.red,
            size: 37,
          ),
        ),
        title: Text('${track.name}', maxLines: 2,),
        subtitle: Text(track.artists.join(', '), maxLines: 1,),
        onTap: () {},
      ),
    );
  }

  Widget _buildNoTracksPage() {
    return Center(child: Text('No tracks'));
  }
}
