//
//  JZ_MainPlayer.h
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/11.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JZ_Player.h"
#import "JZ_ControlView.h"

@interface JZ_MainPlayer : JZ_Player


@property (nonatomic,weak) JZ_ControlView *controlView;


- (void)LogicUpdate;
- (void)LogicFixedUpdate;

- (void)initShip;

@end
