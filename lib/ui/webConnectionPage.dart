import 'dart:io';

import 'package:emoti_music/secrets/spotify.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebConnectionPage extends StatefulWidget {
  WebConnectionPage({Key key, @required this.webConnectionPageArguments}) : super(key: key);

  static const ROUTE_NAME = 'auth-page';

  WebConnectionPageArguments webConnectionPageArguments;

  @override
  _WebConnectionPageState createState() => _WebConnectionPageState();
}

class _WebConnectionPageState extends State<WebConnectionPage> {
  final redirectUri = 'https://emoti_music/auth';

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl: widget.webConnectionPageArguments.uri,
      navigationDelegate: (navReq) {
        if (navReq.url.startsWith(redirectUri)) {
          widget.webConnectionPageArguments.setResponseUri(navReq.url);
          return NavigationDecision.prevent;
        }

        return NavigationDecision.navigate;
      },
    );
  }
}

class WebConnectionPageArguments {
  final String uri;
  final Function setResponseUri;

  WebConnectionPageArguments(this.uri, this.setResponseUri);
}
