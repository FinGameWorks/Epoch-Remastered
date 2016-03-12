//
//  JZ_QuadtreeTerrainDataSource.h
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/12.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JZ_QuadtreeTerrainDataSource : NSObject

@end


struct Quadtree
{
    float TileSize;
    int TileLevel;
};