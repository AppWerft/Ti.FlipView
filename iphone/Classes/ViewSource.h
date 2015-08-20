/**
 * Ti.Pageflip Module
 * Copyright (c) 2011-2013 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import <Foundation/Foundation.h>
#import "Source.h"
#import "TiViewProxy.h"


@interface ViewSource : NSObject<Source> {
    NSMutableArray* pages;
}

-(id)initWithArray:(NSArray*)titPages andProxy:(TiProxy*)flipViewProxy;

@end
