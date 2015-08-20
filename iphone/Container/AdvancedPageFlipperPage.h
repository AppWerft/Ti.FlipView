/**
 * Ti.Pageflip Module
 * Copyright (c) 2011-2013 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#ifndef __IPHONE_5_0
#define __IPHONE_5_0     50000
#endif

#import <UIKit/UIKit.h>
#import "TiApp.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0

// Simple ViewController Wrapper class for views as provided by Titanium
@interface AdvancedPageFlipperPage : UIViewController {
}

// We keep track of index in page (ViewController) collection
@property (nonatomic) NSUInteger index;
@property (strong, nonatomic) UIView* enclosedView;

@end

@interface AdvancedPageFlipperEmptyPage : UIViewController
@end

#endif