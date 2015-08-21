var win = Ti.UI.createWindow();

// create some views
var views = [];
for (var i=0; i <= 5; i++){
	views.push(Ti.UI.createView({ backgroundColor: '#'+Math.floor(Math.random()*16777215).toString(16)}));
}

// require the module
var Flip = require('de.manumaticx.androidflip');

// create the flipView
var flipView = Flip.createFlipView({
	orientation: Flip.ORIENTATION_HORIZONTAL,
	overFlipMode: Flip.OVERFLIPMODE_RUBBER_BAND,
	views: views
});

// add flip listener
flipView.addEventListener('flipped', function(e){
	Ti.API.info("flipped to page " + e.index);
});

// add it to a parent view
win.add(flipView);

win.open();