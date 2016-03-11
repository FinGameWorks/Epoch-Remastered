//
//  JZ_Atomsphere.m
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/11.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "JZ_Atomsphere.h"

@implementation JZ_Atomsphere
@synthesize sphereRadius;

- (void)initAtomsphere
{
    SCNMaterial *mat = [SCNMaterial material];
    self.geometry = [SCNSphere sphereWithRadius:sphereRadius];
    self.geometry.materials = [NSArray arrayWithObject:mat];
    mat.doubleSided = YES;

    
    SCNProgram *program = [SCNProgram program];
    NSURL *vertexShaderURL   = [[NSBundle mainBundle]
                                URLForResource:@"/PlanetShader" withExtension:@"vert"];
    NSURL *fragmentShaderURL = [[NSBundle mainBundle]
                                URLForResource:@"/PlanetShader" withExtension:@"frag"];
    NSString *vertexShader = [[NSString alloc] initWithContentsOfURL:vertexShaderURL
                                   encoding:NSUTF8StringEncoding
                                      error:NULL];
    NSString *fragmentShader = [[NSString alloc] initWithContentsOfURL:fragmentShaderURL
                                   encoding:NSUTF8StringEncoding
                                      error:NULL];
    
    program.vertexShader   = vertexShader;
    program.fragmentShader = fragmentShader;

    [program setSemantic:@"200.0" forSymbol:@"re" options:nil];
    [program setSemantic:@"200.0" forSymbol:@"rp" options:nil];
    [program setSemantic:@"14.0" forSymbol:@"planet_h" options:nil];
    [program setSemantic:@"4.0" forSymbol:@"view_depth" options:nil];
    
    mat.program = program;
    
    
    
    
}

//http://http.developer.nvidia.com/GPUGems2/gpugems2_chapter16.html

@end
