//
//  JZ_Skybox.m
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/11.
//  Copyright © 2016年 JustZht. All rights reserved.
//
#define PamoMapHeight 1024

#import "JZ_Skybox.h"

//Image Transform
#import "JZ_ImageHelper.h"

//NoiseLib
#import "noise.h"
#include "noiseutils.h"

@implementation JZ_Skybox

#pragma mark - Share Instance

+ (id)sharedManager {
    static JZ_ImageHelper *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init])
    {
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (NSMutableArray *)SkyboxArray
{
    return [self NoiseCubemapWithSeed:SCNVector3Make(14.0f, 1.0f, 0.7f)];
}

- (void)SkyboxInScene:(SCNScene *)scene
{
    scene.background.contents = [self SkyboxArray];
}
#pragma mark - make a array of Cubemaps(height Cubemaps, color Cubemaps, etc) using given parameter
- (NSMutableArray *)NoiseCubemapWithSeed:(SCNVector3)ParameterVector3
{
    module::Perlin myModule;
    
    myModule.SetOctaveCount (ParameterVector3.x);
    myModule.SetFrequency(ParameterVector3.y);
    myModule.SetPersistence (ParameterVector3.z);
    utils::NoiseMap heightMap;
    utils::NoiseMapBuilderSphere heightMapBuilder;
    heightMapBuilder.SetSourceModule (myModule);
    heightMapBuilder.SetDestNoiseMap (heightMap);
    heightMapBuilder.SetDestSize (PamoMapHeight*2, PamoMapHeight);
    heightMapBuilder.SetBounds (-90.0, 90.0, -180.0, 180.0);
    heightMapBuilder.Build ();
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
       utils::RendererImage ColorRenderer;
    utils::Image ColorImage;
    ColorRenderer.SetSourceNoiseMap (heightMap);
    ColorRenderer.SetDestImage (ColorImage);
    ColorRenderer.ClearGradient ();
    ColorRenderer.AddGradientPoint (-1.0000, utils::Color (  0,   5, 69, 255));
    ColorRenderer.AddGradientPoint (0.0500, utils::Color (  0, 4,108, 255));
    ColorRenderer.AddGradientPoint (0.2500, utils::Color (  44, 37,117, 255));
    ColorRenderer.AddGradientPoint (0.4500, utils::Color (  0, 123,255, 255));
    ColorRenderer.AddGradientPoint (1.0000, utils::Color (  235, 250,255, 255));
    //    renderer.EnableLight ();
    //    renderer.SetLightContrast (3.0);
    //    renderer.SetLightBrightness (2.0);
    ColorRenderer.Render ();
    
    NSString *basePath = [NSString stringWithFormat:@"%@/SkyboxColorMap.bmp",paths.firstObject];
    utils::WriterBMP writer;
    writer.SetSourceImage (ColorImage);
    std::string stdbasePath = *new std::string([basePath UTF8String]);
    writer.SetDestFilename (stdbasePath);
    writer.WriteDestFile ();

    UIImage *UIColorImage = [UIImage imageWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"SkyboxColorMap.bmp"]];
    
    NSMutableArray * ColorMapImagesArray = [self cubeMapImagesRotationFixedArrayUsingPanoMap:UIColorImage];
    
    return ColorMapImagesArray;
    
}

#pragma mark - make a array of SCNMaterials using given Pano Map
- (NSMutableArray *)cubeMapImagesRotationFixedArrayUsingPanoMap:(UIImage *)image
{
    cv::Mat PanoMap = [[JZ_ImageHelper sharedManager]cvMatFromUIImage:image];
    NSMutableArray *CubeMapArray = [[JZ_ImageHelper sharedManager] createCubeMapArray:PanoMap Width:PamoMapHeight/2 Height:PamoMapHeight/2];
    NSMutableArray *CubeMappingImages = [NSMutableArray array];
    [CubeMappingImages addObject:[CubeMapArray objectAtIndex:0]];
    [CubeMappingImages addObject:[CubeMapArray objectAtIndex:2]];
    [CubeMappingImages addObject:[CubeMapArray objectAtIndex:4]];
    [CubeMappingImages addObject:[CubeMapArray objectAtIndex:5]];
    [CubeMappingImages addObject:[CubeMapArray objectAtIndex:3]];
    [CubeMappingImages addObject:[CubeMapArray objectAtIndex:1]];
    
    return CubeMappingImages;
}

@end
