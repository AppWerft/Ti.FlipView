var GLOBALS = require('GLOBALS');

module.exports = function() {
	var args = arguments[0] || {};
	var self = Ti.UI.createScrollView({
		layout : 'vertical',
		backgroundColor : 'white',
		scrollType : 'vertical',
		height : Ti.UI.FILL,
		contentWidth : Ti.UI.FILL,
		contentHeight : Ti.UI.SIZE,
	});
	var w = parseInt(GLOBALS.SCREENWIDTH * 0.4);
	var imageurl = 'http://lorempixel.com/g/' + w + '/' + w + '/?' + Math.random();	console.log(imageurl);
	self.add(Ti.UI.createImageView({
		image : imageurl,
		top : 10,
		defaultImage : '',
		hires : true,
		borderRadius : w / 2,
		width : w,
		height : w
	}));
	self.add(Ti.UI.createLabel({
		text : require('vendor/loremipsum')(400),
		left : 10,
		top : 10,
		right : 10,
		height : Ti.UI.SIZE,
		color : '#444',
		font : {
			fontSize : 22
		}
	}));
	return self;
};