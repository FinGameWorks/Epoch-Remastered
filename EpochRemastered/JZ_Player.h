//
//  JZ_Player.h
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/11.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface JZ_Player : SCNNode

@property (nonatomic,strong) NSString *ShipSceneName;

- (void)LogicUpdate;
- (void)LogicFixedUpdate;

- (void)initShip;

@end
