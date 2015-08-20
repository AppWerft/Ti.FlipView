/**
 * Ti.Pageflip Module
 * Copyright (c) 2011-2013 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "ViewSource.h"


@implementation ViewSource {
    TiProxy *_flipViewProxy;
}


#pragma mark Initialization

-(id)initWithArray:(NSArray*)titPages andProxy:(TiProxy*)flipViewProxy
{
    _flipViewProxy = flipViewProxy;
    if ((self = [super init])) {
        // Pages are Views created in Titanium
        pages = [titPages mutableCopy];

        NSLog(@"[DEBUG] Viewsource registering view hierarchie %@",[NSDate date] );
        TiViewProxy* proxy = (TiViewProxy*) flipViewProxy;
        for (TiViewProxy* page in pages) {
            // we have to remember the page proxies otherwise GC of Titanium will
            // destroy the page proxies
            [_flipViewProxy rememberProxy:page];
            // TODO CHECK : can postpone this call to when page is about to be visible?
//            [page setParent:proxy];  // without this call, we will see only top nodes of children

            // just hide by making transparent?
            page.view.alpha = 0;
        }
        NSLog(@"[DEBUG] Viewsource begin layout %@",[NSDate date] );

        [proxy layoutChildren:NO];
    }
    return self;
}

- (void)dealloc {
    // we have to cleanup proxies for pages, when flip view will be destroyed, haven't we?
    for (TiViewProxy* page in pages) {
        [[page parent] forgetProxy:page];
    }
    _flipViewProxy = nil;
}

#pragma mark Data Source

- (NSInteger)numberOfPages
{
    return [pages count];
}

- (UIView*)viewForPage:(NSInteger)page withBounds:(CGRect)bounds
{
    NSLog(@"[INFO] ViewSource::viewForPage %d",page);
    TiViewProxy *pageView = pages[page];
    if([pageView parent] == nil) {
        NSLog(@"[INFO] setting of parent required");
        [pageView setParent:_flipViewProxy];
    }

    UIView* view = [pages[page] view];

    // TODO does this call mean, we should be visible?
    view.alpha = 1;
    if (!CGRectIsNull(bounds)) {
        [view setFrame:bounds];
        [view setNeedsDisplay];
        // TODO CHECK why do we call this stuff here
        NSLog(@"[INFO] call removeFromSuperView");
        [view performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
    }
    return view;
}


# pragma mark Public APIs

// TODO CHECK what happens if we call this when view is already visible? Is there a binding?
// TODO where do we get the flip view from?

// args: [index,UIView]
-(void)insertPageAfter:(id)args
{
    NSLog(@"[INFO] insertPageAfter");
    int index = [TiUtils intValue:[args objectAtIndex:0]];
    if (index < 0 || index >= [pages count])
        return;
	TiViewProxy *page = [args objectAtIndex:1];
    [_flipViewProxy rememberProxy:page];
    [pages insertObject:page atIndex:index+1];
}

// args: [index,UIView]
-(void)insertPageBefore:(id)args
{
    NSLog(@"[INFO] insertPageBefore");
    int index = [TiUtils intValue:[args objectAtIndex:0]];
    if (index < 0 || index >= [pages count])
        return;
	TiViewProxy *page = [args objectAtIndex:1];
    [_flipViewProxy rememberProxy:page];
    [pages insertObject:page atIndex:index];
}

// args: [UIView]
-(void)appendPage:(id)args
{
    NSLog(@"[INFO] appendPage");
    TiViewProxy *page = [args objectAtIndex:0];
    [_flipViewProxy rememberProxy:page];
    [pages addObject:page];
}

// args: [UIView]
-(void)deletePage:(id)args
{
    NSLog(@"[INFO] deletePage");
    int index = [TiUtils intValue:[args objectAtIndex:0]];
    if (index < 0 || index >= [pages count])
        return;

    // release proxy connection from flip view to page, when removing page
    TiViewProxy *page =  pages[index];
    [page.parent forgetProxy:page];

    [pages removeObjectAtIndex:index];
}


@end
