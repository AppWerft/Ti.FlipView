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
// open a single window
var win = Ti.UI.createWindow({
backgroundColor : 'white'
});

var label = Ti.UI.createLabel();
win.add(label);
win.open();

var pages = [];
for (var i = 0; i < 10; i++) {
pages.push(require('view'));
}

// constructor:
var flipView = require('org.bcbhh.Iosflipview').createView({
pages : pages,
startPage : 5,
transitionOrientation : 0|1,
transitionDuration : 0.4,
tapRecognitionMargin : 10,
swipeThreshold : 120,
swipeEscapeVelocity : 650,
bounceRatio : 0.3, // default 0.3
rubberBandRatio : 0.6666, // default 0.6666
});

Properties:
flipView.numberOfPages  (read only)

// events:
flipView.addEventListener('change', function(e) { 
console.log('Current page index is ' +e.source.currentPage);
});

// methods:
flipView.insertPageAfter(index,view);
flipView.insertPageBefore(index,view)
flipView.appendPage(view);
flipView.deletePage(index);
flipView.bounceForward();
flipView.bounceBackward();
changeCurrentPage();


win.add(flipView);
~~~


BUILDING YOUR MODULE
--------------------

Simply run `titanium build --platform <name of platform> --build-type production --dir /path/to/module`.
You can omit the --dir option if your working directory is in the module's project directory.


INSTALL YOUR MODULE
-------------------

Mac OS X
--------
Copy the distribution zip file into the `~/Library/Application Support/Titanium` folder

Linux
-----
Copy the distribution zip file into the `~/.titanium` folder

Windows
-------
Copy the distribution zip file into the `C:\ProgramData\Titanium` folder


REGISTER YOUR MODULE
--------------------

Register your module with your application by editing `tiapp.xml` and adding your module.
Example:

<modules>
	<module version="0.1">org.bcbhh.iosflipview</module>
</modules>

When you run your project, the compiler will combine your module along with its dependencies
and assets into the application.


USING YOUR MODULE IN CODE
-------------------------

To use your module in code, you will need to require it.

For example,

	var my_module = require('org.bcbhh.iosflipview');
	my_module.foo();


TESTING YOUR MODULE
-------------------

To test with the script, execute:

	titanium run --dir=YOURMODULEDIR

This will execute the app.js in the example folder as a Titanium application.


DISTRIBUTING YOUR MODULE
-------------------------

You can choose to manually distribute your module distribution zip file or through the Titanium Marketplace!


Cheers!
