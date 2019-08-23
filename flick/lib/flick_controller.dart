//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// © Cosmos Software | Ali Yigit Bireroglu                                                                                                           /
// All material used in the making of this code, project, program, application, software et cetera (the "Intellectual Property")                     /
// belongs completely and solely to Ali Yigit Bireroglu. This includes but is not limited to the source code, the multimedia and                     /
// other asset files. If you were granted this Intellectual Property for personal use, you are obligated to include this copyright                   /
// text at all times.                                                                                                                                /
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//@formatter:off

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Export.dart';

///The widget that is responsible of ALL Flick related logic and UI. It is important to define two essential concepts used for this package:
///I) The view is what is being moved. It is the widget that flicks.
///II) The bound is what constrains the view.
class FlickController extends StatefulWidget {
  ///The widget that is to be displayed on your UI.
  final Widget uiChild;

  ///Set this to true if your [uiChild] doesn't change at runtime.
  final bool useCache;

  ///The [GlobalKey] of the view.
  final GlobalKey viewKey;

  ///The [GlobalKey] of the bound. If set, [constraintsMin], [constraintsMax], [flexibilityMin] and [flexibilityMax] can't be null.
  final GlobalKey boundKey;

  ///Use this value to set the lower left boundary of the movement. [boundKey] can't be null.
  final Offset constraintsMin;

  ///Use this value to set the upper right boundary of the movement. [boundKey] can't be null.
  final Offset constraintsMax;

  ///Use this value to set the lower left elasticity of the movement. [boundKey] can't be null.
  final Offset flexibilityMin;

  ///Use this value to set the upper right elasticity of the movement. [boundKey] can't be null.
  final Offset flexibilityMax;

  ///Use this value to set a custom bound width. If not set, [FlickController] will automatically calculate it via [boundKey].
  final double customBoundWidth;

  ///Use this value to set a custom bound height. If not set, [FlickController] will automatically calculate it via [boundKey].
  final double customBoundHeight;

  ///Use this value to set the sensitivity of the flick.
  final double sensitivity;

  ///The callback for when the view moves.
  final MoveCallback onMove;

  ///The callback for when the drag starts.
  final DragCallback onDragStart;

  ///The callback for when the drag updates.
  final DragCallback onDragUpdate;

  ///The callback for when the drag ends.
  final DragCallback onDragEnd;

  ///The callback for when the view flicks.
  final FlickCallback onFlick;

  const FlickController(
    this.uiChild,
    this.useCache,
    this.viewKey, {
    Key key,
    this.boundKey,
    this.constraintsMin,
    this.constraintsMax,
    this.flexibilityMin,
    this.flexibilityMax,
    this.customBoundWidth: 0,
    this.customBoundHeight: 0,
    this.sensitivity: 0.05,
    this.onMove,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onFlick,
  }) : super(key: key);

  @override
  FlickControllerState createState() {
    return FlickControllerState(
      useCache,
      viewKey,
      boundKey,
      constraintsMin,
      constraintsMax,
      flexibilityMin,
      flexibilityMax,
      sensitivity,
      onMove,
      onDragStart,
      onDragUpdate,
      onDragEnd,
      onFlick,
    );
  }
}

class FlickControllerState extends State<FlickController> with SingleTickerProviderStateMixin {
  Widget uiChild;
  final bool useCache;
  final GlobalKey viewKey;
  final GlobalKey boundKey;

  Offset constraintsMin;
  Offset constraintsMax;
  Offset normalisedConstraintsMin;
  Offset normalisedConstraintsMax;
  final Offset flexibilityMin;
  final Offset flexibilityMax;
  final double sensitivity;

  bool canMove = true;

  final MoveCallback onMove;
  final DragCallback onDragStart;
  final DragCallback onDragUpdate;
  final DragCallback onDragEnd;
  final FlickCallback onFlick;

  RenderBox viewRenderBox;
  double viewWidth = -1;
  double viewHeight = -1;
  Offset viewOrigin;
  RenderBox boundRenderBox;
  double boundWidth = -1;
  double boundHeight = -1;
  Offset boundOrigin;

  Offset delta = Offset.zero;

  ///The [AnimationController] used to move the view during flicking.
  AnimationController animationController;
  Animation<Offset> animation;

  final ValueNotifier<Offset> deltaNotifier = ValueNotifier<Offset>(Offset.zero);

  ///Use this value to determine the depth of debug logging that is actually only here for myself and the Swiss scientists.
  int _debugLevel = 0;

  FlickControllerState(
    this.useCache,
    this.viewKey,
    this.boundKey,
    this.constraintsMin,
    this.constraintsMax,
    this.flexibilityMin,
    this.flexibilityMax,
    this.sensitivity,
    this.onMove,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onFlick,
  );

  @override
  void initState() {
    super.initState();

    if (useCache) uiChild = wrapper();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 333),
      lowerBound: 0,
      upperBound: 1,
    )
      ..addListener(() {
        deltaNotifier.value = animation.value;
        if (onMove != null) onMove(deltaNotifier.value);
      })
      ..addStatusListener((_) {});
    animation = Tween(begin: Offset.zero, end: Offset.zero).animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn));

    checkViewAndBound();
  }

  @override
  void dispose() {
    animationController.removeListener(() {
      deltaNotifier.value = animation.value;
    });
    animationController.removeStatusListener((_) {});
    animationController.dispose();

    reset();

    super.dispose();
  }

  void checkViewAndBound() {
    if (!viewIsSet)
      setView();
    else
      checkViewOrigin();
    if (!boundIsSet)
      setBound();
    else
      checkBoundOrigin();
  }

  void setView() {
    try {
      if (viewKey.currentContext == null) return;
      if (viewRenderBox == null) viewRenderBox = viewKey.currentContext.findRenderObject();

      if (viewRenderBox != null) {
        if (viewRenderBox.hasSize) {
          if (viewWidth == -1) viewWidth = viewRenderBox.size.width;
          if (viewHeight == -1) viewHeight = viewRenderBox.size.height;
        }

        if (viewOrigin == null) viewOrigin = viewRenderBox.localToGlobal(Offset.zero);
      }
    } catch (_) {}
  }

  bool get viewIsSet => !(viewWidth == -1 || viewHeight == -1 || viewOrigin == null);

  void setBound() {
    if (boundKey == null) return;
    try {
      if (boundKey.currentContext == null) return;
      if (boundRenderBox == null) boundRenderBox = boundKey.currentContext.findRenderObject();

      if (boundRenderBox != null) {
        if (boundRenderBox.hasSize) {
          if (boundWidth == -1) boundWidth = boundRenderBox.size.width + widget.customBoundWidth;
          if (boundHeight == -1) boundHeight = boundRenderBox.size.height + widget.customBoundHeight;

          if (boundWidth != -1 && boundHeight != -1) normaliseConstraints();
        }
      }
      if (boundOrigin == null) boundOrigin = boundRenderBox.localToGlobal(Offset.zero);
    } catch (_) {}
  }

  bool get boundIsSet => !(boundWidth == -1 || boundHeight == -1 || boundOrigin == null) || boundKey == null;

  void checkViewOrigin() {
    if (viewOrigin != viewRenderBox.localToGlobal(Offset.zero) - deltaNotifier.value)
      viewOrigin = viewRenderBox.localToGlobal(Offset.zero) - deltaNotifier.value;
  }

  void checkBoundOrigin() {
    if (boundKey == null) return;
    if (boundOrigin != boundRenderBox.localToGlobal(Offset.zero)) boundOrigin = boundRenderBox.localToGlobal(Offset.zero);
  }

  void normaliseConstraints() {
    if (boundKey == null) return;
    double constraintsMinX = constraintsMin.dx == double.negativeInfinity ? double.negativeInfinity : boundWidth * constraintsMin.dx;
    double constraintsMinY = constraintsMin.dy == double.negativeInfinity ? double.negativeInfinity : boundHeight * constraintsMin.dy;
    double constraintsMaxX = constraintsMax.dx == double.infinity ? double.infinity : boundWidth * constraintsMax.dx;
    double constraintsMaxY = constraintsMax.dy == double.infinity ? double.infinity : boundHeight * constraintsMax.dy;
    constraintsMin = Offset(constraintsMinX, constraintsMinY);
    constraintsMax = Offset(constraintsMaxX, constraintsMaxY);
  }

  void endDrag(dynamic dragEndDetails) {
    if (!canMove) return;
    if (animationController.isAnimating) return;

    if (_debugLevel > 0) print("EndDrag");

    delta = deltaNotifier.value;

    if (onDragEnd != null) onDragEnd(dragEndDetails);

    if (shouldFlick(dragEndDetails, 100.0))
      flick(dragEndDetails);
    else if (onFlick != null) onFlick(deltaNotifier.value);
  }

  Future flick(dynamic dragEndDetails) async {
    checkViewAndBound();
    Offset flickTarget = getFlickTarget(dragEndDetails);

    if (_debugLevel > 0) {
      print("--------------------");
      print(viewRenderBox.localToGlobal(Offset.zero));
      print(dragEndDetails.velocity.pixelsPerSecond);
      print(dragEndDetails.velocity.pixelsPerSecond.distance);
      print(flickTarget);
      print("--------------------");
    }

    await move(flickTarget);
    deltaNotifier.value = flickTarget;

    delta = Offset.zero;

    if (onFlick != null) onFlick(deltaNotifier.value);
  }

  Offset getFlickTarget(dynamic dragEndDetails) {
    Offset _delta =
        delta + Offset(dragEndDetails.velocity.pixelsPerSecond.dx * sensitivity, dragEndDetails.velocity.pixelsPerSecond.dy * sensitivity);

    if (boundKey == null) return _delta;

    normalisedConstraintsMin = constraintsMin - viewOrigin + boundOrigin;
    normalisedConstraintsMax = constraintsMax - viewOrigin + boundOrigin - Offset(viewWidth, viewHeight);
    if (_delta.dx < normalisedConstraintsMin.dx)
      _delta = Offset(normalisedConstraintsMin.dx - pow((_delta.dx - normalisedConstraintsMin.dx).abs(), flexibilityMin.dx) + 1.0, _delta.dy);
    if (_delta.dx > normalisedConstraintsMax.dx)
      _delta = Offset(normalisedConstraintsMax.dx + pow((_delta.dx - normalisedConstraintsMax.dx).abs(), flexibilityMax.dx) - 1.0, _delta.dy);
    if (_delta.dy < normalisedConstraintsMin.dy)
      _delta = Offset(_delta.dx, normalisedConstraintsMin.dy - pow((_delta.dy - normalisedConstraintsMin.dy).abs(), flexibilityMin.dy) + 1.0);
    if (_delta.dy > normalisedConstraintsMax.dy)
      _delta = Offset(_delta.dx, normalisedConstraintsMax.dy + pow((_delta.dy - normalisedConstraintsMax.dy).abs(), flexibilityMax.dy) - 1.0);

    return _delta;
  }

  Future move(Offset flickTarget) async {
    animation = Tween(begin: deltaNotifier.value, end: flickTarget).animate(CurvedAnimation(parent: animationController, curve: Curves.decelerate));
    animationController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 333));
    return;
  }

  ///Use this function to determine if the view should flick or not.
  bool shouldFlick(dynamic dragEndDetails, double treshold) {
    return dragEndDetails.velocity.pixelsPerSecond.distance > treshold;
  }

  void reset() {
    delta = Offset.zero;
    deltaNotifier.value = Offset.zero;
  }

  Widget wrapper() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: onDragStart != null ? onDragStart : null,
      onVerticalDragUpdate: onDragUpdate != null ? onDragUpdate : null,
      onVerticalDragEnd: endDrag,
      onHorizontalDragStart: onDragStart != null ? onDragStart : null,
      onHorizontalDragUpdate: onDragUpdate != null ? onDragUpdate : null,
      onHorizontalDragEnd: endDrag,
      child: widget.uiChild,
    );
  }

  @override
  Widget build(BuildContext context) {
    checkViewAndBound();

    return ValueListenableBuilder(
      child: useCache ? uiChild : null,
      builder: (BuildContext context, Offset delta, Widget cachedChild) {
        return Transform.translate(
          offset: delta,
          child: useCache ? cachedChild : wrapper(),
        );
      },
      valueListenable: deltaNotifier,
    );
  }
}
