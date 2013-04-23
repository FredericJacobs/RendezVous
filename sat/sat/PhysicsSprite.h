//
//  PhysicsSprite.h
//  cocos2d-ios
//
//  Created by Ricardo Quesada on 1/4/12.
//  Copyright (c) 2012 Zynga. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"

enum  {
  PLANET=1,
  SATELLITE=2,
  ROCKET=3
} bodyType;
@interface PhysicsSprite : CCSprite
{
	b2Body *body_;	// strong ref

}
@property (nonatomic) float oldvel;
@property (nonatomic) float velchange;
@property (nonatomic) float oldDis;
@property (nonatomic) int type;
-(void) setPhysicsBody:(b2Body*)body;
-(b2Body*) getPhysicsBody;

@end