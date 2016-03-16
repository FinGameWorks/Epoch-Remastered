//
//  JZ_MainPlayer.m
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/11.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "JZ_MainPlayer.h"
#define SpeedMutilpier 20

@interface JZ_MainPlayer()

//world point
@property (nonatomic) SCNVector3 centerPoint;
@property (nonatomic) SCNVector3 forwardPoint;
@property (nonatomic) SCNVector3 upPoint;
@property (nonatomic) SCNVector3 rightPoint;

//world vector
@property (nonatomic) SCNVector3 forwardVector;
@property (nonatomic) SCNVector3 backVector;
@property (nonatomic) SCNVector3 upVector;
@property (nonatomic) SCNVector3 rightVector;

@end

@implementation JZ_MainPlayer
@synthesize controlView;
@synthesize centerPoint,forwardVector,forwardPoint,upPoint,upVector,rightPoint,rightVector,backVector;

- (SCNVector3)SCNVector3:(SCNVector3)a mins:(SCNVector3)b
{
    return SCNVector3Make(a.x-b.x, a.y-b.y, a.z-b.z);
}

- (SCNVector3)SCNVector3:(SCNVector3)a multiply:(float)b
{
    return SCNVector3Make(a.x*b, a.y*b, a.z*b);
}


- (void)LogicUpdate
{
    centerPoint = [self.parentNode convertPosition:SCNVector3Make(0, 0, 0) fromNode:self.presentationNode];
    forwardPoint = [self.parentNode convertPosition:SCNVector3Make(0, 0, -1.0f) fromNode:self.presentationNode];
    upPoint = [self.parentNode convertPosition:SCNVector3Make(0, 1.0f, 0) fromNode:self.presentationNode];
    rightPoint = [self.parentNode convertPosition:SCNVector3Make(1.0f, 0, 0) fromNode:self.presentationNode];
    
    forwardVector = [self SCNVector3:forwardPoint mins:centerPoint];
    backVector = [self SCNVector3:centerPoint mins:forwardPoint];
    upVector = [self SCNVector3:upPoint mins:centerPoint];
    rightVector = [self SCNVector3:rightPoint mins:centerPoint];
    
    
    if (controlView)
    {

        self.physicsBody.velocity = [self SCNVector3:backVector multiply:controlView.speedSliderDirection*SpeedMutilpier];

        [self.physicsBody applyTorque:SCNVector4Make(forwardVector.x,forwardVector.y,forwardVector.z, -controlView.JoystickTouchVector.x*2.0f) impulse:NO];
        
        [self.physicsBody applyTorque:SCNVector4Make(rightVector.x, rightVector.y, rightVector.z, controlView.JoystickTouchVector.y*2.0f) impulse:NO];
        

    }
    else
    {
        NSException* myException = [NSException
                                    exceptionWithName:@"FileNotFoundException"
                                    reason:@"controlView Not Found"
                                    userInfo:nil];
        @throw myException;
    }
    
    //NSLog(@"JZ_MainPlayer self.position %f %f %f ",self.position.x,self.position.y,self.position.z);
    //NSLog(@"JZ_MainPlayer self.presentationNode.position %f %f %f ",self.presentationNode.position.x,self.presentationNode.position.y,self.presentationNode.position.z);
    
}

- (SCNVector3)getRotation:(SCNMatrix4)matrix
{
    SCNVector3 rotation;
    
    if (matrix.m11 == 1.0f)
    {
        rotation.x = atan2f(matrix.m13, matrix.m34);
        rotation.y = 0;
        rotation.z = 0;
        
    }else if (matrix.m11 == -1.0f)
    {
        rotation.x = atan2f(matrix.m13, matrix.m34);
        rotation.y = 0;
        rotation.z = 0;
    }else
    {
        rotation.x = atan2(-matrix.m31,matrix.m11);
        rotation.y = asin(matrix.m21);
        rotation.z = atan2(-matrix.m23,matrix.m22);
    }
    
    return rotation;
}

- (void)LogicFixedUpdate
{
    
}
- (void)initShip
{
    [super initShip];
}


@end
