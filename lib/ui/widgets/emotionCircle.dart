import 'package:emoti_music/bloc/trackBloc/bloc.dart';
import 'package:emoti_music/models/track.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class EmotionCircle extends StatefulWidget {
  EmotionCircle({Key key, @required this.snapshot, @required this.trackBloc, this.favoriteFirst = false})
      : super(key: key);

  final AsyncSnapshot<List<CustomTrack>> snapshot;
  final TrackBloc trackBloc;
  final bool favoriteFirst;

  @override
  _EmotionCircleState createState() => _EmotionCircleState();
}

class _EmotionCircleState extends State<EmotionCircle> {
  AsyncSnapshot<List<CustomTrack>> snapshot;
  TrackBloc trackBloc;
  bool favoriteFirst = false;

  double scale = 1.0;
  PhotoViewScaleStateController _scaleStateController;
  PhotoViewController _viewController;

  @override
  void initState() {
    snapshot = widget.snapshot;
    trackBloc = widget.trackBloc;
    favoriteFirst = widget.favoriteFirst;
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
    if (snapshot != widget.snapshot || trackBloc != widget.trackBloc || favoriteFirst != widget.favoriteFirst) {
      setState(() {
        trackBloc = widget.trackBloc;
        snapshot = widget.snapshot;
        favoriteFirst = widget.favoriteFirst;
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

    return Scaffold(
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return true;
        },
        child: Center(
          child: snapshot.hasData
              ? PhotoView.customChild(
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
                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(380)),
                        child: Builder(
                          builder: (BuildContext context) {
                            var tracks = snapshot.data;
                            if (favoriteFirst) {
                              tracks = List.from(snapshot.data);
                              tracks.removeWhere((element) => !element.favorite);
                            }

                            List<LayoutId> items = List.generate(
                              tracks.length,
                              (index) => LayoutId(
                                id: index + 1,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(380),
                                  child: Container(
                                    width: trackDiameter / scale,
                                    height: trackDiameter / scale,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(image: NetworkImage(tracks[index].imageUrl)),
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(380),
                                    ),
                                  ),
                                  onTap: () {},
                                ),
                              ),
                            );
                            return CustomMultiChildLayout(
                              delegate: EmotionCircleLayoutDelegate(
                                  position: initial,
                                  itemLength: items.length,
                                  getChildrenOffset: (id, size) =>
                                      getChildrenOffset(tracks, id, size, initial, middle)),
                              children: items,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }

  Offset getChildrenOffset(List<CustomTrack> tracks, int id, Size size, Offset initial, double middle) {
    CustomTrack track = tracks.elementAt(id - 1);
    double valence = track.valence * 2 - 1;
    double energy = track.energy * 2 - 1;
    var res = Offset((initial.dx - size.width / 2 + valence * middle) * (1 - 0.1 / scale),
        (initial.dy - size.height / 2 + energy * middle) * (1 - 0.1 / scale));
    return res;
  }
}

class EmotionCircleLayoutDelegate extends MultiChildLayoutDelegate {
  EmotionCircleLayoutDelegate({this.position, this.getChildrenOffset, this.itemLength = 0});

  final Offset position;
  final int itemLength;

  Function getChildrenOffset = (id, size) => Offset.zero;

  @override
  void performLayout(Size size) {
    for (int i = 1; i <= itemLength; i += 1) {
      if (hasChild(i)) {
        Size itemSize = layoutChild(
          i, // The id once again.
          BoxConstraints.loose(size), // This just says that the child cannot be bigger than the whole layout.
        );

        positionChild(i, getChildrenOffset(i, itemSize));
      }
    }
  }

  @override
  bool shouldRelayout(EmotionCircleLayoutDelegate oldDelegate) {
    return oldDelegate.position != position || oldDelegate.itemLength != itemLength;
  }
}
