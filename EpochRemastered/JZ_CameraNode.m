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
@synthesize CameraInnerNode;

- (void)LogicUpdate
{
//
//    //NSLog(@"LogicUpdate:%@",NSStringFromClass([self class]));
//    SCNVector3 idealPosition = [self.parentNode convertPosition:CameraPositionNode.presentationNode.position fromNode:CameraPositionNode.parentNode.presentationNode];
//    
//    self.position = idealPosition;
//    NSLog(@"idealPosition %f %f %f ",idealPosition.x,idealPosition.y,idealPosition.z);
//    NSLog(@"JZ_CameraNode self.presentationNode.position %f %f %f ",self.presentationNode.position.x,self.presentationNode.position.y,self.presentationNode.position.z);
    
    //self.transform = [self.parentNode convertTransform:CameraPositionNode.presentationNode.transform fromNode:CameraPositionNode.parentNode.presentationNode];
    
    //NSLog(@"JZ_CameraNode self.position %f %f %f ",self.position.x,self.position.y,self.position.z);

}
- (void)LogicFixedUpdate
{
    //NSLog(@"LogicFixedUpdate:%@",NSStringFromClass([self class]));
}

- (void)initCamera
{
    CameraInnerNode = [SCNNode node];
    SCNCamera *cam = [SCNCamera camera];
    CameraInnerNode.position = SCNVector3Make(0.0f, 0.0f, 0.0f);
    CameraInnerNode.camera = cam;
    CameraInnerNode.camera.automaticallyAdjustsZRange = YES;
    [self addChildNode:CameraInnerNode];
    
    if (MainPlayer)
    {
        CameraLookAtNode = [MainPlayer childNodeWithName:@"CameraLookAt" recursively:YES];
        SCNLookAtConstraint *LookAtConstraint = [SCNLookAtConstraint lookAtConstraintWithTarget:CameraLookAtNode];
        LookAtConstraint.gimbalLockEnabled = NO;
        LookAtConstraint.influenceFactor = 1.0f;
        
        
        CameraPositionNode = [MainPlayer childNodeWithName:@"CameraPosition" recursively:YES];
        
        
        SCNTransformConstraint *TransformConstraint = [SCNTransformConstraint transformConstraintInWorldSpace:YES withBlock:^SCNMatrix4(SCNNode *node, SCNMatrix4 transform)
                                                       {
                                                           transform = [self.parentNode convertTransform:CameraPositionNode.presentationNode.transform fromNode:CameraPositionNode.parentNode.presentationNode];
                                                           
                                                           return transform;
                                                       }];
        TransformConstraint.influenceFactor = 1.0f;
        self.constraints = @[TransformConstraint];
        
        CameraInnerNode.constraints = @[LookAtConstraint];
    }
    
}

- (SCNVector3)normalized:(SCNVector3)vector
                  length:(float)lengthTo
{
    float lengthFrom = sqrtf(powf(vector.x, 2.0f) + powf(vector.y, 2.0f) + powf(vector.z, 2.0f));
    return SCNVector3Make(vector.x/lengthFrom*lengthTo, vector.y/lengthFrom*lengthTo, vector.z/lengthFrom*lengthTo);
}

@end
