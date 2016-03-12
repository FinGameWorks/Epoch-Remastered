//
//  JZ_PlanetSCNNode.h
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/11.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface JZ_PlanetSCNNode : SCNNode

// Planet Transform
@property (nonatomic) float planetRadius;

// Planet Map Generation Parameter
@property (nonatomic) float basicSubmeshLevel;


// Debug
@property (nonatomic) BOOL isDebug;



- (void)initPlanet;


@end
