# flick

[comment]: <> (Badges)
<a href="https://www.cosmossoftware.coffee">
   <img alt="Cosmos Software" src="https://img.shields.io/badge/Cosmos%20Software-Love%20Code-red" />
</a>
<a href="https://github.com/Solido/awesome-flutter">
   <img alt="Awesome Flutter" src="https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square" />
</a>

[![Pub](https://img.shields.io/pub/v/flick?color=g)](https://pub.dev/packages/flick)
[![License](https://img.shields.io/github/license/aliyigitbireroglu/flutter-flick?color=blue)](https://github.com/aliyigitbireroglu/flutter-flick/blob/master/LICENSE)

[comment]: <> (Introduction)
An extensive flick tool/widget for Flutter that allows very flexible flick management for your widgets. 

It is designed to work flawlessly with [snap](https://pub.dev/packages/snap) but it can be used as a standalone package too. 

**It is highly recommended to read the documentation and run the example project on a real device to fully understand and inspect the full range
 of capabilities.**

[comment]: <> (ToC)
[Media](#media) | [Description](#description) | [How-to-Use](#howtouse)

[comment]: <> (Notice)
## Notice
* **[flick](https://pub.dev/packages/flick) works as intended on actual devices even if it might appear to fail rarely on simulators. Don't be 
discouraged!**
* * *


[comment]: <> (Media)
<a name="media"></a>
## Media

Watch on **Youtube**:

[v0.1.0](https://youtu.be/RJvb7YKIO6g)
<br><br>
<img src="https://www.cosmossoftware.coffee/Common/Portfolio/GIFs/FlutterFlick.gif" height="450" max-height="450"/>
<br><br>


[comment]: <> (Description)
<a name="description"></a>
## Description
This is an extensive flick tool/widget for Flutter that allows very flexible flick management for your widgets. 

Just wrap the widget you want to flick with the FlickController widget, fill the parameters and this package will take care of everything else.


[comment]: <> (How-to-Use)
<a name="howtouse"></a>
## How-to-Use
*"The view is what is being moved. It is the widget that flicks. The bound is what constrains the view."*

First, a GlobalKey for your view: 

```
GlobalKey view = GlobalKey();
```

If you want your view to be constrained, also define a GlobalKey for your bound. 

```
GlobalKey bound = GlobalKey();
```

Then, create a FlickController such as:

```
FlickController(
  uiChild(),    //uiChild
  false,        //useCache
  view,         //viewKey
 {Key key,
  boundKey          : bound,
  constraintsMin    : Offset.zero,
  constraintsMax    : const Offset(1.0, 1.0),
  flexibilityMin    : const Offset(0.75, 0.75),
  flexibilityMax    : const Offset(0.75, 0.75),
  customBoundWidth  : 0,
  customBoundHeight : 0,
  sensitivity       : 0.05,
  onMove            : _onMove,
  onDragStart       : _onDragStart,
  onDragUpdate      : _onDragUpdate,
  onDragEnd         : _onDragEnd,
  onFlick           : _onFlick})

Widget uiChild() {
  return Container(
    key: view,
    ...
  ); 
}

void _onMove(Offset offset);

void _onDragStart(dynamic dragDetails);
void _onDragUpdate(dynamic dragDetails);
void _onDragEnd(dynamic dragDetails);

void _onFlick(Offset offset);
```

**Further Explanations:**

*For a complete set of descriptions for all parameters and methods, see the [documentation](https://pub.dev/documentation/flick/latest/).*

* Set [useCache] to true if your [uiChild] doesn't change during the Peek & Pop process.
* If [boundKey] is set, [constraintsMin], [constraintsMax], [flexibilityMin] and [flexibilityMax] can't be null.
* For further clarification of [constraintsMin], [constraintsMax], [flexibilityMin] and [flexibilityMax], see [this](https://pub.dev/packages/snap#howtouse).
* Use [FlickControllerState]'s [shouldFlick(dynamic dragEndDetails, double treshold)] method to determine if the view should flick or not where 
[treshold] is the velocity at which the view should be considered to flick.


[comment]: <> (Notes)
## Notes
I started using and learning Flutter only some weeks ago so this package might have some parts that don't make sense, that should be completely 
different, that could be much better, etc. Please let me know! Nicely! 

Any help, suggestion or criticism is appreciated! 

Cheers.

[comment]: <> (CosmosSoftware)
<br><br>
<img align="right" src="https://www.cosmossoftware.coffee/Common/Images/CosmosSoftwareIconTransparent.png" width="150" height="150"/>
<br><br>