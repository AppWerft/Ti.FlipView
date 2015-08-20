Ti.FlipViewControler ![](https://camo.githubusercontent.com/ecc6562b9e8446bbf967b69b4180fef9080068b3/687474703a2f2f7777772d7374617469632e61707063656c657261746f722e636f6d2f6261646765732f746974616e69756d2d6769742d62616467652d73712e706e67)
====================

About
-----
This is the Titanium version of [Mpospese/mpflipviewcontroller](https://github.com/Mpospese/mpflipviewcontroller)

![](https://raw.githubusercontent.com/AppWerft/TiFlipViewControler/master/flipviewcontroler.gif)

It is the iOS version of [Manu's TiAndroidFlip](https://github.com/manumaticx/TiAndroidFlip)


USAGE
-----

~~~
var win = Ti.UI.createWindow({
win.open();
var flipView = require('de.appwerft.iosflipview').createView({
    pages : [0,1,2,3,4,5,6].map.function() {return Ti.Ui.createView({}}
);
win.add(flipView);
~~~

Properties:
----------

* flipView.numberOfPages  (read only)
* startPage,
* transitionOrientation,
* transitionDuration,
* tapRecognitionMargin,
* swipeThreshold,
* swipeEscapeVelocity,
* bounceRatio
* rubberBandRatio


Events:
-------

~~~
flipView.addEventListener('change', function(e) { 
console.log('Current page index is ' + e.source.currentPage);
});
~~~

Methods after creating:
----------------------

* flipView.insertPageAfter(index,view);
* flipView.insertPageBefore(index,view)
* flipView.appendPage(view);
* flipView.deletePage(index);
* flipView.bounceForward();
* flipView.bounceBackward();
* changeCurrentPage();

