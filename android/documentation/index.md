# TiAndroidFlip API

## Properties

* __currentPage__ `Number` - Index of the active page
* __views__ `Ti.UI.View[]` - The pages within the flipView
* __orientation__ `String` - The flipping orientation (either _ORIENTATION_VERTICAL_ or _ORIENTATION_HORIZONTAL_)
* __overFlipMode__ `Number` - Same as OverScrollMode on ScrollableView (use _OVERFLIPMODE_GLOW_ to get the default android overscroll indicator or use  _OVERFLIPMODE_RUBBER_BAND_ to use a more iOS-like indication  )

## Methods

* __getViews( )__ - Gets the value of the __views__ property.
* __setViews( `views` )__ - Sets the value of the __views__ property.
  - `views`: `Ti.UI.View[]` - The pages within the flipView
* __addView( )__ - Adds a new page to the flipView
* __removeView( `view` )__ - Removes an existing page from the flipView
  - `view`: `Number/Ti.UI.View` - index or view of the page
* __flipToView( `view` )__ - flips to a specific page
  - `view`: `Number/Ti.UI.View` - index or view of the page
* __movePrevious( )__ - Sets the current page to the previous consecutive page in __views__.
* __moveNext( )__ - Sets the current page to the next consecutive page in __views__.
* __getCurrentPage( )__ - Gets the value of the __currentPage__ property.
* __getCurrentPage( `currentPage` )__ - Sets the value of the __currentPage__ property.

## Events

* __flipped__ - fired when page was flipped
  * `index` - index of the new page
