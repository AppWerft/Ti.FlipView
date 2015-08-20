// This is a test harness for your module
// You should do something interesting in this harness
// to test out the module and to provide instructions
// to users on how to use it by example.

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
var flipView = require('org.bcbhh.iosflipvew').createView({
	pages : pages,
	startPage : 5,
	transitionDuration : 0.4,
	tapRecognitionMargin : 10,
	swipeThreshold : 120,
	swipeEscapeVelocity : 650,
	bounceRatio : 0.3, // default 0.3
	rubberBandRatio : 0.6666, // default 0.6666
});

// events:
flipView.addEventListener('change', function(e) { 
	console.log('Current page index is ' +e.source.currentPage);
});

// methods:


win.add(flipView);

