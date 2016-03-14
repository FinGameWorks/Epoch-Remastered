//
//  JZ_CameraNode.h
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/13.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import "JZ_MainPlayer.h"

@interface JZ_CameraNode : SCNNode

@property (nonatomic,strong) JZ_MainPlayer *MainPlayer;

@property (nonatomic,strong)SCNNode *CameraLookAtNode;
@property (nonatomic,strong)SCNNode *CameraPositionNode;

@property (nonatomic,strong)SCNNode *CameraInnerNode;

- (void)LogicUpdate;
- (void)LogicFixedUpdate;

- (void)initCamera;

@end
