/**
* Appcelerator Titanium Mobile
* Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
* Licensed under the terms of the Apache Public License
* Please see the LICENSE included with this distribution for details.
*
* Implementation of the flip view controller
*
* Initialized by the Proxy class in viewDidAttach
*
* NOTE: Ti only provides UIView objects, but our implementation of the FlipView requires UIViewControllers
*       therefore we have to implement boilerplate code :-(
*/

#import "OrgBcbhhIosFlipViewView.h"
#import "ViewSource.h"
#import "AdvancedPageFlipperPage.h" // the UIViewController wrapper class
#import "MPFlipTransition.h"


@interface OrgBcbhhIosFlipViewView ()
// (Private)

// to support rubber bending, we need some house keeping
@property(assign, nonatomic) long previousIndex;
// candidate for next index
@property(assign, nonatomic) long tentativeIndex;

// we keep the info, to clean up observers
@property(assign, nonatomic) BOOL observerAdded;

// Forward declarations

// TODO is this a protocol we implement?
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;

- (NSUInteger)indexOfViewController:(UIViewController *)viewController;

- (void)refreshCurrentPage;

@end

@implementation OrgBcbhhIosFlipViewView

@synthesize previousIndex = _previousIndex;
@synthesize tentativeIndex = _tentativeIndex;
@synthesize source;


#pragma mark Initialization and Memory Management

- (id)init {
    NSLog(@"[INFO] init view");
    if ((self = [super init])) {
        NSLog(@"[INFO] inited now setup");
        // marker for not fully initialized views
        currentPageIdx = -1;
        transitionDuration = 0.5;

        // TODO DISCUSS do we want to support a view with two visible controllers at all? Not feasible for every use case
        landscapeShowsTwoPages = NO;

        [self initFlipviewController];

        // initialize property values in JavaScript object
        [[self proxy] setValue:NUMBOOL(NO) forKey:@"landscapeShowsTwoPages"];
    }
    NSLog(@"[INFO] initFlipviewView done");
    return self;
}


// called on frameSizeChanged and init
- (void)initFlipviewController {
    NSLog(@"[INFO] initFlipviewController in Flipview %@ - flipper: %@",self,flipper );
    // TODO: Move the bulk of the advanced flipper's logic in to its class, and out of here.
    if (flipper != nil) {
        if (viewAlreadyCreated) {
            NSLog(@"removeFromSuperview called in initFlipViewController");
            [flipper.view removeFromSuperview];
        }
    }

    // TODO FIXME problem here: flipper will be re-

    // TODO currently not used
    int spineLocation = landscapeShowsTwoPages && inLandscape ? UIPageViewControllerSpineLocationMid : UIPageViewControllerSpineLocationMin;

    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:spineLocation]
                                                        forKey:UIPageViewControllerOptionSpineLocationKey];
    //if (flipper == nil) {
        // TODO make direction a property
        flipper = [[MPFlipViewController alloc] initWithOrientation:MPFlipViewControllerOrientationHorizontal];

        // The flipper will fetch it's pages from the data source, so don't have to initialize it in init
        flipper.delegate = self;
        flipper.dataSource = self;
    //}
    if (viewAlreadyCreated) {
        if (currentPageIdx == -1)
            currentPageIdx = 0;
        [self addSubview:flipper.view];
        [self refreshCurrentPage];
    }
}

- (void)initFlipviewControllerOld {
    NSLog(@"[INFO] initFlipviewController in Flipview %@ - flipper: %@",self,flipper );
    // TODO: Move the bulk of the advanced flipper's logic in to its class, and out of here.
    if (flipper != nil) {
        if (viewAlreadyCreated) {
            NSLog(@"removeFromSuperview called in initFlipViewController");
            [flipper.view removeFromSuperview];
        }
    }

    // TODO FIXME problem here: flipper will be re-

    // TODO currently not used
    int spineLocation = landscapeShowsTwoPages && inLandscape ? UIPageViewControllerSpineLocationMid : UIPageViewControllerSpineLocationMin;

    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:spineLocation]
                                                        forKey:UIPageViewControllerOptionSpineLocationKey];
    //if (flipper == nil) {
    // TODO make direction a property
    flipper = [[MPFlipViewController alloc] initWithOrientation:MPFlipViewControllerOrientationHorizontal];

    // The flipper will fetch it's pages from the data source, so don't have to initialize it in init
    flipper.delegate = self;
    flipper.dataSource = self;
    //}
    if (viewAlreadyCreated) {
        if (currentPageIdx == -1)
            currentPageIdx = 0;
        [self addSubview:flipper.view];
        [self refreshCurrentPage];
    }
}

- (void)dealloc {
    // since we are using ARC now, we have no implementation
}

#pragma mark Utility Methods

- (BOOL)isLandscape {
    return self.bounds.size.width > self.bounds.size.height;
}

+ (BOOL)isIOS5OrGreater {
    return [UIAlertView instancesRespondToSelector:@selector(alertViewStyle)];
}


// Since this class has to inherit from TiUIView we have to instantiate the flipper as sub view and proxy to it
- (void)createView {
    NSLog(@"[INFO] createView");
    // TODO CHECK when in LC will this be called
    viewAlreadyCreated = YES;
    if (currentPageIdx == -1) // not yet initialized?
        currentPageIdx = 0;   // goto first page
    [self addSubview:flipper.view];
    [self refreshCurrentPage];

}

// NOTE: vieDidUnload is never called and implemented in ViewControllers only, so we don't implement it here


// NOTE: we support only one observer
- (void)addObserver {
    if (![self observerAdded]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flipViewControllerDidFinishAnimatingNotification:) name:MPFlipViewControllerDidFinishAnimatingNotification object:nil];
        [self setObserverAdded:YES];
    }
}

- (void)removeObserver {
    if ([self observerAdded]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPFlipViewControllerDidFinishAnimatingNotification object:nil];
        [self setObserverAdded:NO];
    }
}


// Call after changing the data source, so at the current page index there is may be some other view now
// NOTE: current viewcontroller is set in the flipview here and in changeCurrentPage method
- (void)refreshCurrentPage {
    NSArray *pagesInView; // the viewcontroller(s) (in 2 page mode) visible in current page
    UIViewController *page = [self viewControllerAtIndex:currentPageIdx];

    // not yet initialized?
    if (page == nil) {
        NSLog(@"[INFO] refreshCurrentPage (page not intialized) for Index %d", currentPageIdx);
        if (currentPageIdx == 0) {
            return;
        }
        // get previous page
        page = [self viewControllerAtIndex:currentPageIdx - 1];
        if (page == nil) {
            // How can this be?
            return;
        }
        currentPageIdx = currentPageIdx - 1;
    }

    [flipper setViewController:page direction:MPFlipViewControllerDirectionForward animated:YES completion:NULL];

    // Notify proxy
    [self pageChanged:currentPageIdx withPageCount:[source numberOfPages]];
}


#pragma mark UIPageViewController Protocol

// TODO this is for Standard Page Curl support. But we need to support the protocol for MPFlipViewControllerDataSource
// TODO this will lead to creation of a wrapping controller each time
// To support view controller based flip views and the protocol UIViewControllerDataSource
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    NSLog(@"[INFO] viewControllerAtIndex %d", index);

    // TODO here we can handle prefetching of UIControllers / UIViews

    // Return the data view controller for the given index.
    long pageCount = [source numberOfPages];

    if (pageCount == 0 || index >= pageCount) {
        return nil;
    }

    // Create a new view controller and pass suitable data.
    AdvancedPageFlipperPage *dataViewController = [[AdvancedPageFlipperPage alloc] init];
    dataViewController.index = index;
    // This will add the Ti View as subview to the UIViewController so it can be used by MPFlipViewController...
    dataViewController.enclosedView = [source viewForPage:index withBounds:CGRectNull];

    return dataViewController;
}


- (NSUInteger)indexOfViewController:(UIViewController *)viewController {
    NSLog(@"[INFO] indexOfViewController");
    // NOTE: the Ti UIViews are wrapped into UIViewControllers
    if ([viewController class] != [AdvancedPageFlipperPage class]) {
        // The only way a non-properly-typed class gets in here is when we intentionally stuffed it in as a bookend view.
        return [source numberOfPages];
    }

    // the view controller keeps track of it's index
    return ((AdvancedPageFlipperPage *) viewController).index;
}

#pragma mark Protocol UIView

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds {
    NSLog(@"[INFO] frameSizeChanged");

    bool tempInLandscape = bounds.size.width > bounds.size.height;
    if ((tempInLandscape && !inLandscape) || (!tempInLandscape && inLandscape)) {
        inLandscape = tempInLandscape;
//        [self initFlipviewController];
    }
    flipper.view.frame = bounds;
}

#pragma mark Public Properties

- (void)setTransitionDuration_:(id)args {
    // TODO these ENSURE macros do not work with value type arguments
    //    ENSURE_ARG_COUNT(args, 1)
    // TODO ENSURE_SINGLE_ARG(args, <#t#>)
    transitionDuration = [TiUtils floatValue:args];

    if (flipper != nil) {
        [flipper setTransitionDuration:transitionDuration];
    }
    else {
        NSLog(@"[WARN] The transition you are using does not support transitionDurations!");
    }
}

- (void)setSwipeThreshold_:(id)args {
    float swipeThreshold = [TiUtils floatValue:args];

    if (flipper != nil) {
        [flipper setSwipeThreshold:swipeThreshold];
    }
    else {
        NSLog(@"[WARN] The transition you are using does not support transitionDurations!");
    }
}

- (void)setSwipeEscapeVelocity_:(id)args {
    float swipeEscapeVelocity = [TiUtils floatValue:args];

    if (flipper != nil) {
        [flipper setSwipeEscapeVelocity:swipeEscapeVelocity];
    }
    else {
        NSLog(@"[WARN] The transition you are using does not support transitionDurations!");
    }
}

- (void)setBounceRatio_:(id)args {
    // Bounce ratio when doing a animated bounce
    [MPFlipTransition setBounceFlipRatio:[TiUtils floatValue:args]];
}

- (void)setRubberBandRatio_:(id)args {
    float rubberBandMaxFlipRatio = [TiUtils floatValue:args];
    [flipper setMaxRubberbandFlipRatio:rubberBandMaxFlipRatio];
}

- (void)setTapRecognitionMargin_:(id)args {
    int margin = [TiUtils intValue:args];
    NSLog(@"Set tapRecognitionMargin to %i in Flipper %@", margin, flipper);
    [flipper setTapRecognitionMargin:margin];
}

- (void)setPagingMarginWidth_:(id)args {
    if (flipper != nil) {
        //flipper.pagingMarginWidth = [TiUtils dimensionValue:args];
    }
    else {
        NSLog(@"[WARN] The transition you are using does not support pagingMarginWidth!");
    }
}

- (void)setTransitionOrientation_:(id)args {
    //   ENSURE_ARG_COUNT(args, 1)
    int value = [TiUtils intValue:args];
    // TODO make this a instance variable? Or just set it in flipper
//    MPFlipViewControllerOrientation orientation;
    switch (value) {
        case MPFlipViewControllerOrientationHorizontal:
            [flipper setOrientation:MPFlipViewControllerOrientationHorizontal];
            break;
        case MPFlipViewControllerOrientationVertical:
            [flipper setOrientation:MPFlipViewControllerOrientationVertical];
            break;
        default:
            [flipper setOrientation:MPFlipViewControllerOrientationHorizontal];
            break;
    }
}

- (void)setStartPage_:(id)args {
    NSLog(@"[INFO] set startPage called");
    currentPageIdx = [TiUtils intValue:args];
}

// TODO CHECK in what sequence will the several init methods be called?

// NOTE this will be set during ctor of JavaScript object for the first time, MOST IMPORTANT METHOD!
// It is a property set method, naming convention with trailing underscore as defined by Titanium!
- (void)setPages_:(id)args {
    NSLog(@"[INFO] set Pages called");
    ENSURE_TYPE_OR_NIL(args, NSArray);

    if (args == nil)
        return;

    // here Ti Proxy and Views will be linked!
    NSLog(@"[INFO] initializing source %@",[NSDate date] );
    source = [[ViewSource alloc] initWithArray:args andProxy:self.proxy];
    NSLog(@"[INFO] source initialized %@",[NSDate date] );

    // TODO : we have to init the MPFlipViewController with the source somewhere?!!

    // the advanced flipper tracks with the TiPageflipView's pointer at the source

    NSLog(@"[INFO] calling refreshCurrentPage %@",[NSDate date] );
    [self refreshCurrentPage];
    NSLog(@"[INFO] refreshCurrentPage called %@",[NSDate date] );

}

#pragma mark - MPFlipViewControllerDelegate protocol - call back methods invoked by FlipView

// TODO after flip in TI we have to send event in implementation
- (void)flipViewController:(MPFlipViewController *)flipViewController didFinishAnimating:(BOOL)finished previousViewController:(UIViewController *)previousViewController transitionCompleted:(BOOL)completed {
    NSLog(@"[INFO] didFinishAnimating called");

    if (completed) {
        AdvancedPageFlipperPage *page = (AdvancedPageFlipperPage *) previousViewController;
        self.previousIndex = self.tentativeIndex;
        currentPageIdx = self.previousIndex; // TODO what is the reason for having two variables here??
        [self pageChanged:currentPageIdx withPageCount:[source numberOfPages]];
    }
    NSLog(@"[INFO] didFinishAnimating done");

    // TODO notify proxy (fire event) and may be update properties
}


- (void)flipViewControllerWillStartAnimating:(MPFlipViewController *)flipViewController previousViewController:(UIViewController *)previousViewController destinationViewController:(UIViewController *)destinationViewController {
    // TODO shall we provide some event data or just send a notification event to proxy
    NSLog(@"[INFO] willStartAnimating called");

    [self transitionStarted];
    NSLog(@"[INFO] willStartAnimating done");
}


// app decides in which direction we want to do the flip
// TODO TI needs a property for that
- (MPFlipViewControllerOrientation)flipViewController:(MPFlipViewController *)flipViewController orientationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return UIInterfaceOrientationIsPortrait(orientation) ? MPFlipViewControllerOrientationVertical : MPFlipViewControllerOrientationHorizontal;
    else
        return MPFlipViewControllerOrientationHorizontal;
}

#pragma mark Proxy Notification

- (void)pageChanged:(NSInteger)page withPageCount:(NSInteger)pageCount {
    NSLog(@"[INFO] in pageChanged (idx %d for %@)", page, self);
    currentPageIdx = page;
    NSLog(@"[INFO] currentPageIdx now %d)", currentPageIdx);
    NSNumber *cp = [NSNumber numberWithInteger:currentPageIdx];
    NSNumber *pc = [NSNumber numberWithInteger:pageCount];

    [[self proxy] setValue:cp forKey:@"currentPage"];
    [[self proxy] setValue:pc forKey:@"pageCount"];

    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
            cp, @"currentPage", pc, @"pageCount", nil];
    [[self proxy] fireEvent:@"change" withObject:event];
    NSLog(@"[INFO] currentPageIdx after proxyFire %d)", currentPageIdx);
}

// TODO currently this is not an event, reported to user
- (void)pageTapped:(NSInteger)page {
    NSLog(@"[INFO] in pageTapped(idx %d)", page);
    currentPageIdx = page;
    NSNumber *cp = [NSNumber numberWithInteger:currentPageIdx];
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
            cp, @"currentPage", nil];
    [[self proxy] fireEvent:@"tap" withObject:event];
}

- (void)transitionStarted {
    NSNumber *currentPage = [NSNumber numberWithInteger:currentPageIdx];
    NSNumber *candPage = [NSNumber numberWithInteger:self.tentativeIndex];
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
            currentPage, @"currentPage", candPage, @"targetPage", nil];
    [self.proxy fireEvent:@"flipStarted" withObject:event];
}


#pragma mark - MPFlipViewController DataSource protocol

- (NSSet *)flipViewControllerClassesToIgnoreGestureHandling:(MPFlipViewController *)flipViewController {
    return nil;
}

// get controller on previous page
// naming is not the best, but modelled after Apple's PageViewController
- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    // TODO this would be the place to handle prefetch
//    int index = self.previousIndex;
    long index = currentPageIdx;
    NSLog(@"[INFO] get prevViewController (prev %d)", index);
    index--;
    if (index < 0)
        return nil; // reached beginning, don't wrap
    self.tentativeIndex = index;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerAfterViewController:(UIViewController *)viewController {
    // TODO this would be the place to handle prefetch
    NSLog(@"[INFO] get nextViewController");
//    int index = self.previousIndex;
    long index = currentPageIdx;
    NSLog(@"[INFO] get nextViewController (prev %d)", index);
    index++;
    if (index > source.numberOfPages)
        return nil; // reached end, don't wrap
    self.tentativeIndex = index;
    return [self viewControllerAtIndex:index];
}


#pragma mark - Notifications - TODO Do we need this

- (void)flipViewControllerDidFinishAnimatingNotification:(NSNotification *)notification {
    NSLog(@"[INFO] Notification received: %@", notification);
}

# pragma mark Public Methods for changing data source after viewing

- (void)bounceForward:(id)args {
    NSLog(@"[INFO] Bounce forward BCB ");
    [flipper bounceForward];
}

- (void)bounceBackward:(id)args {
    NSLog(@"[INFO] Bounce backward BCB ");
    [flipper bounceBackward];
}

- (void)insertPageAfter:(id)args {
    [source insertPageAfter:args];
    // inserting means a change of data source, when already visible
    [self refreshCurrentPage]; // this refreshes not only the current page...
}

- (void)insertPageBefore:(id)args {
    [source insertPageBefore:args];
    // inserting means a change of data source, when already visible
    [self refreshCurrentPage];
}

- (void)appendPage:(id)args {
    [source appendPage:args];
    // appending means a change of data source, when already visible
    [self refreshCurrentPage];
}

- (void)deletePage:(id)args {
    [source deletePage:args];
    // deleting means a change of data source, when already visible
    [self refreshCurrentPage];
}

// Protocol as exposed to JavaScript args: [index:int, animated:bool]
- (void)changeCurrentPage:(id)args {
    // If we don't have any pages, ignore the request.
    long pageCount = [source numberOfPages];
    if (pageCount == 0) {
        NSLog(@"[WARN] Attempted to set page before specifying a data source (views or pdf) with at least one page; ignoring request.");
        return;
    }

    int requestedPageIndex = [TiUtils intValue:[args objectAtIndex:0]];
    bool animated = [args count] > 1 && [TiUtils boolValue:[args objectAtIndex:1]];

    // Bounds check to make sure we get a valid 0-based index to a page.
    if (requestedPageIndex < 0) {
        NSLog(@"[WARN] Attempted to set currentPage to %d, which is less than zero! Setting to first page instead.", requestedPageIndex);
        [[self proxy] setValue:NUMLONG(0) forKey:@"currentPage"];
        return;
    }
    if (requestedPageIndex >= pageCount) {
        NSLog(@"[WARN] Attempted to set currentPage to %d, which is above the total number of pages! Setting to last page instead.", requestedPageIndex);
        [[self proxy] setValue:NUMLONG(pageCount - 1) forKey:@"currentPage"];
        return;
    }
    if (requestedPageIndex == currentPageIdx) {
        NSLog(@"[WARN] Attempted to set currentPage to itself! Ignoring.", requestedPageIndex);
        return;
    }


    MPFlipViewControllerDirection dir;
    if (requestedPageIndex > currentPageIdx)
        dir = MPFlipViewControllerDirectionForward;
    else
        dir = MPFlipViewControllerDirectionReverse;

    // NOTE refreshCurrentPage has similar call - why don't we just call it?
    if (flipper != nil) {
        [flipper setViewController:[self viewControllerAtIndex:requestedPageIndex]
                         direction:dir animated:animated
                        completion:NULL
        ];
        // TODO why don't we call notification code in proxy here?
        [self pageChanged:requestedPageIndex withPageCount:pageCount];
    }
}


#pragma mark - Page View Controller Data Source DELETE not required by MPFlipView

// TODO REMOVE THIS not longer required

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    NSUInteger index = [self indexOfViewController:(AdvancedPageFlipperPage *) viewController];
    if ((index <= 0) || (index == NSNotFound)) {
        return nil;
    }

    // This is only handled here, because PageViewController does not fire such an event
    [self transitionStarted];

    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:(AdvancedPageFlipperPage *) viewController];
    if (index == NSNotFound) {
        return nil;
    }

    [self transitionStarted];

    index++;
    return [self viewControllerAtIndex:index];
}


@end
