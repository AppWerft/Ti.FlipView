/**
 * Ti.Pageflip Module
 * Copyright (c) 2011-2013 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "AdvancedPageFlipperPage.h"
#import <UIKit/UIKit.h>

#if  __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0

@implementation AdvancedPageFlipperPage

@synthesize index = _index;
@synthesize enclosedView = _enclosedView;

-(void)viewDidLoad
{
    [super viewDidLoad];
    if (_enclosedView != nil) {
        [_enclosedView setFrame:self.view.bounds];
        [self.view addSubview:[self enclosedView]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // we have to access the Titanium based parent ViewController here
    return [[[TiApp app] controller] shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

-(void)dealloc
{
}

@end

@implementation AdvancedPageFlipperEmptyPage

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [[[TiApp app] controller] shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

@end

#endif