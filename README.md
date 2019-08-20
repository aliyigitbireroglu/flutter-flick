# flick

An extensive flick tool/widget for Flutter that allows very flexible flick management for your widgets. It is designed to work flawlessly with 
[snap](https://pub.dev/packages/snap) but it can be used as a standalone package too. 

**It is highly recommended to read the documentation and run the example project on a real device to fully understand and inspect the full range
 of capabilities.**

[Media](#media) | [Description](#description) | [How-to-Use](#howtouse)

<img src="https://img.shields.io/badge/Cosmos%20Software-Love%20Code-red"/>
<br>

[![Pub](https://img.shields.io/pub/v/flick?color=g)](https://pub.dev/packages/flick)
[![License](https://img.shields.io/github/license/aliyigitbireroglu/flutter-flick?color=blue)](https://github.com/aliyigitbireroglu/flutter-flick/blob/master/LICENSE)

## Notice
* **[flick](https://pub.dev/packages/flick) works as intended on actual devices even if it might appear to fail rarely on simulators. Don't be 
discouraged!**
* * *


<a name="media"></a>
## Media
*Videos*

* [v0.1.0](https://youtu.be/RJvb7YKIO6g)

*GIFs*
<br><br>
<img src="https://www.cosmossoftware.coffee/Common/Portfolio/GIFs/FlutterFlick.gif"/>
<br><br>


<a name="description"></a>
## Description
This is a very detailed flick tool/widget for Flutter that allows very flexible flick management for your widgets. Just wrap the widget you want to
 flick with the FlickController widget, fill the parameters and this package will take care of everything else.


<a name="howtouse"></a>
## How-to-Use
*"The view is what is being moved. It is the widget that flicks. The bound is what constrains the view."*

First, a GlobalKey for your view: 

```
GlobalKey view = GlobalKey();
```

If you want your view to be constrained, also define a GlobalKey for your bound. Then, create a FlickController as shown in the example project:

```
FlickController(
  normalBox(), 
  true, 
  view, 
  sensitivity: 0.1))

Widget normalBox() {
return Container(
  key: view,
  width: 200,
  height: 200,
  color: Colors.transparent,
  child: Padding(
    padding: const EdgeInsets.all(5),
    child: Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: const BorderRadius.all(const Radius.circular(10.0))),
      child: Center(
        child: Text(
          "Flick",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25))))));
}
```

In this excerpt, the view is the normalBox widget and it is unconstrained which means it can be flicked to anywhere. It is also unchanging through 
the runtime so the useCache value for the FlickController is set to true. The sensitivity is 0.1 which means a very strong flick will be required 
to move the view a large distance.


## Notes
I started using and learning Flutter only some weeks ago so this package might have some parts that don't make sense, 
that should be completely different, that could be much better, etc. Please let me know! Nicely! 

Any help, suggestion or criticism is appreciated! 

Cheers.

<br><br>
<img align="right" src="https://www.cosmossoftware.coffee/Common/Images/CosmosSoftwareIconTransparent.png" width="150" height="150"/>
<br><br>