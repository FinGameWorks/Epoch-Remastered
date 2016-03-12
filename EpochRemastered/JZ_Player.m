//
//  JZ_Player.m
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/11.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "JZ_Player.h"

@implementation JZ_Player
@synthesize ShipSceneName;


- (void)LogicUpdate
{
    NSLog(@"LogicUpdate:%@",NSStringFromClass([self class]));
}
- (void)LogicFixedUpdate
{
    NSLog(@"LogicFixedUpdate:%@",NSStringFromClass([self class]));
}


- (void)initShip
{
    SCNNode *ShipNode = [[SCNScene sceneNamed:ShipSceneName inDirectory:@"art.scnassets" options:nil].rootNode clone];
    [self addChildNode:ShipNode];
    ShipNode.position = SCNVector3Make(0.0f, 0.0f, 0.0f);
}

@end
