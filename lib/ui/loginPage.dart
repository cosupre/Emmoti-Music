import 'package:emoti_music/secrets/spotify.dart';
import 'package:emoti_music/ui/webConnectionPage.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, @required this.registerCredentials}) : super(key: key);

  final Function registerCredentials;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = false;
  final redirectUri = 'https://emoti_music/auth';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SpotifySecrets secrets = SpotifySecrets();
    final credentials = SpotifyApiCredentials(secrets.clientId, secrets.clientSecret);
    final grant = SpotifyApi.authorizationCodeGrant(credentials);

    final scopes = ['user-read-email', 'user-read-private', 'playlist-modify-public', 'playlist-modify-private'];

    final authUri = grant.getAuthorizationUrl(
      Uri.parse(redirectUri),
      scopes: scopes, // scopes are optional
    );

    return Scaffold(
      body: isLogin
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false,
              bottom: false,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Emoti\' Music'),
                      RaisedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, WebConnectionPage.ROUTE_NAME,
                              arguments: WebConnectionPageArguments(authUri.toString(), (responseUri) async {
                                Navigator.pop(context);
                                final spotify = SpotifyApi.fromAuthCodeGrant(grant, responseUri);

                                widget.registerCredentials(spotify);
                              }));
                        },
                        child: Text('Connection'),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
