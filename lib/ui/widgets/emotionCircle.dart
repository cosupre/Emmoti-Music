import 'dart:math';

import 'package:emoti_music/models/track.dart';
import 'package:emoti_music/ui/widgets/circleLayoutDelegate.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class EmotionCircle extends StatefulWidget {
  EmotionCircle({Key key, @required this.tracks, @required this.onTap}) : super(key: key);

  final List<CustomTrack> tracks;
  final Function onTap;

  @override
  _EmotionCircleState createState() => _EmotionCircleState();
}

class _EmotionCircleState extends State<EmotionCircle> {
  List<CustomTrack> tracks;

  double scale = 1.0;
  PhotoViewScaleStateController _scaleStateController;
  PhotoViewController _viewController;

  @override
  void initState() {
    tracks = widget.tracks;
    super.initState();
    _viewController = PhotoViewController()
      ..outputStateStream.listen((PhotoViewControllerValue value) {
        setState(() {
          scale = value.scale;
        });
      });
    _scaleStateController = PhotoViewScaleStateController();
  }

  @override
  void dispose() {
    _viewController.dispose();
    _scaleStateController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EmotionCircle oldWidget) {
    if (tracks != widget.tracks) {
      setState(() {
        tracks = widget.tracks;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var margin = 20.0;
    Size size = MediaQuery.of(context).size;
    var diameter = size.width - 2 * margin;
    var middle = diameter / 2;
    var trackDiameter = diameter / 5;
    Offset initial = Offset(middle, middle);

    return PhotoView.customChild(
      minScale: 1.0,
      maxScale: 5.0,
      initialScale: 1.0,
      controller: _viewController,
      scaleStateController: _scaleStateController,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(margin),
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage('assets/circle.jpg'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(380),
            ),
            child: Builder(
              builder: (BuildContext context) {
                List<LayoutId> items = List.generate(
                  tracks.length,
                  (index) => LayoutId(
                    id: index + 1,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(380),
                      child: Container(
                        width: trackDiameter / scale.clamp(1.0, 5.0),
                        height: trackDiameter / scale.clamp(1.0, 5.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(image: NetworkImage(tracks[index].imageUrl)),
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(380),
                          border: Border.all(color: Colors.black),
                        ),
                      ),
                      onTap: () {
                        widget.onTap(tracks[index]);
                      },
                    ),
                  ),
                );
                return CustomMultiChildLayout(
                  delegate: CircleLayoutDelegate(
                      position: initial,
                      itemLength: items.length,
                      getChildrenOffset: (id, size) => getChildrenOffset(tracks, id, size, initial, middle)),
                  children: items,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Offset getChildrenOffset(List<CustomTrack> tracks, int id, Size size, Offset initial, double middle) {
    CustomTrack track = tracks.elementAt(id - 1);
    double valence = track.valence * 2 - 1;
    double energy = track.energy * 2 - 1;

    double x = valence * middle;
    double y = energy * middle;

    double minimum = min(x, y);

    // pythagore lol
    double maxSquareRadius = sqrt(middle * middle + minimum * minimum);

    x = x * middle / maxSquareRadius;
    y = y * middle / maxSquareRadius;

    var res = Offset(
        (initial.dx - size.width / 2 + x) * (1 - 0.1 / scale), (initial.dy - size.height / 2 - y) * (1 - 0.1 / scale));
    return res;
  }
}
