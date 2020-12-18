import 'package:emoti_music/bloc/trackBloc/dao.dart';
import 'package:emoti_music/main.dart';
import 'package:emoti_music/models/track.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';

class TrackRepository {
  final SpotifyApi spotify = getIt<SpotifyApi>();
  final TrackDao trackDao = TrackDao();

  Future<List<CustomTrack>> getTracks({sync = false, @required playlistId}) async {
    List<CustomTrack> oldTracks = await trackDao.getTracks(playlistId: playlistId);

    if (sync) {
      try {
        var tracks = await spotify.playlists.getTracksByPlaylistId(playlistId).all();
        var trackIds = tracks.map((e) => e.id);
        var features = await spotify.audioFeatures.list(trackIds);

        List<CustomTrack> customTracks = List<CustomTrack>.generate(tracks.length,
                (index) =>
                CustomTrack.fromTrackAndFeature(tracks.elementAt(index), features.elementAt(index), playlistId));

        await Future.forEach(customTracks, (element) async {
          var searchInOldList = oldTracks.where((old) => old.id == element.id).toList();
          if (searchInOldList.isNotEmpty) {
            element.favorite = searchInOldList.first.favorite;
          }

          oldTracks.removeWhere((old) => old.id == element.id);

          trackDao.exists(element.id).then((exists) => exists ? trackDao.updateTrack(element) : trackDao.createTrack(element));
        });

        oldTracks.forEach((element) => trackDao.deleteTrack(element.id));
        oldTracks = customTracks;
      } catch (e) {
        print(e);
      }
    }

    return oldTracks;
  }

  Future updateTrack(CustomTrack track) async => await trackDao.updateTrack(track);

  Future deleteTrack(CustomTrack track) async {
    spotify.playlists.removeTrack(track.uri, track.playlistId).catchError((e) => print);
    return trackDao.deleteTrack(track.id);
  }

  Future<CustomTrack> createTrack(CustomTrack track) async {
    spotify.playlists.addTrack(track.uri, track.playlistId);
    await trackDao.createTrack(track);
    return track;
  }

  deleteAll() async {
    await trackDao.deleteAll();
  }
}
