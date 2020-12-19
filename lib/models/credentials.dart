import 'package:spotify/spotify.dart';

class Credentials {
  String clientId;
  String clientSecret;
  String accessToken;
  String refreshToken;
  List<String> scopes;
  DateTime expiration;

  Credentials(
    this.clientId,
    this.clientSecret, {
    this.accessToken,
    this.refreshToken,
    this.scopes,
    this.expiration,
  });

  factory Credentials.fromSpotifyApiCredentials(SpotifyApiCredentials data) => Credentials(
        data.clientId,
        data.clientSecret,
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
        scopes: data.scopes,
        expiration: data.expiration,
      );

  SpotifyApiCredentials toSpotifyApiCredentials() => SpotifyApiCredentials(clientId, clientSecret,
      accessToken: accessToken, refreshToken: refreshToken, scopes: scopes, expiration: expiration);

  factory Credentials.fromJson(Map<String, dynamic> data) => Credentials(
        data['clientId'],
        data['clientSecret'],
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
        scopes: data['scopes'] != null ? List<String>.from(data['scopes']) : List<String>.empty(),
        expiration:
            data['expiration'] != null ? DateTime.fromMillisecondsSinceEpoch(data['expiration']) : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'clientId': this.clientId,
        'clientSecret': this.clientSecret,
        'accessToken': this.accessToken,
        'refreshToken': this.refreshToken,
        'scopes': this.scopes,
        'expiration': this.expiration?.millisecondsSinceEpoch,
      };
}
