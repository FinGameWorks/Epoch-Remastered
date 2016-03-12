//
//  JZ_CameraNode.m
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/13.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "JZ_CameraNode.h"

@implementation JZ_CameraNode
@synthesize MainPlayer;
@synthesize CameraPositionNode,CameraLookAtNode;

- (void)LogicUpdate
{
    NSLog(@"LogicUpdate:%@",NSStringFromClass([self class]));
}
- (void)LogicFixedUpdate
{
    NSLog(@"LogicFixedUpdate:%@",NSStringFromClass([self class]));
}

- (void)initCamera
{
    SCNCamera *cam = [SCNCamera camera];
    self.camera = cam;
    self.camera.automaticallyAdjustsZRange = YES;
    
    if (MainPlayer)
    {
        CameraLookAtNode = [MainPlayer childNodeWithName:@"CameraLookAt" recursively:YES];
        SCNLookAtConstraint *LookAtConstraint = [SCNLookAtConstraint lookAtConstraintWithTarget:CameraLookAtNode];
        LookAtConstraint.gimbalLockEnabled = NO;
        LookAtConstraint.influenceFactor = 1.0f;
        
        
        CameraPositionNode = [MainPlayer childNodeWithName:@"CameraPosition" recursively:YES];
        SCNTransformConstraint *TransformConstraint = [SCNTransformConstraint transformConstraintInWorldSpace:YES withBlock:^SCNMatrix4(SCNNode *node, SCNMatrix4 transform)
                                                       {
                                                           
                                                           transform = [MainPlayer.parentNode convertTransform:CameraPositionNode.transform fromNode:CameraPositionNode.parentNode];
                                                           
                                                           return transform;
                                                       }];
        TransformConstraint.influenceFactor = 1.0f;
        
        
        
        self.constraints = @[TransformConstraint,LookAtConstraint];
    }
    
}

- (SCNVector3)normalized:(SCNVector3)vector
                  length:(float)lengthTo
{
    float lengthFrom = sqrtf(powf(vector.x, 2.0f) + powf(vector.y, 2.0f) + powf(vector.z, 2.0f));
    return SCNVector3Make(vector.x/lengthFrom*lengthTo, vector.y/lengthFrom*lengthTo, vector.z/lengthFrom*lengthTo);
}

@end
