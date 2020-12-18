import 'package:spotify/spotify.dart';

class CustomUser extends User {
  @override
  String displayName;

  @override
  String email;

  @override
  String id;

  @override
  String uri;

  int playlistId;
  String playlistName;

  CustomUser(this.displayName, this.email, this.id, this.uri, {this.playlistId, this.playlistName});

  factory CustomUser.fromUser(User user) => CustomUser(user.displayName, user.email, user.id, user.uri);

  factory CustomUser.fromJson(Map<String, dynamic> json) =>
      CustomUser(json['displayName'], json['email'], json['id'], json['uri'],
          playlistId: json['playlistId'], playlistName: json['playlistName']);

  Map<String, dynamic> toJson() => {
        'displayName': this.displayName,
        'email': this.email,
        'id': this.id,
        'uri': this.uri,
        "playlistId": this.playlistId,
        "playlistName": this.playlistName,
      };
}
