//
//  CCPanZoomController.h
//  sat
//
//  Created by Frederic Jacobs on 4/20/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "cocos2d.h"

#define kCCPanZoomControllerHistoryCount 12

typedef struct {
    float time;
    CGPoint pt;
} CCPanZoomTimePointStamp;

@interface CCPanZoomController : NSObject<CCTargetedTouchDelegate>
{	
    //properties
    CCNode  *_node;

    //bounding rect
    CGPoint _tr;
    CGPoint _bl;
    
    //window rect
    CGPoint _winTr;
    CGPoint _winBl;
    
    BOOL    _centerOnPinch;
    BOOL    _zoomOnDoubleTap;
    float   _zoomRate;
    float   _zoomInLimit;
    float   _zoomOutLimit;
    float   _swipeVelocityMultiplier;
    float   _scrollDuration;
    float   _scrollDamping;
    float   _pinchDamping;
    float   _pinchDistanceThreshold;
    float   _doubleTapZoomDuration;
    
    //internals    
    float	_time;
    int     _timePointStampCounter;
    CCPanZoomTimePointStamp _history[kCCPanZoomControllerHistoryCount];

	
	//touches
	CGPoint _firstTouch;
	float   _firstLength;
	float   _oldScale;
	
    //keep track of touches in order
	NSMutableArray *_touches;
    
    //keep around swipe action to get rid of it if needed
    CCAction *_lastScrollAction;
}

@property (readwrite, assign) CGRect    boundingRect;   /*!< The max bounds you want to scroll */
@property (readwrite, assign) CGRect    windowRect;     /*!< The boundary of your window, by default uses winSize of CCDirector */
@property (readwrite, assign) BOOL      centerOnPinch;  /*!< Should zoom center on pinch pts, default is YES */
@property (readwrite, assign) BOOL      zoomOnDoubleTap;/*!< Should we zoom in/out on double-tap */
@property (readwrite, assign) float     zoomRate;       /*!< How much to zoom based on movement of pinch */
@property (readwrite, assign) float     zoomInLimit;    /*!< The smallest zoom level */
@property (readwrite, assign) float     zoomOutLimit;   /*!< The hightest zoom level */
@property (readwrite, assign) float     swipeVelocityMultiplier; /*!< The velocity factor of the swipe's scroll action */
@property (readwrite, assign) float     scrollDuration; /*!< Duration of the scroll action after a swipe */
@property (readwrite, assign) float     scrollDamping;  /*!< When scrolling around, this will dampen the movement */
@property (readwrite, assign) float     pinchDamping;   /*!< When zooming, this will dampen the zoom */
@property (readwrite, assign) float     pinchDistanceThreshold; /*!< The distance moved before a pinch is recognized */
@property (readonly) float              optimalZoomOutLimit; /*!< Get the optimal zoomOutLimit for the current state */
@property (readwrite, assign) float     doubleTapZoomDuration;  /*!< Duration of zoom after double-tap */

/*! Create a new control with the node you want to scroll/zoom */
+ (id) controllerWithNode:(CCNode*)node;

/*! Initialize a new control with the node you want to scroll/zoom */
- (id) initWithNode:(CCNode*)node;

/*! Scroll to position */
- (void) updatePosition:(CGPoint)pos;

/*! Center point in window view */
- (void) centerOnPoint:(CGPoint)pt;

/*! Center point in window view with a given duration */
- (void) centerOnPoint:(CGPoint)pt duration:(float)duration rate:(float)rate;

/*! Zoom in on point with duration */
- (void) zoomInOnPoint:(CGPoint)pt duration:(float)duration;

/*! Zoom out on point with duration */
- (void) zoomOutOnPoint:(CGPoint)pt duration:(float)duration;

/*! Zoom to a scale on a point with a given duration */
- (void) zoomOnPoint:(CGPoint)pt duration:(float)duration scale:(float)scale;

/*! Enable touches, convenience method really */
- (void) enableWithTouchPriority:(int)priority swallowsTouches:(BOOL)swallowsTouches;

/*! Disable touches */
- (void) disable;

@end
