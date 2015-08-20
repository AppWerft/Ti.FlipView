//
//  MPFlipViewController.h
//  MPFlipViewController
//
//  Created by Mark Pospesel on 6/4/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPTransitionEnumerations.h"

enum {
    MPFlipViewControllerOrientationHorizontal = 0,
    MPFlipViewControllerOrientationVertical = 1
};
typedef NSInteger MPFlipViewControllerOrientation;

/*enum {
    MPFlipViewControllerSpineLocationNone = 0, // Undefined
    MPFlipViewControllerSpineLocationMin = 1,  // Spine is at Left or Top
    MPFlipViewControllerSpineLocationMid = 2,  // Spine is in middle
    MPFlipViewControllerSpineLocationMax = 3   // Spine is at Right or Bottom
};
typedef NSInteger MPFlipViewControllerSpineLocation;*/

enum {
    MPFlipViewControllerDirectionForward,
    MPFlipViewControllerDirectionReverse
};
typedef NSInteger MPFlipViewControllerDirection; // For 'MPFlipViewControllerOrientationHorizontal', 'forward' is right-to-left, like pages in a book. For 'MPFlipViewControllerOrientationVertical', bottom-to-top, like pages in a wall calendar.


// forward declaration
@protocol MPFlipViewControllerDelegate, MPFlipViewControllerDataSource;



@interface MPFlipViewController : UIViewController<UIGestureRecognizerDelegate>

@property (nonatomic) MPFlipViewControllerOrientation orientation; // horizontal or vertical
// TODO what is this for?
@property (nonatomic, readonly) UIViewController *viewController;
@property (nonatomic) NSArray *gestureRecognizers;


@property (nonatomic, assign) id <MPFlipViewControllerDelegate> delegate;
// CHANGED to strong but does this make sense?
@property (nonatomic, strong) id <MPFlipViewControllerDataSource> dataSource; // If nil, user gesture-driven navigation will be disabled.

@property (nonatomic, assign, getter = isGestureDriven) BOOL gestureDriven;

@property (nonatomic, assign, getter = isRubberbanding) BOOL rubberbanding;


@property(nonatomic, assign) float transitionDuration;
@property(nonatomic, assign) float swipeThreshold;
@property(nonatomic, assign) float swipeEscapeVelocity;
@property(nonatomic, assign) float maxRubberbandFlipRatio;
@property (nonatomic, assign) int tapRecognitionMargin;

// designated initializer
- (id)initWithOrientation:(MPFlipViewControllerOrientation)orientation;

// flip to a new page
- (void)setViewController:(UIViewController *)destinationViewController direction:(MPFlipViewControllerDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

// programmatic bounce
-(void) bounceForward;
-(void) bounceBackward;

// slightly animate the displayed view controller to give a hint to the user that a next view controller is available.
- (void)showNextViewControllerHint;


// private method to override
- (BOOL)startFlipWithDirection:(MPFlipViewControllerDirection)direction;
- (void)startFlipToViewController:(UIViewController *)destinationController fromViewController:(UIViewController *)sourceController withDirection:(MPFlipViewControllerDirection)direction;

@end  // of interface


@protocol MPFlipViewControllerDelegate<NSObject>

@optional
// handle this to be notified when page flip animations have finished
- (void)flipViewController:(MPFlipViewController *)flipViewController didFinishAnimating:(BOOL)finished previousViewController:(UIViewController *)previousViewController transitionCompleted:(BOOL)completed;

- (void)flipViewControllerWillStartAnimating:(MPFlipViewController *)flipViewController previousViewController:(UIViewController *)previousViewController destinationViewController:(UIViewController *)destinationViewController;

// handle this and return the desired orientation (horizontal or vertical) for the new interface orientation
// called when MPFlipViewController handles willRotateToInterfaceOrientation:duration: callback
- (MPFlipViewControllerOrientation)flipViewController:(MPFlipViewController *)flipViewController orientationForInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end


@protocol MPFlipViewControllerDataSource<NSObject>

// Register UI Element Classes for which FlipView Gestures will be ignored, so Gestures will be handled by control itself
- (NSSet *)flipViewControllerClassesToIgnoreGestureHandling:(MPFlipViewController *)flipViewController;

@required

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerBeforeViewController:(UIViewController *)viewController; // get previous page, or nil for none
- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerAfterViewController:(UIViewController *)viewController; // get next page, or nil for none

@end

// Notifications
// All of the following notifications have an `object' that is the sending MPFipViewController.

// The following notification has a userInfo key "MPAnimationFinished" with an NSNumber (bool, YES/NO) value,
// an "MPTransitionCompleted" key with an NSNumber (bool, YES/NO) value,
// an "MPPreviousController" key with a UIViewController value, and
// an "MPNewController" key with a UIViewController value (will be NSNull for rubber-banding past first/last controller)
#define MPAnimationFinishedKey @"MPAnimationFinished"
#define MPTransitionCompletedKey @"MPTransitionCompleted"
#define MPPreviousControllerKey @"MPPreviousController"
#define MPNewControllerKey @"MPNewController"
extern NSString *MPFlipViewControllerDidFinishAnimatingNotification;

