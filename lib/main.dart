import 'dart:convert';

import 'package:emoti_music/bloc/trackBloc/bloc.dart';
import 'package:emoti_music/models/credentials.dart';
import 'package:emoti_music/models/playlist.dart';
import 'package:emoti_music/models/user.dart';
import 'package:emoti_music/ui/HomePage.dart';
import 'package:emoti_music/ui/choosePlaylistPage.dart';
import 'package:emoti_music/ui/loginPage.dart';
import 'package:emoti_music/ui/webConnectionPage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/spotify.dart';

GetIt getIt = GetIt.instance;

void main() {
  getIt.allowReassignment = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StartingPage(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (RouteSettings settings) {
        var args = settings.arguments;
        var routes = {
          WebConnectionPage.ROUTE_NAME: (BuildContext _) => WebConnectionPage(webConnectionPageArguments: args),
          ChoosePlaylistPage.ROUTE_NAME: (BuildContext _) => ChoosePlaylistPage(choosePlaylistPageArguments: args),
        };

        return MaterialPageRoute(builder: routes[settings.name], settings: settings);
      },
    );
  }
}

class StartingPage extends StatefulWidget {
  @override
  _StartingPageState createState() => _StartingPageState();
}

class _StartingPageState extends State<StartingPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<Credentials> futureCredentials;
  Future<CustomUser> futureUser;
  Future<CustomPlaylist> futurePlaylist;

  @override
  void initState() {
    super.initState();

    futureCredentials = _prefs.then((SharedPreferences prefs) {
      String prefResult = prefs.getString('credentials') ?? null;
      return prefResult != null && prefResult != ''
          ? Credentials.fromJson(jsonDecode(prefResult))
          : Credentials('', '');
    });

    futureUser = _prefs.then((SharedPreferences prefs) {
      String prefResult = prefs.getString('user') ?? null;
      return prefResult != null && prefResult != '' ? CustomUser.fromJson(jsonDecode(prefResult)) : null;
    });

    futurePlaylist = _prefs.then((SharedPreferences prefs) {
      String prefResult = prefs.getString('playlist') ?? null;
      return prefResult != null && prefResult != '' ? CustomPlaylist.fromJson(jsonDecode(prefResult)) : null;
    });
  }

  Future<void> registerCredentials(SpotifyApi spotify) async {
    Credentials credentials = Credentials.fromSpotifyApiCredentials(await spotify.getCredentials());
    CustomUser user = CustomUser.fromUser(await spotify.me.get());
    print(jsonEncode(user));
    final SharedPreferences prefs = await _prefs;

    setState(() {
      futureCredentials = prefs.setString('credentials', jsonEncode(credentials.toJson())).then((bool success) {
        return credentials;
      });

      futureUser = prefs.setString('user', jsonEncode(user)).then((bool success) {
        return user;
      });
    });
  }

  Future<void> registerPlaylist(CustomPlaylist playlist) async {
    final SharedPreferences prefs = await _prefs;
    getIt.registerSingleton<CustomPlaylist>(playlist);

    setState(() {
      futurePlaylist = prefs.setString('playlist', jsonEncode(playlist)).then((bool success) {
        return playlist;
      });
    });
  }

  Future<void> deleteCredentials() async {
    Credentials credentials = Credentials('', '', active: false);
    final SharedPreferences prefs = await _prefs;
    setState(() {
      futureCredentials = prefs.setString('credentials', jsonEncode(credentials.toJson())).then((bool success) {
        return credentials;
      });

      futureUser = prefs.setString('user', '').then((bool success) {
        return null;
      });

      futurePlaylist = prefs.setString('playlist', '').then((bool success) {
        return null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureCredentials,
      builder: (BuildContext context, AsyncSnapshot<Credentials> credSnapshot) {
        return FutureBuilder(
            future: futureUser,
            builder: (BuildContext context, AsyncSnapshot<User> userSnapshot) {
              return FutureBuilder(
                  future: futurePlaylist,
                  builder: (BuildContext context, AsyncSnapshot<CustomPlaylist> playlistSnapshot) {
                    return credSnapshot.hasData
                        ? (credSnapshot.data.active && userSnapshot.hasData && userSnapshot.data != null
                            ? Builder(
                                builder: (BuildContext context) {
                                  getIt.registerSingleton<SpotifyApi>(SpotifyApi(credSnapshot.data));
                                  getIt.registerSingleton<CustomUser>(userSnapshot.data);
                                  return playlistSnapshot.hasData && playlistSnapshot.data != null
                                      ? _buildHomeAndSetGetIt(
                                          credSnapshot.data, userSnapshot.data, playlistSnapshot.data)
                                      : ChoosePlaylistPage(
                                          choosePlaylistPageArguments: ChoosePlaylistPageArguments(
                                              validate: registerPlaylist, disconnect: deleteCredentials));
                                },
                              )
                            : LoginPage(
                                registerCredentials: registerCredentials,
                              ))
                        : Scaffold(
                            body: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                  });
            });
      },
    );
  }

  _buildHomeAndSetGetIt(credentials, user, playlist) {
    try {
      getIt.registerSingleton<CustomPlaylist>(playlist);
      return HomePage(
        disconnect: deleteCredentials,
        registerPlaylist: registerPlaylist,
      );
    } catch (e) {
      print(e);
    }
  }
}
