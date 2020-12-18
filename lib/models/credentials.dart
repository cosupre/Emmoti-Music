import 'package:spotify/spotify.dart';

class Credentials extends SpotifyApiCredentials {
  bool active;

  Credentials(
    clientId,
    clientSecret, {
    accessToken,
    refreshToken,
    scopes,
    expiration,
    this.active = false,
  }) : super(
          clientId,
          clientSecret,
          accessToken: accessToken,
          refreshToken: refreshToken,
          scopes: scopes,
          expiration: expiration,
        );

  factory Credentials.fromSpotifyApiCredentials(SpotifyApiCredentials data) =>
      Credentials(
        data.clientId,
        data.clientSecret,
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
        scopes: data.scopes,
        expiration: data.expiration,
        active: true,
      );

  factory Credentials.fromJson(Map<String, dynamic> data) => Credentials(
        data['clientId'],
        data['clientSecret'],
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
        scopes: data['scopes'] != null ? List<String>.from(data['scopes']) : List<String>.empty(),
        expiration: data['expiration'] != null ? DateTime.fromMicrosecondsSinceEpoch(data['expiration']) : DateTime.now(),
        active: data['active'],
      );

  Map<String, dynamic> toJson() => {
        'clientId': this.clientId,
        'clientSecret': this.clientSecret,
        'accessToken': this.accessToken,
        'refreshToken': this.refreshToken,
        'scopes': this.scopes,
        'expiration': this.expiration?.millisecondsSinceEpoch,
        'active': this.active,
      };
}
