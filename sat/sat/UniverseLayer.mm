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

/*TODO: port from the flash
 package {
 import flash.display.*;
 import flash.events.Event;
 import flash.events.MouseEvent;
 import Box2D.Dynamics.*;
 import Box2D.Collision.*;
 import Box2D.Collision.Shapes.*;
 import Box2D.Common.Math.*;
 import Box2D.Dynamics.Joints.*;
 import flash.sampler.NewObjectSample;
 // extra http://www.mvfusion.nl/orbital-gravity-code-sample/
 // all code was provided through
 //
 // http://www.emanueleferonato.com/2012/03/28/simulate-radial-gravity-also-know-as-planet-gravity-with-box2d-as-seen-on-angry-birds-space/
 //
 // So Emanuele Feronato is getting credit for all code. I just added some extra stuff in the update loop to make orbits possible at most speeds...
 
 public class Main extends Sprite {
 private var world:b2World=new b2World(new b2Vec2(0,0),true);
 private var worldScale:Number=30;
 private var planetVector:Vector.=new Vector.();
 private var debrisVector:Vector.=new Vector.();
 private var orbitCanvas:Sprite=new Sprite();
 private var oldDistance:Number = 0 ;
 private var newSprite:Sprite;
 private var doMoveLeft:Boolean = false;
 private var flt:Number = 0;
 public function Main() {
 addChild(orbitCanvas);
 orbitCanvas.graphics.lineStyle(1,0xff0000);
 debugDraw();
 addPlanet(400,300,90);//90
 //addPlanet(800,300,45);//90
 //addPlanet(480,120,45);
 addEventListener(Event.ENTER_FRAME,update);
 stage.addEventListener(MouseEvent.CLICK,createDebris);
 
 
 newSprite = new Sprite();
 addChild(newSprite);
 var mn:moveLeft = new moveLeft();
 addChild(mn);
 mn.addEventListener(MouseEvent.CLICK, goLeft);
 
 }
 private function goLeft(e:MouseEvent):void{
 trace("click");
 doMoveLeft = !doMoveLeft;
 }
 private function createDebris(e:MouseEvent):void {
 addBox(mouseX,mouseY,20,20);
 trace(mouseX, mouseY);
 newSprite.graphics.clear();
 
 }
 
 
 
 private function convertToRange( OldValue :Number , OldMin :Number , OldMax :Number , NewMin :Number , NewMax:Number ) :Number
 {
 
 var res:Number = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin;
 if(OldMin == 0 && OldMax == 0){
 res = 0.0;
 }
 return res;
 
 }
 private function update(e:Event):void {
 world.Step(1/60, 10, 10);
 world.ClearForces();
 
 for (var i:int=0; i debrisVector[i].GetLinearVelocity().Length()){
 var verschil2:Number = (debrisVector[i].GetUserData().oldvel - debrisVector[i].GetLinearVelocity().Length()) * 1.0;
 
 var newF:b2Vec2 = new b2Vec2(F.x * (debrisVector[i].GetLinearVelocity().Length() * (verschil2 * 2)),
 F.y * (debrisVector[i].GetLinearVelocity().Length() * (verschil2 * 2)));
 
 //compare previous distance with new current distance...if the difference is higher, that means, we are going up
 //again, which is NOT what we want. That will give an annoying elastic effect and will make body escape from planet.
 var diffDistance:Number = debrisVector[i].GetUserData().oldDis - finalDistance;
 
 if(diffDistance > 0){
 //red = we must apply some add. force to make sure body goes back to planet.
 //BTW, here one must add some extra code to compare last velocity and current velocity, to make sure
 //we eliminate small hicks...
 var subf:b2Vec2 = new b2Vec2(newF.x * gravityStrenght , newF.y * gravityStrenght );
 SUPERFORCE.Add(subf);
 }
 
 var mm2:Number = convertToRange(speedD , 0, 45, 2,3);
 var dampvalue2:Number = i2*0.0314 / mm2 * speedD/i2;
 
 debrisVector[i].SetLinearDamping(dampvalue2*2 );
 
 if(diffDistance < -0.0){
 //orange = body goes up...so dont apply anti force!
 newSprite.graphics.beginFill(0xFF9900);
 newSprite.graphics.drawCircle(debrisVector[i].GetPosition().x * worldScale, debrisVector[i].GetPosition().y * worldScale, 2);
 newSprite.graphics.endFill();
 
 }
 else{
 //red = body needs to be forced someway...
 newSprite.graphics.beginFill(0xFF0000);
 newSprite.graphics.drawCircle(debrisVector[i].GetPosition().x * worldScale, debrisVector[i].GetPosition().y * worldScale, 2);
 newSprite.graphics.endFill();
 }
 }
 else{
 newSprite.graphics.beginFill(0x00FF00);
 newSprite.graphics.drawCircle(debrisVector[i].GetPosition().x * worldScale, debrisVector[i].GetPosition().y * worldScale, 2);
 newSprite.graphics.endFill();
 }
 
 debrisVector[i].ApplyForce(SUPERFORCE, debrisVector[i].GetWorldCenter());
 //store old data into variable, usefull to compare in loop
 debrisVector[i].GetUserData().oldvel = debrisVector[i].GetLinearVelocity().Length();
 debrisVector[i].GetUserData().oldDis = finalDistance;
 }
 }
 }
 world.DrawDebugData();
 }
 }
 }
 */

-(void) initPhysics
{
	
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
	
	[self addPlanet:s.width/2 yCoord:s.height/2  radius:s.width/20];
}

-(void) draw
{
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

-(void)addPlanet:(float)pX yCoord:(float)pY radius:(float)r {
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
	PhysicsSprite *sprite = [PhysicsSprite spriteWithFile:@"Earth.png"];

	sprite.position=ccp(pX/PTM_RATIO,pY/PTM_RATIO);
	[sprite setPhysicsBody:thePlanet];
	[_planets addObject:sprite];
	thePlanet->CreateFixture(&fixtureDef);
	
}

-(void)addBox:(float)pX yCoord:(float)pY wVal:(float)w hVal:(float)h {
	b2CircleShape polygonShape;
	polygonShape.m_radius = w/PTM_RATIO/2;
	b2FixtureDef fixtureDef;
	fixtureDef.restitution=0.1;
	fixtureDef.density = 1;
	fixtureDef.friction=1;
	fixtureDef.shape=&polygonShape;
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	b2Vec2 satCoords;
	satCoords.x = pX/PTM_RATIO;
	satCoords.y= pY/PTM_RATIO;
	bodyDef.position =satCoords;
	b2Body *theSat = world->CreateBody(&bodyDef);
	//  newobject.oldvel = 0;
	//  newobject.velchange = 0;
	//  newobject.oldDis = 0;
	//  box.SetUserData(newobject);
	//theSat->SetUserData(<#void *data#>);
	b2Vec2 force;
	force.x = 400;
	force.y= 0;
	b2Vec2 center;
	CGSize s = [[CCDirector sharedDirector] winSize];
	center.x=s.height;
	center.y=s.width;
	theSat->ApplyForce(force, center);
	theSat->CreateFixture(&fixtureDef);
	//  var box:b2Body=world.CreateBody(bodyDef);
	//
	//  var newobject:Object = new Object();
	
	//  debrisVector.push(box);
	//  box.ApplyForce(new b2Vec2(400,0), box.GetWorldCenter());
	//
	//  box.CreateFixture(fixtureDef);
}


//-(void) addNewSpriteAtPosition:(CGPoint)p {
//  [self addBox:p.x yCoord:p.y wVal:20 hVal:20];
//}
-(void) addNewSpriteAtPosition:(CGPoint)p{
    CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
    CCNode *parent = [self getChildByTag:kTagParentNode];
    
    PhysicsSprite *sprite = [PhysicsSprite spriteWithFile:@"Earth.png"];
    [parent addChild:sprite];
    
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
    
    // actually apply a force!
    b2Vec2 force;
    force.x = 400;
    force.y= 0;
    b2Vec2 center;
    CGSize s = [[CCDirector sharedDirector] winSize];
    center.x=s.height;
    center.y=s.width;
    body->ApplyForce(force, center);
    [sprite setPhysicsBody:body];
  }



-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);	
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
		
		if (CGPointEqualToPoint([touch locationInView:[[CCDirector sharedDirector]view]], self.tapPoint)){
			for( UITouch *touch in touches ) {
				CGPoint location = [touch locationInView: [touch view]];
				
				NSLog(@"UIView Location: height :%f width: %f", location.x, location.y);
				
				// This fixes the OpenGL vs UIKit coordinates but some bug persists for the x axis (width of the device)
				
				location = [[CCDirector sharedDirector] convertToUI:location];

				[self addNewSpriteAtPosition: location];
			}
		}
	}
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
