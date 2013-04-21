//
//  HelloWorldLayer.mm
//  sat
//
//  Created by Christine Corbett Moran on 4/20/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

// Import the interfaces
#import "UniverseLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "PhysicsSprite.h"

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface UniverseLayer()
-(void) initPhysics;
@end

@implementation UniverseLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	UniverseLayer *layer = [UniverseLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;

		// init physics
		[self initPhysics];

		[self scheduleUpdate];
		
        CGRect boundingRect = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
	
		_controller = [[CCPanZoomController controllerWithNode:self] retain];
        _controller.boundingRect = boundingRect;
        _controller.zoomOutLimit = 1;
        _controller.zoomInLimit = 3;
		_controller.zoomOnDoubleTap = FALSE;
        [_controller enableWithTouchPriority:0 swallowsTouches:NO];
		
	}
	return self;
}




-(void) initPhysics {
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, 0.0f);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	m_debugDraw->SetFlags(flags);
	
	_satellites = [[NSMutableArray alloc] init];
  _planets = [[NSMutableArray alloc] init];
	
	[self addPlanet:s.width/2 yCoord:s.height/2  radius:s.width/10 imageNamed:@"earth.png"];
}

-(void) draw {
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();
	
	kmGLPopMatrix();
}

-(void)addPlanet:(float)pX yCoord:(float)pY radius:(float)r imageNamed:(NSString*)planetImage{
	b2FixtureDef fixtureDef;
	fixtureDef.restitution=0;
	fixtureDef.density = 1;
	b2CircleShape circleShape;
	circleShape.m_radius = r/PTM_RATIO;
	fixtureDef.shape = &circleShape;
	
	b2BodyDef bodyDef;
	
	b2Vec2 planetCoords;
	planetCoords.x = pX/PTM_RATIO;
	planetCoords.y= pY/PTM_RATIO;
	
	bodyDef.position=planetCoords;
	b2Body *thePlanet = world->CreateBody(&bodyDef);
	PhysicsSprite *sprite = [PhysicsSprite spriteWithFile:planetImage];

	sprite.position=ccp(pX/PTM_RATIO,pY/PTM_RATIO);
	[sprite setPhysicsBody:thePlanet];
	thePlanet->CreateFixture(&fixtureDef);
	[_planets addObject:sprite];
  [self addChild:sprite];
	
}





-(void) addNewSpriteAtPosition:(CGPoint)p imageNamed:(NSString*)bodyImage {
    CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
  
    PhysicsSprite *sprite = [PhysicsSprite spriteWithFile:bodyImage];
    sprite.oldvel=0;
    sprite.velchange=0;
    sprite.oldDis=0;
    sprite.position = ccp( p.x, p.y);
    
    // Define the dynamic body.
    //Set up a 1m squared box in the physics world
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    b2Body *body = world->CreateBody(&bodyDef);
    
    // Define another box shape for our dynamic body.
    b2PolygonShape dynamicBox;
    dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
    
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBox;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    body->CreateFixture(&fixtureDef);
    
    
    [sprite setPhysicsBody:body];
    body->SetUserData(sprite);

    // actually apply a force!
    b2Vec2 force = b2Vec2(25,52);
    CGSize s = [[CCDirector sharedDirector] winSize];
    b2Vec2 center = b2Vec2(s.height,s.width);

    body->ApplyForce(force, center);
    [_satellites addObject:sprite];
    [self addChild:sprite];
  }



-(void) update: (ccTime) dt {
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 10;
	int32 positionIterations = 10;
  
  
  world->Step(1/30.0, velocityIterations , positionIterations);
  world->ClearForces();
  for (PhysicsSprite *sat in _satellites){
    b2Vec2 debrisPosition=[sat getPhysicsBody]->GetWorldCenter();
    for(PhysicsSprite *planet  in _planets){
      
      b2CircleShape *planetShape=(b2CircleShape *)([planet getPhysicsBody]->GetFixtureList()->GetShape());
      //Unfortunately Box2D static bodies do not have mass, so I need to get the circle shape of the planet. So in this case the bigger the radius, the more intense the gravity attraction. TODO: make this mass physical
      float planetRadius = planetShape->m_radius;
      b2Vec2 planetPosition=[planet getPhysicsBody]->GetWorldCenter();
      b2Vec2 planetDistance = b2Vec2(0,0);
      planetDistance+=debrisPosition;
      planetDistance-=planetPosition;
      float finalDistance = planetDistance.Length();
      // Checks if the debris should be affected by planet gravity (in this case, the debris must be within a radius of three times the planet radius) TODO: we probably always want it to be affected in our sim
      if (finalDistance<=planetRadius*10) {
        // Inverts planet distance, so that the force will move the debris in the direction of the planet origin
        planetDistance.x=-planetDistance.x;
        planetDistance.y=-planetDistance.y;
        // make gravity attraction weaker when the debris is far from the planet, and stronger when the debris is getting close to the planet TODO: make this physical
        float vecSum=abs(planetDistance.x)+abs(planetDistance.y);
        planetDistance*=(1/vecSum)*planetRadius/finalDistance;
        // This is the final formula to make the gravity weaker as we move far from the planet TODO: do we want this?
        [sat getPhysicsBody]->ApplyForce(planetDistance, [sat getPhysicsBody]->GetWorldCenter());
      }
    }
  }
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if ([touches count] == 1) {
		UITouch *touch = [touches anyObject];
		self.tapPoint = [touch locationInView:[[CCDirector sharedDirector]view]];
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([touches count] == 1) {
		UITouch *touch = [touches anyObject];
		
		//if (CGPointEqualToPoint([touch locationInView:[[CCDirector sharedDirector]view]], self.tapPoint)){
			for( UITouch *touch in touches ) {
				CGPoint location = [touch locationInView: [touch view]];
				
				NSLog(@"UIView Location: height :%f width: %f", location.x, location.y);
				
				// This fixes the OpenGL vs UIKit coordinates but some bug persists for the x axis (width of the device)
				
				location = [[CCDirector sharedDirector] convertToUI:location];

				[self addNewSpriteAtPosition: location imageNamed:@"iss.png"];
			}
		}
	//}
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
	[super dealloc];
}

@end
