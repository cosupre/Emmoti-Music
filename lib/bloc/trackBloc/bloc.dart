import 'dart:async';

import 'package:emoti_music/bloc/trackBloc/repository.dart';
import 'package:emoti_music/models/track.dart';

class TrackBloc {
  final _trackRepository = TrackRepository();

  final _trackController = StreamController<List<CustomTrack>>.broadcast();

  get tracks => _trackController.stream;

  TrackBloc(playlistId) {
    getTracks(playlistId);
  }

  sortTracks(List<CustomTrack> tracks) {
    tracks.sort((a, b) {
      return a.name.compareTo(b.name);
    });
    return  tracks;
  }

  getTracks(playlistId) async {
    _trackController.sink.add(sortTracks(await _trackRepository.getTracks(playlistId: playlistId)));
  }

  syncTracks(playlistId) async {
    _trackController.sink.add(sortTracks(await _trackRepository.getTracks(playlistId: playlistId, sync: true)));
  }

  updateTrack(CustomTrack track) async {
    await _trackRepository.updateTrack(track);
    getTracks(track.playlistId);
  }

  createTrack(CustomTrack track) async {
    await _trackRepository.createTrack(track);
    getTracks(track.playlistId);
  }

  deleteTrack(CustomTrack track) async {
    await _trackRepository.deleteTrack(track);
    getTracks(track.playlistId);
  }

  deleteAll() async {
    await _trackRepository.deleteAll();
    getTracks(0);
  }

  dispose() {
    _trackController.close();
  }
}