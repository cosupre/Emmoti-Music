import 'package:emoti_music/bloc/trackBloc/bloc.dart';
import 'package:emoti_music/main.dart';
import 'package:emoti_music/models/playlist.dart';
import 'package:emoti_music/models/track.dart';
import 'package:emoti_music/models/user.dart';
import 'package:emoti_music/ui/trackInfoPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:spotify/spotify.dart' as spot;

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
  spot.SpotifyApi spotify;

  @override
  void initState() {
    snapshot = widget.snapshot;
    trackBloc = widget.trackBloc;
    favoriteFirst = widget.favoriteFirst;

    spotify = getIt<spot.SpotifyApi>();

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
      body: Builder(
        builder: (BuildContext context) {
          if (snapshot.hasData) return _buildTrackListing(context, snapshot.data);
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildTrackListing(BuildContext context, List<CustomTrack> tracks) {
    if (favoriteFirst) {
      tracks = List.from(tracks);
      tracks.removeWhere((element) => !element.favorite);
    }
    return ListView.builder(
        itemBuilder: (BuildContext context, int itemPosition) => _buildTrackListTile(context, tracks, itemPosition),
        itemCount: tracks.length + 1);
  }

  Widget _buildAddTrackListTile(BuildContext context) {
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
        subtitle: Text('C\'est si facile'),
        onTap: () {
          showDialog(
            context: context,
            child: AlertDialog(
              contentPadding: const EdgeInsets.all(8.0),
              content: Row(
                children: [
                  Expanded(
                    child: TypeAheadField(
                      hideOnEmpty: true,
                      textFieldConfiguration: TextFieldConfiguration(
                        autofocus: true,
                        decoration: InputDecoration(labelText: 'Choose a Track', hintText: 'Write to see suggestions'),
                      ),
                      suggestionsCallback: (pattern) async {
                        if (pattern == null || pattern.isEmpty) return [];

                        List<CustomTrack> trackData = snapshot.hasData ? snapshot.data : [];

                        var search = await spotify.search
                            .get(pattern, types: [spot.SearchType.track])
                            .first(50)
                            .catchError((err) => print((err as spot.SpotifyException).message));

                        List result = [];
                        int index = 0;
                        while (result.length < 5) {
                          var element = search.elementAt(index);
                          List items = element.items.toList();
                          items.forEach((item) {
                            bool valid = true;
                            trackData.forEach((el) {
                              if (item.webId == el.webId) valid = false;
                            });
                            if (valid) result.add(item);
                          });

                          ++index;
                        }
                        search.forEach((element) {
                          List items = element.items.toList();
                          result.addAll(items);
                        });

                        List<String> trackIds = result.map<String>((e) => e.id).toList();
                        var features = await spotify.audioFeatures.list(trackIds);

                        List<CustomTrack> res = List<CustomTrack>.generate(
                            result.length,
                            (index) => CustomTrack.fromTrackAndFeature(
                                result.elementAt(index), features.elementAt(index), playlist.id));
                        trackData.forEach((element) {
                          res.removeWhere((el) => element.webId == el.webId);
                        });
                        return res;
                      },
                      itemBuilder: (context, dynamic suggestion) {
                        return ListTile(
                          title: Text(
                            '${suggestion.name}',
                            maxLines: 2,
                          ),
                          subtitle: Text(
                            suggestion.artists.join(', '),
                            maxLines: 1,
                          ),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(suggestion.imageUrl),
                            backgroundColor: Colors.transparent,
                          ),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        List<CustomTrack> trackData = snapshot.hasData ? snapshot.data : [];
                        var temp = List.from(trackData);
                        temp.removeWhere((element) => element.webId != suggestion.webId);
                        if (temp.isEmpty) {
                          trackBloc.createTrack(suggestion);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrackListTile(BuildContext context, List<CustomTrack> tracks, int index) {
    if (index == 0) {
      return _buildAddTrackListTile(context);
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
        title: Text(
          '${track.name}',
          maxLines: 2,
        ),
        subtitle: Text(
          track.artists.join(', '),
          maxLines: 1,
        ),
        onTap: () =>
            Navigator.pushNamed(context, TrackInfoPage.ROUTE_NAME, arguments: TrackInfoPageArguments(track, trackBloc)),
      ),
    );
  }

  Widget _buildNoTracksPage() {
    return Center(child: Text('No tracks'));
  }
}
