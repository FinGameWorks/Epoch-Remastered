//
//  NoiseDebuggerViewController.m
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/8.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "NoiseDebuggerViewController.h"
#import <SceneKit/SceneKit.h>

//NoiseLib
#import "noise.h"
#include "noiseutils.h"

@interface NoiseDebuggerViewController ()
@property (strong, nonatomic) UIImage *DebugerImage;
@property (weak, nonatomic) IBOutlet SCNView *PlanetSceneKitView;

@end

@implementation NoiseDebuggerViewController
@synthesize DebugerImage,PlanetSceneKitView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //清空 NSDocumentDirectory
    [self EmptySandbox];
    
    module::Perlin myModule;
    myModule.SetOctaveCount (10);
    myModule.SetFrequency(2.0);
    myModule.SetPersistence (0.6);
    utils::NoiseMap heightMap;
    utils::NoiseMapBuilderSphere heightMapBuilder;
    heightMapBuilder.SetSourceModule (myModule);
    heightMapBuilder.SetDestNoiseMap (heightMap);
    heightMapBuilder.SetDestSize (512, 256);
    heightMapBuilder.SetBounds (-90.0, 90.0, -180.0, 180.0);
    heightMapBuilder.Build ();
    
    utils::RendererImage renderer;
    utils::Image image;
    renderer.SetSourceNoiseMap (heightMap);
    renderer.SetDestImage (image);
    renderer.ClearGradient ();
    renderer.AddGradientPoint (-1.0000, utils::Color (  0,   0, 128, 255)); // deeps
    renderer.AddGradientPoint (-0.2500, utils::Color (  0,   0, 255, 255)); // shallow
    renderer.AddGradientPoint ( 0.0000, utils::Color (  0, 128, 255, 255)); // shore
    renderer.AddGradientPoint ( 0.0625, utils::Color (240, 240,  64, 255)); // sand
    renderer.AddGradientPoint ( 0.1250, utils::Color ( 32, 160,   0, 255)); // grass
    renderer.AddGradientPoint ( 0.6750, utils::Color (224, 224,   0, 255)); // dirt
    renderer.AddGradientPoint ( 0.7500, utils::Color (128, 128, 128, 255)); // rock
    renderer.AddGradientPoint ( 1.0000, utils::Color (255, 255, 255, 255)); // snow
//    renderer.EnableLight ();
//    renderer.SetLightContrast (3.0);
//    renderer.SetLightBrightness (2.0);
    renderer.Render ();
    

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [NSString stringWithFormat:@"%@/tutorial.bmp",paths.firstObject];
    
    utils::WriterBMP writer;
    writer.SetSourceImage (image);
    std::string stdbasePath = *new std::string([basePath UTF8String]);
    writer.SetDestFilename (stdbasePath);
    writer.WriteDestFile ();
    
    
    DebugerImage = [UIImage imageWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"tutorial.bmp"]];
    
    [self initSceneKitWith:DebugerImage];
}

- (void)initSceneKitWith:(UIImage *)PlanetTexture
{
    PlanetSceneKitView.scene = [SCNScene scene];
    
    PlanetSceneKitView.allowsCameraControl = YES;
    PlanetSceneKitView.showsStatistics = YES;
    PlanetSceneKitView.backgroundColor = [UIColor blackColor];
    PlanetSceneKitView.debugOptions = SCNDebugOptionShowWireframe;
    
    SCNSphere *PlanetSphere = [SCNSphere sphereWithRadius:30.0f];
    PlanetSphere.geodesic = NO;
    
    SCNNode *PlanetNode = [SCNNode nodeWithGeometry:PlanetSphere];
    [PlanetSceneKitView.scene.rootNode addChildNode:PlanetNode];
    
    SCNMaterial *PlanetMaterial = [SCNMaterial material];
    PlanetMaterial.diffuse.contents = PlanetTexture;
    PlanetSphere.materials = @[PlanetMaterial];
    
    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [PlanetSceneKitView.scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 0, 100);
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeDirectional;
    lightNode.eulerAngles = SCNVector3Make(45.0f, 45.0f, 45.0f);
    lightNode.position = SCNVector3Make(10, 10, -10);
    [PlanetSceneKitView.scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    [PlanetSceneKitView.scene.rootNode addChildNode:ambientLightNode];

}

-(void)EmptySandbox
{
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    while (files.count > 0) {
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
        if (error == nil) {
            for (NSString *path in directoryContents) {
                NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
                BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
                files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
                if (!removeSuccess) {
                    // Error
                }
            }
        } else {
            // Error
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
