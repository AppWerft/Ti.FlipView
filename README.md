Ti.FlipViewControler ![](https://camo.githubusercontent.com/ecc6562b9e8446bbf967b69b4180fef9080068b3/687474703a2f2f7777772d7374617469632e61707063656c657261746f722e636f6d2f6261646765732f746974616e69756d2d6769742d62616467652d73712e706e67)
====================

About
-----
This is the Titanium version of [Mpospese/mpflipviewcontroller](https://github.com/Mpospese/mpflipviewcontroller) for iOS and a fork of the Android version of [Manu's TiAndroidFlip](https://github.com/manumaticx/TiAndroidFlip)

![](https://raw.githubusercontent.com/AppWerft/TiFlipViewControler/master/flipviewcontroler.gif) 

![](https://raw.githubusercontent.com/manumaticx/TiAndroidFlip/master/documentation/demo.gif)


Currently we have different API for both platform. Please look into to  platform folders.

USAGE
-----

~~~
var win = Ti.UI.createWindow({
win.open();
var flipView = require('ti.flipview').createView({
    pages : [0,1,2,3,4,5,6,7,8].map.function() {return Ti.Ui.createView({}}
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


Events (ioS):
-------

~~~
flipView.addEventListener('change', function(e) { 
console.log('Current page index is ' + e.source.currentPage);
});
~~~

Methods after creating (ioS):
----------------------

* flipView.insertPageAfter(index,view);
* flipView.insertPageBefore(index,view)
* flipView.appendPage(view);
* flipView.deletePage(index);
* flipView.bounceForward();
* flipView.bounceBackward();
* changeCurrentPage();

Crossplatform
-------------

For using in both platforms currently you can use this javascript wrapper:
~~~
var FlipModule = require('ti.flipview');
module.exports = function() {
    var options = arguments[0] || {};
    var total = options.pages.length;
    if (Ti.Android) {
        var self = FlipModule.createFlipView({
        orientation : FlipModule.ORIENTATION_HORIZONTAL,
        overFlipMode : FlipModule.OVERFLIPMODE_GLOW,
        views : options.pages,
        currentPage : (options.startPage) ? options.startPage : 0,
        total : total
    });
    self.addEventListener('flipped', function(_e) {
        options && options.onflipend({
                current : _e.index,
                pagecount : total,
            });
        });
        return self;
} else {
    var self = FlipModule.createView({
        startPage : (options.startPage) ? options.startPage : undefined,
        transitionDuration : 0.4,
        pages : options.pages,
        tapRecognitionMargin : 1,
        swipeThreshold : 120,
        swipeEscapeVelocity: 650,
        bounceRatio: 0.3,  // default 0.3
        rubberBandRatio: 0.6666, // default 0.6666
        total : total
    });
    self.addEventListener('change', function(_e) {
        options.onflipend && options.onflipend({
            current : _e.source.currentPage,
            pagecount : total
        });
    });
    return self;
    }
};
~~~

In the future the API wil be the same syntax