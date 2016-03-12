//
//  JZ_PlanetDataSourcce.h
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/12.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import <Foundation/Foundation.h>

//NoiseLib
#import "noise.h"
#import "noiseutils.h"

@interface JZ_PlanetDataSource : NSObject


#pragma mark - Parameters
@property (nonatomic) float PerlinOvatveCount;
@property (nonatomic) float PerlinFrequency;
@property (nonatomic) float PerlinPersistence;
@property (nonatomic) int PamoMapHeight;
@property (nonatomic,strong) NSMutableArray *GrandientColorPointArray;


#pragma mark - cubemaps method
- (NSMutableArray *)cubeMaps;

#pragma mark - Share Instance
+ (id)sharedManager;

@end

struct GrandientColorPoint
{
    float height;
    noise::utils::Color color;
};