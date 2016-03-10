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

- (void)initShip
{
    SCNNode *ShipNode = [[SCNScene sceneNamed:ShipSceneName inDirectory:@"art.scnassets" options:nil].rootNode clone];
    [self addChildNode:ShipNode];
}

@end
