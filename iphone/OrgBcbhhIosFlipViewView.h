/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TiModule.h"
#import "TiUtils.h"
#import "TiUIView.h"
#import "Protocols.h"
#import "Source.h"
#import "KrollCallback.h"
#import "MPFlipViewController.h"


@interface OrgBcbhhIosFlipViewView : TiUIView <BCBPageFlipperDelegate
, MPFlipViewControllerDelegate, MPFlipViewControllerDataSource> {

    // TODO what is the difference between these and properties and private instance vars?

    // the flip view contains the pages
    MPFlipViewController *flipper;

    NSObject<Source>* source;

    // TODO remove this, we do not support two pages at the moment
    bool landscapeShowsTwoPages;
    bool inLandscape;

    // when using automation this is the duration in seconds
    float transitionDuration;
    bool viewAlreadyCreated;
    long currentPageIdx;

}


// TODO does this have to be strong?
@property (strong, nonatomic) NSObject<Source>* source;

-(void)createView;

@end
