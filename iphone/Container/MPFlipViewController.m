//
//  MPFlipViewController.m
//  MPFlipViewController
//
//  Created by Mark Pospesel on 6/4/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "MPFlipViewController.h"
#import	"MPFlipTransition.h"

// MARGINS left/right where tap is recognized as page turn
#define MARGIN     44

#define SWIPE_THRESHOLD    125.0f
#define SWIPE_ESCAPE_VELOCITY 650.0f
#define DEFAULT_DURATION  0.7f
#define MAX_BOUNCE_RATIO  0.667f

// Notifications
NSString *MPFlipViewControllerDidFinishAnimatingNotification = @"com.markpospesel.MPFlipViewControllerDidFinishAnimatingNotification";

@interface MPFlipViewController ()

@property(nonatomic, strong) UIViewController *childViewController;
@property(nonatomic, strong) UIViewController *sourceController;
@property(nonatomic, strong) UIViewController *destinationController;
@property(nonatomic, assign) BOOL gesturesAdded;
@property(nonatomic, readonly) BOOL isAnimating;
@property(nonatomic, assign, getter = isPanning) BOOL panning;
@property(nonatomic, strong) MPFlipTransition *flipTransition;
@property(assign, nonatomic) CGPoint panStart;
@property(assign, nonatomic) CGPoint lastPanPosition;
@property(assign, nonatomic) BOOL animationDidStartAsPan;
@property(nonatomic, assign) MPFlipViewControllerDirection direction;

@end

@implementation MPFlipViewController {
@private
    float _transitionDuration;
    float _swipeEscapeVelocity;
    float _swipeThreshold;
    float _maxRubberbandFlipRatio;
    int _tapRecognitionMargin;
}

@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;

@synthesize orientation = _orientation;
@synthesize childViewController = _childViewController;
@synthesize gestureRecognizers = _gestureRecognizers;
@synthesize gesturesAdded = _gesturesAdded;
@synthesize gestureDriven = _gestureDriven;
@synthesize panning = _panning;
@synthesize rubberbanding = _rubberbanding;
@synthesize flipTransition = _flipTransition;
@synthesize panStart = _panStart;
@synthesize lastPanPosition = _lastPanPosition;
@synthesize animationDidStartAsPan = _animationDidStartAsPan;
@synthesize direction = _direction;
@synthesize sourceController = _sourceController;
@synthesize destinationController = _destinationController;

@synthesize transitionDuration = _transitionDuration;
@synthesize swipeEscapeVelocity = _swipeEscapeVelocity;
@synthesize swipeThreshold = _swipeThreshold;
@synthesize maxRubberbandFlipRatio = _maxRubberbandFlipRatio;
@synthesize tapRecognitionMargin = _tapRecognitionMargin;


- (void)setTapRecognitionMargin:(int)tapRecognitionMargin {
   NSLog(@"[DEBUG] MPFlipviewController setTapRegcognitionMargin: %i %@", tapRecognitionMargin,self);
    _tapRecognitionMargin = tapRecognitionMargin;
}
- (id)initWithOrientation:(MPFlipViewControllerOrientation)orientation {
    NSLog(@"MPFlipviewController initWithOrientation %@",self);
    self = [super init];
    if (self) {
        // Custom initialization
        _orientation = orientation;
        _direction = MPFlipViewControllerDirectionForward;
        _gesturesAdded = NO;
        _panning = NO;
        _gestureDriven = NO;
        _rubberbanding = NO;
        _transitionDuration = DEFAULT_DURATION;
        _swipeEscapeVelocity = SWIPE_ESCAPE_VELOCITY;
        _swipeThreshold = SWIPE_THRESHOLD;
        _maxRubberbandFlipRatio = MAX_BOUNCE_RATIO;
        _tapRecognitionMargin = MARGIN;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self addGestures];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - rotation callbacks

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ![self isAnimating];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[self delegate] respondsToSelector:@selector(flipViewController:orientationForInterfaceOrientation:)])
        [self setOrientation:[[self delegate] flipViewController:self orientationForInterfaceOrientation:toInterfaceOrientation]];

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - Properties

- (UIViewController *)viewController {
    return [self childViewController];
}

- (BOOL)isAnimating {
    return [self flipTransition] != nil;
}

- (BOOL)isFlipFrontPage {
    return [[self flipTransition] stage] == MPFlipAnimationStage1;
}

- (void)setPanning:(BOOL)panning {
    if (_panning != panning) {
        _panning = panning;
        if (panning) {
            [self setAnimationDidStartAsPan:YES];
        }
    }
}

#pragma mark - private instance methods

- (void)addGestures {
    if ([self gesturesAdded])
        return;

    // Add our swipe gestures
    BOOL isHorizontal = ([self orientation] == MPFlipViewControllerOrientationHorizontal);

    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeNext:)];
    left.direction = isHorizontal ? UISwipeGestureRecognizerDirectionLeft : UISwipeGestureRecognizerDirectionUp;
    left.delegate = self;
    [self.view addGestureRecognizer:left];

    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipePrev:)];
    right.direction = isHorizontal ? UISwipeGestureRecognizerDirectionRight : UISwipeGestureRecognizerDirectionDown;
    right.delegate = self;
    [self.view addGestureRecognizer:right];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];

    self.gestureRecognizers = @[left, right, tap, pan];

    [self setGesturesAdded:YES];

}
- (void)removeGestures {
    if (self.gesturesAdded) {
        for (UIGestureRecognizer *recognizer in [[self view] gestureRecognizers]) {
            [[self view] removeGestureRecognizer:recognizer];
        }
        self.gestureRecognizers = nil;
        [self setGesturesAdded:NO];
    }
}

-(void)setOrientation:(MPFlipViewControllerOrientation)orientation {
    NSLog(@"[INFO] Orientation set to %ld" ,(long)orientation);
    _orientation = orientation;

    // we have to re-initialize the gestures since orientation plays a role in detection
    [self removeGestures];
    [self addGestures];
}

#pragma mark - public Instance methods

// This is the non interactive method to flip to another given VC
// caller has to define the direction of animation
// PRE-CON
- (void)setViewController:(UIViewController *)destinationViewController direction:(MPFlipViewControllerDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    UIViewController *sourceController = [self viewController];

    // we have to inform the ViewController about the available area
    [[destinationViewController view] setFrame:[self.view bounds]];

    [self addChildViewController:destinationViewController]; // this calls [destinationViewController willMoveToParentViewController:self] for us
    [self setChildViewController:destinationViewController];

    [sourceController willMoveToParentViewController:nil];

    if (animated && sourceController) {
        [self startFlipToViewController:destinationViewController
                     fromViewController:sourceController
                          withDirection:direction];

        [self.flipTransition perform:^(BOOL finished) {
            [self endFlipAnimation:finished transitionCompleted:YES completion:completion];
        }];
    }
    else  // NOT animated
    {
        [[self view] addSubview:[destinationViewController view]];
        [[sourceController view] removeFromSuperview];
        [destinationViewController didMoveToParentViewController:self];
        if (completion)
            completion(YES);

        [sourceController removeFromParentViewController]; // this calls [previousController didMoveToParentViewController:nil] for us
    }
}

#pragma mark - Gesture handlers

// we can define UI Elements to be ignored when handling gestures, so it would be possible to use a slider or caroussel in a flip view
- (BOOL)isIgnoredClassOnGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if ([[self dataSource] respondsToSelector:@selector(flipViewControllerClassesToIgnoreGestureHandling:)]) {
        CGPoint touchLocation = [gestureRecognizer locationInView:self.view];
        UIView *touchedView = [gestureRecognizer.view hitTest:touchLocation withEvent:nil];
        NSLog(@"[INFO] Type of TouchedView in Gesture %@",touchedView);

        return [[self.dataSource flipViewControllerClassesToIgnoreGestureHandling:self] containsObject:touchedView.class];
    }

    return NO;
}


// TAP handling - a tap is a short one finger touch event and starts an animated page change

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {

    // The following 2 checks could be extracted (if Xcode would allow this...)
    // do not react if we are in middle of an animation
    if ([self isAnimating])
        return;

    // do not react, if we want to handle in UIElement itself
    if ([self isIgnoredClassOnGestureRecognizer:gestureRecognizer])
        return;

    // first try to ignore taps
    if([self tapRecognitionMargin] == 0)
        return;

    CGPoint tapPoint = [gestureRecognizer locationInView:self.view];
    BOOL isHorizontal = [self orientation] == MPFlipViewControllerOrientationHorizontal;
    CGFloat value = isHorizontal ? tapPoint.x : tapPoint.y;
    CGFloat dimension = isHorizontal ? self.view.bounds.size.width : self.view.bounds.size.height;
    NSLog(@"[INFO] Tap to flip recognized tapPoint %f", value);

    // TODO handle reverse mode where we flip forward from top to bottom
    if (value <= _tapRecognitionMargin)
        [self gotoPreviousPage];
    else if (value >= dimension - _tapRecognitionMargin)
        [self gotoNextPage];
}

// SWIPE handling - swipe starts an animation

- (void)handleSwipePrev:(UIGestureRecognizer *)gestureRecognizer {
    if ([self isAnimating])
        return;

    if ([self isIgnoredClassOnGestureRecognizer:gestureRecognizer])
        return;

    NSLog(@"[INFO] Swipe prev recognized");
    [self gotoPreviousPage];
}

- (void)handleSwipeNext:(UIGestureRecognizer *)gestureRecognizer {
    if ([self isAnimating])
        return;

    if ([self isIgnoredClassOnGestureRecognizer:gestureRecognizer])
        return;

    NSLog(@"[INFO] Swipe next recognized");
    [self gotoNextPage];
}


// Panning is used to handle the dynamic flip where page is glued to fingertip (kind of)
// NOTE: when a pan velocity exceeds a certain threshold we assume a swipe and animate a flip!
- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {

    if ([self isIgnoredClassOnGestureRecognizer:gestureRecognizer])
        return;

    UIGestureRecognizerState state = [gestureRecognizer state];
    CGPoint currentPosition = [gestureRecognizer locationInView:self.view];

    // just started panning
    if (state == UIGestureRecognizerStateBegan) {
        // do nothing if pan occurs after swipe and animation is still in progress
        if ([self isAnimating])
            return;

        // See if touch started near one of the edges, in which case we'll pan a page turn
        BOOL isHorizontal = [self orientation] == MPFlipViewControllerOrientationHorizontal;
        CGFloat value = isHorizontal ? currentPosition.x : currentPosition.y;
        CGFloat dimension = isHorizontal ? self.view.bounds.size.width : self.view.bounds.size.height;
        if (value <= MARGIN) {
            if (![self startFlipWithDirection:MPFlipViewControllerDirectionReverse])
                return;
        }
        else if (value >= dimension - MARGIN) {
            if (![self startFlipWithDirection:MPFlipViewControllerDirectionForward])
                return;
        }
        else {
            // Do nothing for now, but it might become a swipe later
            return;
        }

        [self setPanning:YES];
        [self setPanStart:currentPosition];
        [self setLastPanPosition:currentPosition];
    }

    // TODO where does the limitation in panned flip max angle come from??

    // in the middle of a panning gesture
    if ([self isPanning] && state == UIGestureRecognizerStateChanged) {

        // TODO what does progress mean in this case?
        CGFloat progress = [self progressFromPosition:currentPosition];

        // TODO we should extract the swipe velocity detection!
        CGPoint vel = [gestureRecognizer velocityInView:gestureRecognizer.view];
        //NSLog(@"Pan position changed, velocity = %@", NSStringFromCGPoint(vel));

        // We have a component in flip direction and one in the orthogonal one
        CGFloat velocityFlipDirection = (self.orientation == MPFlipViewControllerOrientationHorizontal) ? vel.x : vel.y;
        CGFloat velocityOrthogonalDirection = (self.orientation == MPFlipViewControllerOrientationHorizontal) ? vel.y : vel.x;

        // ignore the velocity if it's mostly in the off-axis direction (e.g. don't consider left velocity if swipe is mostly up or even diagonally up-left)
        if (fabs(velocityOrthogonalDirection) > fabs(velocityFlipDirection))
            velocityFlipDirection = 0;

        if (![self isRubberbanding] && (velocityFlipDirection < -self.swipeEscapeVelocity || velocityFlipDirection > self.swipeEscapeVelocity)) {
            // Detected a swipe to the left
            NSLog(@"Escape velocity reached.");

            // if the user has changed the direction in the middle of a pan we have to go to opposite direction
            BOOL shouldFallBack = (velocityFlipDirection < -self.swipeEscapeVelocity) ? self.direction != MPFlipViewControllerDirectionForward : self.direction == MPFlipViewControllerDirectionForward;
            [self setPanning:NO];

            // finish the remaining animation, but from the last touch position
            // TODO then it is no pan any longer, is it? -> Rename
            // in case of fallBack just move flipped page to start position
            [self finishPan:shouldFallBack];
        }
        else {
            if (progress < 1) // still in the first half of animation
                [self.flipTransition setStage:MPFlipAnimationStage1 progress:progress];
            else // second half of animation, target page side of flip is visible now
                [self.flipTransition setStage:MPFlipAnimationStage2 progress:progress - 1];
            [self setLastPanPosition:currentPosition];
        }
    }

    // User has lift off his finger from screen
    if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        CGPoint vel = [gestureRecognizer velocityInView:gestureRecognizer.view];
        CGFloat velocityFlipDirection = (self.orientation == MPFlipViewControllerOrientationHorizontal) ? vel.x : vel.y;
        CGFloat velocityOrthogonalDirection = (self.orientation == MPFlipViewControllerOrientationHorizontal) ? vel.y : vel.x;
        // ignore the velocity if it's mostly in the off-axis direction (e.g. don't consider left velocity if swipe is mostly up or even diagonally up-left)
        if (fabs(velocityOrthogonalDirection) > fabs(velocityFlipDirection))
            velocityFlipDirection = 0;

        //NSLog(@"Terminal velocity = %@", NSStringFromCGPoint(vel));
        if ([self isPanning]) {
            // If moving slowly, let page fall either forward or back depending on where we were
            BOOL shouldFallBack = [self isFlipFrontPage];

            if ([self isRubberbanding])
                shouldFallBack = YES;
                // But, if user was swiping in an appropriate direction, go ahead and honor that
            else if (velocityFlipDirection < -self.swipeThreshold) {
                // Detected a swipe to the left/top
                shouldFallBack = self.direction != MPFlipViewControllerDirectionForward;
            }
            else if (velocityFlipDirection > self.swipeThreshold) {
                // Detected a swipe to the right/bottom
                shouldFallBack = self.direction == MPFlipViewControllerDirectionForward;
            }

            // finish Animation
            [self finishPan:shouldFallBack];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // don't recognize any further gestures if we're in the middle of animating a page-turn

    if ([self isAnimating])
        return NO;

    NSLog(@"[INFO] MPFlipViewController::shouldReceiveTouch");

    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]
            || [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        // for taps and pans, only handle if started within margin, otherwise don't receive so that the content may handle it
        CGPoint tapPoint = [touch locationInView:self.view];
        BOOL isHorizontal = [self orientation] == MPFlipViewControllerOrientationHorizontal;
        CGFloat value = isHorizontal ? tapPoint.x : tapPoint.y;
        CGFloat dimension = isHorizontal ? self.view.bounds.size.width : self.view.bounds.size.height;
        BOOL shouldReceive = (value <= _tapRecognitionMargin || value >= dimension - _tapRecognitionMargin);
        NSLog(@"[INFO] MPFlipViewController::shouldReceiveTouch tap/pan case: %i margin %i getter %i %@",shouldReceive,_tapRecognitionMargin, [self tapRecognitionMargin],
        self);
        return shouldReceive;
    }

    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // don't recognize simultaneously with scroll view gestures in content area
    return ![[otherGestureRecognizer view] isKindOfClass:[UIScrollView class]];

    // Allow simultanoues pan & swipe recognizers
}

#pragma mark - Private instance methods

- (CGFloat)progressFromPosition:(CGPoint)position {
    // Determine where we are in our page turn animation
    // 0 - 1 means flipping the front-side of the page
    // 1 - 2 means flipping the back-side of the page
    BOOL isForward = ([self direction] == MPFlipViewControllerDirectionForward);
    BOOL isVertical = ([self orientation] == MPFlipViewControllerOrientationVertical);

    CGFloat positionValue = isVertical ? position.y : position.x;
    CGFloat startValue = isVertical ? self.panStart.y : self.panStart.x;
    CGFloat dimensionValue = isVertical ? self.view.frame.size.height : self.view.frame.size.width;
    CGFloat difference = positionValue - startValue;
    CGFloat halfWidth = fabsf(startValue - (dimensionValue / 2));
    CGFloat progress = difference / halfWidth * (isForward ? -1 : 1);
    if ([self isRubberbanding]) {
        if ((difference > 0) == isForward)
            progress = 0;
        else {
            // version of Hill equation (AKA Langmuir absorption equation), y = Kx^n / (1 + Kx^n)
            // basically I want it to get increasingly more difficult to pull the page until we reach a maximum progress of 0.667
            halfWidth += MAX(halfWidth * 2, halfWidth + (dimensionValue / 2));
            CGFloat K = 1 / (halfWidth * 3); // K & n can be adjusted to get different reaction curves
            CGFloat n = 1.6667;
            CGFloat temp = K * powf(fabs(difference), n);
            progress = self.maxRubberbandFlipRatio * (temp / (1 + temp)); // scale it to never get past 0.6667 (normally it is asymptotic to 1)
        }
    }

    //NSLog(@"Difference = %.2f, Half width = %.2f, rawProgress = %.4f", difference, halfWidth, progress);
    if (progress < 0)
        progress = 0;
    if (progress > 2)
        progress = 2;
    return progress;
}

- (void)finishPan:(BOOL)shouldFallBack {
    // finishAnimation
    CGFloat fromProgress = [self progressFromPosition:[self lastPanPosition]];
    if (shouldFallBack != [self isFlipFrontPage]) {
        // 2-stage animation (we're swiping either forward or back)
        if (([self isFlipFrontPage] && fromProgress > 1) || (![self isFlipFrontPage] && fromProgress < 1))
            fromProgress = 1;
        if (fromProgress > 1)
            fromProgress -= 1;
    }
    else {
        // 1-stage animation
        if (!shouldFallBack)
            fromProgress -= 1;
    }
    [[self flipTransition] animateFromProgress:fromProgress shouldFallBack:shouldFallBack completion:^(BOOL finished) {
        [self endFlipAnimation:finished transitionCompleted:!shouldFallBack completion:nil];
    }];
}

- (BOOL)startFlipWithDirection:(MPFlipViewControllerDirection)direction {
    NSLog(@"[INFO] MPFlipViewController::startFlipWithDirection");
    if (![self dataSource])
        return NO;

    UIViewController *destinationController = (direction == MPFlipViewControllerDirectionForward) ?
            [[self dataSource] flipViewController:self viewControllerAfterViewController:[self viewController]] :
            [[self dataSource] flipViewController:self viewControllerBeforeViewController:[self viewController]];

    if (!destinationController) {
        // we're at first or last page, but allow user to lift up current page a bit,
        // so we'll pass in a dummy blank page to show behind
        [self setRubberbanding:YES];
    }

    [self setGestureDriven:YES];
    [self startFlipToViewController:destinationController fromViewController:[self viewController] withDirection:direction];

    return YES;
}

- (void)startFlipToViewController:(UIViewController *)destinationController fromViewController:(UIViewController *)sourceController withDirection:(MPFlipViewControllerDirection)direction {
    BOOL isForward = (direction == MPFlipViewControllerDirectionForward);
    BOOL isVertical = ([self orientation] == MPFlipViewControllerOrientationVertical);
    [self setSourceController:sourceController];
    [self setDestinationController:destinationController];
    [self setDirection:direction];
    self.flipTransition = [[MPFlipTransition alloc] initWithSourceView:[sourceController view]
                                                       destinationView:[destinationController view]
                                                              duration:self.transitionDuration
                                                                 style:((isForward ? MPFlipStyleDefault : MPFlipStyleDirectionBackward) | (isVertical ? MPFlipStyleOrientationVertical : MPFlipStyleDefault))
                                                      completionAction:MPTransitionActionAddRemove];

    [self.flipTransition buildLayers];

    // set the back page in the vertical position (midpoint of animation)
    [self.flipTransition prepareForStage2];

    // Call delegate
    if ([self isGestureDriven]) {
        // TODO if we use setViewController, the caller is responsible to stop Audio/Video before calling
        if ([self.delegate respondsToSelector:@selector(flipViewControllerWillStartAnimating:previousViewController:destinationViewController:)]) {
            [self.delegate flipViewControllerWillStartAnimating:self previousViewController:self.sourceController destinationViewController:destinationController];
        }
    }
}

- (void)endFlipAnimation:(BOOL)animationFinished transitionCompleted:(BOOL)transitionCompleted completion:(void (^)(BOOL finished))completion {
    BOOL didStartAsPan = [self animationDidStartAsPan];
    // clear some flags
    [self setFlipTransition:nil];
    [self setPanning:NO];
    [self setAnimationDidStartAsPan:NO];

    if (transitionCompleted) {
        // If page turn was completed, then we need to send our various notifications as per the Containment API
        if (didStartAsPan) {
            // these weren't sent at beginning (because we couldn't know beforehand
            // whether the gesture would result in a page turn or not)
            [self addChildViewController:self.destinationController]; // this calls [self.destinationController willMoveToParentViewController:self] for us
            [self setChildViewController:self.destinationController];
            [self.sourceController willMoveToParentViewController:nil];
        }

        // final set of containment notifications
        [self.destinationController didMoveToParentViewController:self];
        [self.sourceController removeFromParentViewController]; // this calls [self.sourceController didMoveToParentViewController:nil] for us
    }

    if (completion)
        completion(animationFinished);

    if ([self isGestureDriven]) {
        // notify delegate that we finished the page turn animation, indicating whether the user actually completed the page turn
        // or not, and also whether the animation ran to completion or not
        if ([[self delegate] respondsToSelector:@selector(flipViewController:didFinishAnimating:previousViewController:transitionCompleted:)]) {
            [[self delegate] flipViewController:self didFinishAnimating:animationFinished previousViewController:self.sourceController transitionCompleted:transitionCompleted];
        }

        // Send notification.
        id previousController = self.sourceController ? self.sourceController : [NSNull null];
        id newController = self.destinationController ? self.destinationController : [NSNull null];
        NSDictionary *info = @{MPAnimationFinishedKey : @(animationFinished),
                MPTransitionCompletedKey : @(transitionCompleted),
                MPPreviousControllerKey : previousController,
                MPNewControllerKey : newController};

        // TODO what is the difference between protocol based notification and notification based approach?
        [[NSNotificationCenter defaultCenter] postNotificationName:MPFlipViewControllerDidFinishAnimatingNotification
                                                            object:self
                                                          userInfo:info];
    }

    // clear remaining flags
    self.sourceController = nil;
    self.destinationController = nil;
    [self setGestureDriven:NO];
    [self setRubberbanding:NO];
}


// Animated Page Changes

-(void) bounceBackward{
    NSLog(@"[INFO] bounce backward in MPFlipViewController called");
    [self bounce:MPFlipViewControllerDirectionReverse];
}
-(void) bounceForward{
    NSLog(@"[INFO] bounce forward in MPFlipViewController called");
    [self bounce:MPFlipViewControllerDirectionForward];
}
- (void)showNextViewControllerHint
{
    [self setRubberbanding:YES];
    [self startFlipToViewController:nil fromViewController:self.childViewController withDirection:MPFlipViewControllerDirectionForward];
    [self.flipTransition performRubberband:^(BOOL finished) {
        [self endFlipAnimation:finished transitionCompleted:NO completion:nil];
    }];
}


// Private
-(void) bounce:(MPFlipViewControllerDirection)direction {
    if ([self isAnimating])
        return;

    [self setRubberbanding:YES];
    [self startFlipToViewController:nil fromViewController:self.childViewController withDirection:direction];
    [self.flipTransition performRubberband:^(BOOL finished) {
        [self endFlipAnimation:finished transitionCompleted:NO completion:nil];
    }];
}


- (void)gotoPreviousPage {
    if (![self dataSource])
        return;

    UIViewController *previousController = [[self dataSource] flipViewController:self viewControllerBeforeViewController:[self viewController]];
    if (!previousController) {
        [self setRubberbanding:YES];
        [self startFlipToViewController:nil fromViewController:self.childViewController withDirection:MPFlipViewControllerDirectionReverse];
        [self.flipTransition performRubberband:^(BOOL finished) {
            [self endFlipAnimation:finished transitionCompleted:NO completion:nil];
        }];
        return;
    }

    [self setGestureDriven:YES]; // is this always gesture driven or can this be called by public API?
    [self setViewController:previousController direction:MPFlipViewControllerDirectionReverse animated:YES completion:nil];
}

- (void)gotoNextPage {
    if (![self dataSource])
        return;

    UIViewController *nextController = [[self dataSource] flipViewController:self viewControllerAfterViewController:[self viewController]];
    if (!nextController) {
        [self setRubberbanding:YES];
        [self startFlipToViewController:nil fromViewController:self.childViewController withDirection:MPFlipViewControllerDirectionForward];
        [self.flipTransition performRubberband:^(BOOL finished) {
            [self endFlipAnimation:finished transitionCompleted:NO completion:nil];
        }];
        return;
    }

    [self setGestureDriven:YES];
    [self setViewController:nextController direction:MPFlipViewControllerDirectionForward animated:YES completion:nil];
}

@end
