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

+(CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	CCLayer *backgroundLayer = [CCLayer node];
	
	CCSprite *backgroundSprite = [[CCSprite alloc]initWithFile:@"bigbackground.png"];
	backgroundSprite.scale = 1.0f;
	
	[backgroundLayer addChild:backgroundSprite z:0];
	
	[scene addChild:backgroundLayer z:0];
	// 'layer' is an autorelease object.
	UniverseLayer *layer = [UniverseLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

#pragma mark Initialization methods (Cocos 2D controller, graphics and physics)

-(id) init {
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
		
		//Setting up the button that will be used to launch the rocket.
		
		launchButton = [UIButton buttonWithType:UIButtonTypeCustom];
		float sizeOfButton = 80;
		launchButton.frame = CGRectMake([[UIScreen mainScreen]bounds].size.height - sizeOfButton, [UIScreen mainScreen].bounds.size.width - sizeOfButton, sizeOfButton, sizeOfButton);
		UIImage *launchButtonImage = [UIImage imageNamed:@"LaunchButton.png"];
		[launchButton setBackgroundImage:launchButtonImage forState:UIControlStateNormal];
		[launchButton addTarget:self action:@selector(launchButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
		[[[CCDirector sharedDirector]view]addSubview:launchButton];
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
	
	//m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	//world->SetDebugDraw(m_debugDraw);
	
	//uint32 flags = 0;
	//flags += b2Draw::e_shapeBit;
	//m_debugDraw->SetFlags(flags);
	
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
#pragma mark Planet and Rocket operations


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
  thePlanet->CreateFixture(&fixtureDef);

	PhysicsSprite *sprite = [PhysicsSprite spriteWithFile:planetImage];

	sprite.position=ccp(pX/PTM_RATIO,pY/PTM_RATIO);
	[sprite setPhysicsBody:thePlanet];
	[_planets addObject:sprite];
  [self addChild:sprite];
	
}



-(void) addRocketAtPosition:(CGPoint)p  inDirection:(b2Vec2)direction imageNamed:(NSString*)bodyImage {
  CGSize s = [[CCDirector sharedDirector] winSize];
  PhysicsSprite *sprite = [PhysicsSprite spriteWithFile:bodyImage];
  sprite.position = ccp( p.x, p.y);
  b2BodyDef bodyDef;
  bodyDef.type = b2_dynamicBody;
  bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
  b2Body *body = world->CreateBody(&bodyDef);
  b2Vec2 center = b2Vec2(s.height,s.width);
  body->ApplyForce(direction, center);
  [sprite setPhysicsBody:body];
  [self addChild:sprite];
}


-(void) addNewSatAtPosition:(CGPoint)p imageNamed:(NSString*)bodyImage {

    CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
  
    PhysicsSprite *sprite = [PhysicsSprite spriteWithFile:bodyImage];
    sprite.oldvel=0;
    sprite.velchange=0;
    sprite.oldDis=0;
    sprite.position = ccp( p.x, p.y);
    CGSize s = [[CCDirector sharedDirector] winSize];
    // Define the dynamic body.
    //Set up a 1m squared box in the physics world
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    b2Body *body = world->CreateBody(&bodyDef);
    
    // Define another box shape for our dynamic body.
    b2PolygonShape dynamicBox;
    dynamicBox.SetAsBox(.3f, .3f);//These are mid points for our 1m box
    
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBox;
    fixtureDef.density = 10.0f;
    fixtureDef.friction = 0.3f;
    body->CreateFixture(&fixtureDef);
    body->SetFixedRotation(true);
  
    
    [sprite setPhysicsBody:body];
    body->SetUserData(sprite);

    // actually apply a force!
    b2Vec2 force = b2Vec2(25,52);
 
    b2Vec2 center = b2Vec2(s.height,s.width);

    body->ApplyForce(force, center);
    [_satellites addObject:sprite];
    [self addChild:sprite];
  }


#pragma mark Time related operations

-(void) update: (ccTime) dt {
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 10;
	int32 positionIterations = 10;

  world->Step(1/30.0, velocityIterations , positionIterations);


  world->ClearForces();
  NSMutableSet *collidedSatellites = [[NSMutableSet alloc] init];
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
        // Inverts planet distance, so that the force will move the debris in the direction of the planet origin
        planetDistance.x=-planetDistance.x;
        planetDistance.y=-planetDistance.y;
        // make gravity attraction weaker when the debris is far from the planet, and stronger when the debris is getting close to the planet TODO: make this physical
        float vecSum=abs(planetDistance.x)+abs(planetDistance.y);
        planetDistance*=(1/vecSum)*planetRadius/finalDistance;
        // This is the final formula to make the gravity weaker as we move far from the planet TODO: do we want this?
        [sat getPhysicsBody]->ApplyForce(planetDistance, [sat getPhysicsBody]->GetWorldCenter());
        
        CGRect projectileRect = [sat boundingBox];
        CGRect targetRects = [planet boundingBox];
        if (CGRectIntersectsRect(projectileRect, targetRects)) {
          [collidedSatellites addObject:sat];
        }
      }
    }
  
	[self satellitesDidCrash:collidedSatellites];
  
}


-(void) satellitesDidCrash:(NSSet*)sats{
	for (PhysicsSprite *sat in sats) {
		CCParticleSun *explosion = [CCParticleSun node];
		//self.emitter.position = ccp( size.width /2 , size.height/2 );
		explosion.position = sat.position;
		explosion.duration = 1;
		explosion.gravity=CGPointZero;
		
		//explosion.anchorPoint = ccp(0.5f,0.5f);
		explosion.autoRemoveOnFinish = YES;
		explosion.texture = [[CCTextureCache sharedTextureCache ] addImage: @"4638.jpg"];
		ccColor4F endColor = {1, 1, 1, 0};
		//emitter.startColor = startColor;
		explosion.endColor = endColor;
		[self addChild:explosion z:10];
		
		
		//CCParticleFire *emitter = [[CCParticleFire alloc] init];
		//emitter.texture = [[CCTextureCache sharedTextureCache] addImage:@”particle.png”];
		//mitter.position = ccp(340,160);
		
		//[self addChild:explosion];
		//emitter.autoRemoveOnFinish = YES;
		
		[sat removeFromParentAndCleanup:YES];
		[_satellites removeObject:sat];
	}
}



#pragma mark Touch interactions

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if ([touches count] == 1) {
		UITouch *touch = [touches anyObject];
		self.tapPoint = [touch locationInView:[[CCDirector sharedDirector]view]];
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([touches count] == 1) {
		UITouch *touch = [touches anyObject];
		
		//if (CGPointEqualToPoint([touch locationInView:[[CCDirector sharedDirector]view]], self.tapPoint)){
			for( UITouch *touch in touches ) {
				CGPoint location = [touch locationInView: [touch view]];
				
				NSLog(@"UIView Location: height :%f width: %f", location.x, location.y);
				
				// This fixes the OpenGL vs UIKit coordinates but some bug persists for the x axis (width of the device)
				
				location = [[CCDirector sharedDirector] convertToUI:location];

				[self addNewSatAtPosition:location imageNamed:@"iss.png"];
			}
		}
	//}
}

<<<<<<< HEAD
- (void)launchButtonWasTapped{
  CGSize s = [[CCDirector sharedDirector] winSize];
  [self addRocketAtPosition:ccp(s.width/2,s.height/2) inDirection:b2Vec2(25,0) imageNamed:@"satellite1.png"];
=======
-(void)launchButtonWasTapped{
#warning method not implemented
	
	[launchButton removeFromSuperview];
}

-(void)userSwipedWithVector:(b2Vec2)vector{
	
	[[[CCDirector sharedDirector] view]addSubview:launchButton];
>>>>>>> Launchbutton
}

#pragma mark Memory management

-(void) dealloc {
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
	[super dealloc];
}

@end
