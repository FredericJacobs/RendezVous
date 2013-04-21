//
//  UniverseLayer.h
//  sat
//
//  Created by Christine Corbett Moran on 4/20/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "CCPanZoomController.h"
#import "PhysicsSprite.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// HelloWorldLayer
@interface UniverseLayer : CCLayer
{
	CCTexture2D *spriteTexture_;	// weak ref
	b2World *world;
	CCSprite *earth;
	CCPanZoomController *_controller;
	GLESDebugDraw *m_debugDraw;		// strong ref
	UIButton *launchButton;
}

@property (nonatomic,strong) NSMutableArray *planets;
@property (nonatomic,strong) NSMutableArray *satellites;
@property (nonatomic) float oldDistance;
@property (nonatomic,strong) PhysicsSprite *orbitCanvas;
@property (nonatomic) BOOL doMoveLeft;
@property CGPoint tapPoint;
// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
