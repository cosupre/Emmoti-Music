import 'dart:convert';

import 'package:spotify/spotify.dart';

class CustomTrack {
  List<String> artists;
  String name;
  String id;
  String uri;

  String playlistId;
  String albumId;

  int imageHeight;
  int imageWidth;
  String imageUrl;

  bool favorite;

  double valence;
  double energy;

  CustomTrack({this.id,
    this.name,
    this.uri,
    this.artists,
    this.albumId,
    this.playlistId,
    this.imageHeight,
    this.imageWidth,
    this.imageUrl,
    this.favorite,
    this.valence,
    this.energy});

  factory CustomTrack.fromTrackAndFeature(Track track, AudioFeature feature, playlistId) {
    var album = track.album;
    var image = track.album.images?.elementAt(0);
    var artists = track.artists.map((e) => e.name).toList();
    return CustomTrack(
      id: track.id,
      name: track.name,
      uri: track.uri,
      artists: artists,
      albumId: album.id,
      playlistId: playlistId,
      imageHeight: image.height,
      imageWidth: image.width,
      imageUrl: image.url,
      favorite: false,
      valence: feature.valence,
      energy: feature.energy,
    );
  }

  factory CustomTrack.fromDatabase(Map<String, dynamic> json) =>
      CustomTrack(
        id: json['id'],
        name: json['name'],
        uri: json['uri'],
        artists: jsonDecode(json['artists']).cast<String>(),
        albumId: json['albumId'],
        playlistId: json['playlistId'],
        imageHeight: json['imageHeight'],
        imageWidth: json['imageWidth'],
        imageUrl: json['imageUrl'],
        favorite: json['favorite'] == 0 ? false : true,
        valence: json['valence'],
        energy: json['energy'],
      );

  Map<String, dynamic> toDatabase() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['uri'] = this.uri;
    data['artists'] = jsonEncode(this.artists);
    data['albumId'] = this.albumId;
    data['playlistId'] = this.playlistId;
    data['imageHeight'] = this.imageHeight;
    data['imageWidth'] = this.imageWidth;
    data['imageUrl'] = this.imageUrl;
    data['favorite'] = this.favorite ? 1 : 0;
    data['valence'] = this.valence;
    data['energy'] = this.energy;
    return data;
  }
}
