import 'package:spotify/spotify.dart';

class CustomPlaylist {
  String name;
  String id;

  CustomPlaylist(this.name, this.id);

  factory CustomPlaylist.fromPlaylistSimple(PlaylistSimple simple) => CustomPlaylist(simple.name, simple.id);

  factory CustomPlaylist.fromJson(Map<String, dynamic> json) => CustomPlaylist(json['name'], json['id']);

  Map<String, dynamic> toJson() => {
        "id": this.id,
        "name": this.name,
      };
}
