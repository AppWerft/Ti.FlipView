/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "OrgBcbhhIosFlipViewViewProxy.h"
#import "OrgBcbhhIosFlipViewView.h"
#import "TiUtils.h"

@implementation OrgBcbhhIosFlipViewViewProxy
-(id)init
{
    return [super init];
}

-(TiUIView*)newView {
    return [super newView];
}

// TODO CHECK what is the difference between viewDidAttach and viewDidLoad and other LC methods?
-(void)viewDidAttach
{
    [(OrgBcbhhIosFlipViewView*)[self view] createView];
}

// NOTE: all methods have to be implemented by corresponding View although they are declared in this proxy
// Properties reachable from JS are defined in the view only and have to follow a naming convention

#ifndef USE_VIEW_FOR_UI_METHOD
#define USE_VIEW_FOR_UI_METHOD(methodname)\
      -(void)methodname:(id)args\
     {\
     [self makeViewPerformSelector:@selector(methodname:) withObject:args createIfNeeded:YES waitUntilDone:NO];\
     }
#endif

USE_VIEW_FOR_UI_METHOD(insertPageAfter);
USE_VIEW_FOR_UI_METHOD(insertPageBefore);
USE_VIEW_FOR_UI_METHOD(appendPage);
USE_VIEW_FOR_UI_METHOD(deletePage);

// TODO TBD: shall we rename this method? It triggers a flip to a certain page index?
USE_VIEW_FOR_UI_METHOD(changeCurrentPage);

// programmatic bounce support
USE_VIEW_FOR_UI_METHOD(bounceForward);
USE_VIEW_FOR_UI_METHOD(bounceBackward);

- (void)childWillResize:(TiViewProxy *)child {
    //[super childWillResize:child];
}

- (void)startLayout:(id)arg {
    NSLog(@"[DEBUG] FlipViewProxy startLayout %@",[NSDate date] );
    [super startLayout:arg];
    NSLog(@"[DEBUG] FlipViewProxy startedLayout %@",[NSDate date] );
}

- (void)finishLayout:(id)arg {
    NSLog(@"[DEBUG] FlipViewProxy finishLayout %@",[NSDate date] );
    [super finishLayout:arg];
    NSLog(@"[DEBUG] FlipViewProxy finishedLayout %@",[NSDate date] );
}

- (void)updateLayout:(id)arg {
    NSLog(@"[DEBUG] FlipViewProxy updateLayout %@",[NSDate date] );
    [super updateLayout:arg];
    NSLog(@"[DEBUG] FlipViewProxy updatedLayout %@",[NSDate date] );
}

@end
