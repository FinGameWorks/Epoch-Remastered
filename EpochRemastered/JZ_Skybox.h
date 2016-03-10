//
//  JZ_Skybox.h
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/11.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface JZ_Skybox : NSObject

#pragma mark - Share Instance
+ (id)sharedManager;

#pragma mark - Generate Array of Skybox
- (NSMutableArray *)SkyboxArray;
- (void)SkyboxInScene:(SCNScene *)scene;

@end
