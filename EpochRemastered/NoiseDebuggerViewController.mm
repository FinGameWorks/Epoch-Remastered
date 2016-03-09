//
//  NoiseDebuggerViewController.m
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/8.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "NoiseDebuggerViewController.h"

//Mesh Generation
#import <SceneKit/SceneKit.h>
#import <ModelIO/ModelIO.h>
#import <SceneKit/ModelIO.h>

//Image Transform
#import "JZ_ImageHelper.h"

//NoiseLib
#import "noise.h"
#include "noiseutils.h"

@interface NoiseDebuggerViewController ()
@property (strong, nonatomic) UIImage *DebugerImage;
@property (weak, nonatomic) IBOutlet SCNView *PlanetSceneKitView;

@property (nonatomic,strong) SCNNode * PlanetNode;

@end

@implementation NoiseDebuggerViewController
@synthesize DebugerImage,PlanetSceneKitView,PlanetNode;
@synthesize RandomSeedSlider;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //清空 NSDocumentDirectory
    [self EmptySandbox];
    
    [RandomSeedSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    [self initSceneKitWith:[self NoiseCubemapWithSeed:SCNVector3Make(10.0f, 2.0f, 0.6f)]];
    
    
}

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
    
    
    cv::Mat PanoMap = [[JZ_ImageHelper sharedManager]cvMatFromUIImage:DebugerImage];
    
    NSMutableArray *CubeMapArray = [[JZ_ImageHelper sharedManager] createCubeMapArray:PanoMap Width:256 Height:256];
    NSMutableArray *CubeMappingMaterials = [NSMutableArray array];
    
    
    for (int i = 0; i < 6 ; i++)
    {
        UIImage *Image = [CubeMapArray objectAtIndex:i];
        switch (i)
        {
            case 5:
                Image = [[JZ_ImageHelper sharedManager] imageRotatedByDegrees:Image deg:-90.0f];
                break;
            case 4:
                Image = [[JZ_ImageHelper sharedManager] imageRotatedByDegrees:Image deg:90.0f];
                break;
            default:
                break;
        }
        SCNMaterial *Material              = [SCNMaterial material];
        Material.diffuse.contents          = Image;
        [CubeMappingMaterials addObject:Material];
    }
    return CubeMappingMaterials;
}



- (void)initSceneKitWith:(NSMutableArray *)CubeMappingMaterials
{
    PlanetSceneKitView.scene = [SCNScene scene];
    
    PlanetSceneKitView.allowsCameraControl = YES;
    PlanetSceneKitView.showsStatistics = YES;
    PlanetSceneKitView.backgroundColor = [UIColor blackColor];
    PlanetSceneKitView.debugOptions = SCNDebugOptionShowWireframe;
    
//    SCNSphere *PlanetSphere = [SCNSphere sphereWithRadius:30.0f];
//    PlanetSphere.geodesic = NO;
//    
//    SCNNode *PlanetNode = [SCNNode nodeWithGeometry:PlanetSphere];
//    [PlanetSceneKitView.scene.rootNode addChildNode:PlanetNode];
//
    
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
    //[PlanetSceneKitView.scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    [PlanetSceneKitView.scene.rootNode addChildNode:ambientLightNode];
    
    SCNBox *SCNBoxToSphereMapping = [SCNBox boxWithWidth:60.0f height:60.0f length:60.0f chamferRadius:0.0f];
    SCNBoxToSphereMapping.widthSegmentCount = 16;
    SCNBoxToSphereMapping.heightSegmentCount = 16;
    SCNBoxToSphereMapping.lengthSegmentCount = 16;
    
    //SCNBox automatically recreates its set of geometry elements depending on how many materials you assign
    //(that way it doesn't need six draw calls to render if it doesn't have six materials).
    SCNBoxToSphereMapping.materials = CubeMappingMaterials;
    
    PlanetNode = [SCNNode nodeWithGeometry:SCNBoxToSphereMapping];
    [PlanetSceneKitView.scene.rootNode addChildNode:PlanetNode];
    
    [SCNTransaction flush];
    
    NSArray *geometrySources = [PlanetNode.geometry geometrySources];
    
    // Get the vertex sources
    NSArray *vertexSources = [PlanetNode.geometry geometrySourcesForSemantic:SCNGeometrySourceSemanticVertex];
    
    // Get the first source
    SCNGeometrySource *vertexSource = vertexSources[0]; // TODO: Parse all the sources
    
    long stride = vertexSource.dataStride; // in bytes
    long offset = vertexSource.dataOffset; // in bytes
    
    long componentsPerVector = vertexSource.componentsPerVector;
    long bytesPerVector = componentsPerVector * vertexSource.bytesPerComponent;
    long vectorCount = (long)vertexSource.vectorCount;
    
    
    SCNVector3 vertices[vectorCount]; // A new array for vertices
    
    // for each vector, read the bytes
    for (long i=0; i<vectorCount; i++)
    {
        
        // Assuming that bytes per component is 4 (a float)
        // If it was 8 then it would be a double (aka CGFloat)
        
        //xyz 3 componet
        float vectorData[componentsPerVector];
        
        // The range of bytes for this vector
        NSRange byteRange = NSMakeRange(i*stride + offset, // Start at current stride + offset
                                        bytesPerVector);   // and read the lenght of one vector
        
        // Read into the vector data buffer
        [vertexSource.data getBytes:&vectorData range:byteRange];
        
        // At this point you can read the data from the float array
        
        //
        float x = vectorData[0] / SCNBoxToSphereMapping.width * 2.0f;
        float y = vectorData[1] / SCNBoxToSphereMapping.width * 2.0f;
        float z = vectorData[2] / SCNBoxToSphereMapping.width * 2.0f;
        
        float SphereX = x*sqrt(1-pow(y,2)/2.0f-pow(z,2)/2.0f + pow(y*z,2)/3.0f) * SCNBoxToSphereMapping.width / 2.0f;
        float SphereY = y*sqrt(1-pow(z,2)/2.0f-pow(x,2)/2.0f + pow(x*z,2)/3.0f) * SCNBoxToSphereMapping.width / 2.0f;

        float SphereZ = z*sqrt(1-pow(x,2)/2.0f-pow(y,2)/2.0f + pow(y*x,2)/3.0f) * SCNBoxToSphereMapping.width / 2.0f;

        
        // ... Maybe even save it as an SCNVector3 for later use ...
        //[vertices addObject:[NSValue valueWithSCNVector3:SCNVector3Make(SphereX, SphereY, SphereZ)]];
        vertices[i] = SCNVector3Make(SphereX, SphereY, SphereZ);
        
        // ... or just log it
        NSLog(@"x:%f, y:%f, z:%f", x, y, z);
        NSLog(@"SphereX:%f, SphereY:%f, SphereX:%f", SphereX, SphereY, SphereZ);
    }
    
    
    
    SCNGeometrySource *DeformedGeometrySource = [SCNGeometrySource geometrySourceWithVertices:vertices count:vectorCount];
    NSMutableArray *SCNGeometrySourceArray = [NSMutableArray arrayWithObject:DeformedGeometrySource];
    [SCNGeometrySourceArray addObject:[geometrySources objectAtIndex:2]];
    
    NSArray *DeformGeometryElement = [PlanetNode.geometry geometryElements];
    SCNGeometry *DeformedGeometry = [SCNGeometry geometryWithSources:SCNGeometrySourceArray elements:DeformGeometryElement];
    
    
    MDLMesh *DeformedGeometryUsingMDL = [MDLMesh meshWithSCNGeometry:DeformedGeometry];
    [DeformedGeometryUsingMDL addNormalsWithAttributeNamed:MDLVertexAttributeNormal creaseThreshold:1.0f];
    
    DeformedGeometry = [SCNGeometry geometryWithMDLMesh:DeformedGeometryUsingMDL];
    PlanetNode.geometry = DeformedGeometry;
    
    PlanetNode.geometry.materials = CubeMappingMaterials;
    
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

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    NSLog(@"slider value = %f", sender.value);
    

    PlanetNode.geometry.materials = [self NoiseCubemapWithSeed:SCNVector3Make(10.0f*sender.value, 2.0f*sender.value, 0.6f*sender.value)];
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
