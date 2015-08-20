/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <Foundation/Foundation.h>
#import "TiUtils.h"
#import "TiViewProxy.h"


@interface OrgBcbhhIosFlipViewViewProxy : TiViewProxy {
    // TODO define the API
}
-(void)insertPageAfter:(id)args;
-(void)insertPageBefore:(id)args;
-(void)appendPage:(id)args;
-(void)deletePage:(id)args;

-(void)changeCurrentPage:(id)args;

@end
