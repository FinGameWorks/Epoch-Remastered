//
//  JZ_MainPlayer.m
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/11.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "JZ_MainPlayer.h"
#import "EpochRemastered-swift.h"

@interface JZ_MainPlayer()



@end

@implementation JZ_MainPlayer
@synthesize controlView;

- (void)LogicUpdate
{
    if (controlView)
    {
        switch (controlView.speedSliderDirection)
        {
            case 1:
                [self.physicsBody applyForce:[self.parentNode convertPosition:SCNVector3Make(0, 0, 1.0f) fromNode:self.presentationNode] impulse:NO];
                break;
            case -1:
                [self.physicsBody applyForce:[self.parentNode convertPosition:SCNVector3Make(0, 0, -1.0f) fromNode:self.presentationNode] impulse:NO];
                break;
            case 0:
                //[self.physicsBody applyForce:SCNVector3Make(0, 0, -1.0f) impulse:NO];
                break;
            default:
                break;
        }
        //self.orientation
        
        
        
        //SCNVector3 roll = [self.parentNode convertTransform:SCNMatrix4MakeRotation(1.0, 0, 0, 1.0) fromNode:self.presentationNode].
        SCNVector3 roll = [self getRotation:[self.parentNode convertTransform:SCNMatrix4MakeRotation(1, 0, 0, 1.0f) fromNode:self.presentationNode]];
        //SCNVector3 roll = [self.parentNode convertPosition:SCNVector3Make(0, 0, 1.0f) fromNode:self.presentationNode];
        //SCNVector3 yaw = [self.parentNode convertPosition:SCNVector3Make(0, 1.0f, 0) fromNode:self.presentationNode];
        
        SCNVector3 pitch = [self getRotation:[self.parentNode convertTransform:SCNMatrix4MakeRotation(1,1.0f,0,0) fromNode:self.presentationNode]];
        //SCNVector3 pitch = [self.parentNode convertPosition:SCNVector3Make(1.0f,0,0) fromNode:self.presentationNode];
        

        
        [self.physicsBody applyTorque:SCNVector4Make(roll.x, roll.y, roll.z, controlView.JoystickTouchVector.x*2.0f) impulse:NO];
        
        //[self.physicsBody applyTorque:SCNVector4Make(0, 1.0f, 0, -controlView.JoystickTouchVector.x*2.0f) impulse:NO];
        
        [self.physicsBody applyTorque:SCNVector4Make(pitch.x, pitch.y, pitch.z, controlView.JoystickTouchVector.y*2.0f) impulse:NO];
        
        


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
    NSLog(@"JZ_MainPlayer self.presentationNode.position %f %f %f ",self.presentationNode.position.x,self.presentationNode.position.y,self.presentationNode.position.z);
    
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
