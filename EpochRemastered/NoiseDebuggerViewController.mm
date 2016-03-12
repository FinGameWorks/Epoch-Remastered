//
//  NoiseDebuggerViewController.m
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/8.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#define SubMesh 72
#define PamoMapHeight 1024
#define isDebug NO

#import "NoiseDebuggerViewController.h"
#import "GPUImage/GPUImage.h"

//Mesh Generation
#import <SceneKit/SceneKit.h>
#import <ModelIO/ModelIO.h>
#import <SceneKit/ModelIO.h>

//Image Transform
#import "JZ_ImageHelper.h"

//NoiseLib
#import "noise.h"
#include "noiseutils.h"

#import "JZ_Skybox.h"
#import "JZ_Player.h"
#import "JZ_Atomsphere.h"

#import "JZ_ControlView.h"

@interface NoiseDebuggerViewController () <SCNSceneRendererDelegate>
@property (strong, nonatomic) UIImage *UIColorImage;
@property (strong, nonatomic) UIImage *UIHeightImage;
@property (strong, nonatomic) UIImage *UINormalImage;

@property (weak, nonatomic) IBOutlet SCNView *PlanetSceneKitView;

@property (nonatomic,strong) SCNNode * PlanetNode;

@end

@implementation NoiseDebuggerViewController
@synthesize UIColorImage,UIHeightImage,UINormalImage,PlanetSceneKitView,PlanetNode;
@synthesize RandomSeedSlider;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //清空 NSDocumentDirectory
    
    [self EmptySandbox];
    
    
    [RandomSeedSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self initSceneKitWith:[self NoiseCubemapWithSeed:SCNVector3Make(10.0f, 2.0f, 0.6f)]];
    
    PlanetSceneKitView.delegate = self;
    
    JZ_ControlView *controlView = [[JZ_ControlView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:controlView];
    
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

    utils::RendererImage HeightRenderer;
    utils::Image HeightImage;
    HeightRenderer.SetSourceNoiseMap (heightMap);
    HeightRenderer.SetDestImage (HeightImage);
    HeightRenderer.ClearGradient ();
    HeightRenderer.AddGradientPoint ( -1.0000, utils::Color (255, 255, 255, 255)); // Bottom
    HeightRenderer.AddGradientPoint ( 1.0000, utils::Color (0, 0, 0, 255)); // Top
    HeightRenderer.Render ();
    utils::WriterBMP writer;
    writer.SetSourceImage (HeightImage);
    UIHeightImage = [[JZ_ImageHelper sharedManager] imageFromWriter:writer
                                                             height:PamoMapHeight];

    
    
    
    utils::RendererNormalMap NormalRender;
    utils::Image NormalImage;
    NormalImage.SetSize(PamoMapHeight*2, PamoMapHeight);
    NormalRender.SetSourceNoiseMap(heightMap);
    NormalRender.SetDestImage(NormalImage);
    //NormalRender.EnableWrap();
    NormalRender.SetBumpHeight(2.0);
    NormalRender.Render();
    writer.SetSourceImage (NormalImage);
    UINormalImage = [[JZ_ImageHelper sharedManager] imageFromWriter:writer height:PamoMapHeight];
    

    utils::RendererImage ColorRenderer;
    utils::Image ColorImage;
    ColorRenderer.SetSourceNoiseMap (heightMap);
    ColorRenderer.SetDestImage (ColorImage);
    ColorRenderer.ClearGradient ();
    ColorRenderer.AddGradientPoint (-1.0000, utils::Color (  0,   0, 128, 255)); // deeps
    ColorRenderer.AddGradientPoint (-0.2500, utils::Color (  0,   0, 255, 255)); // shallow
    ColorRenderer.AddGradientPoint ( 0.0000, utils::Color (  0, 128, 255, 255)); // shore
    ColorRenderer.AddGradientPoint ( 0.0625, utils::Color (240, 240,  64, 255)); // sand
    ColorRenderer.AddGradientPoint ( 0.1250, utils::Color ( 32, 160,   0, 255)); // grass
    ColorRenderer.AddGradientPoint ( 0.6750, utils::Color (224, 224,   0, 255)); // dirt
    ColorRenderer.AddGradientPoint ( 0.7500, utils::Color (128, 128, 128, 255)); // rock
    ColorRenderer.AddGradientPoint ( 1.0000, utils::Color (255, 255, 255, 255)); // snow
    //    renderer.EnableLight ();
    //    renderer.SetLightContrast (3.0);
    //    renderer.SetLightBrightness (2.0);
    ColorRenderer.Render ();
    
    writer.SetSourceImage (ColorImage);
    
    UIColorImage = [[JZ_ImageHelper sharedManager] imageFromWriter:writer height:PamoMapHeight];
    
    NSMutableArray * ColorMapImagesArray = [self cubeMapImagesRotationFixedArrayUsingPanoMap:UIColorImage];
    NSMutableArray * HeightMapImagesArray = [self cubeMapImagesRotationFixedArrayUsingPanoMap:UIHeightImage];
    NSMutableArray * NormalMapImagesArray = [self cubeMapImagesRotationFixedArrayUsingPanoMap:UINormalImage];
    
    return [NSMutableArray arrayWithObjects:ColorMapImagesArray,HeightMapImagesArray,NormalMapImagesArray, nil];
    
}


#pragma mark - make a array of SCNMaterials using given Pano Map
- (NSMutableArray *)cubeMapImagesRotationFixedArrayUsingPanoMap:(UIImage *)image
{
    cv::Mat PanoMap = [[JZ_ImageHelper sharedManager]cvMatFromUIImage:image];
    NSMutableArray *CubeMapArray = [[JZ_ImageHelper sharedManager] createCubeMapArray:PanoMap Width:PamoMapHeight/2 Height:PamoMapHeight/2];
    NSMutableArray *CubeMappingImages = [NSMutableArray array];
    
    
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
        
        //Image = [JZ_ImageHelper drawText:[NSString stringWithFormat:@"%d",i+1] fontSize:60.0f inImage:Image atPoint:CGPointMake(Image.size.width/2, Image.size.height/2)];
//        SCNMaterial *Material              = [SCNMaterial material];
//        Material.diffuse.contents          = Image;
        [CubeMappingImages addObject:Image];
    }

    return CubeMappingImages;
}


#pragma mark - init Scene
- (void)initSceneKitWith:(NSMutableArray *)CubeMappingImages
{
    PlanetSceneKitView.scene = [SCNScene scene];
    
    [[JZ_Skybox sharedManager] SkyboxInScene:PlanetSceneKitView.scene];
    
    PlanetSceneKitView.allowsCameraControl = YES;
    PlanetSceneKitView.showsStatistics = YES;
    PlanetSceneKitView.backgroundColor = [UIColor blackColor];
    
    if (isDebug)
    {
        PlanetSceneKitView.debugOptions = SCNDebugOptionShowWireframe;

    }
    
    JZ_Player *player = [JZ_Player node];
    player.ShipSceneName = @"ship.scn";
    [player initShip];
    [PlanetSceneKitView.scene.rootNode addChildNode:player];
    player.geometry.firstMaterial.reflective.contents = PlanetSceneKitView.scene.background.contents;
    player.position = SCNVector3Make(230, 0, 0);
    
//    SCNSphere *PlanetSphere = [SCNSphere sphereWithRadius:30.0f];
//    PlanetSphere.geodesic = NO;
//    
//    SCNNode *PlanetNode = [SCNNode nodeWithGeometry:PlanetSphere];
//    [PlanetSceneKitView.scene.rootNode addChildNode:PlanetNode];
//
    
    // create and add a camera to the scene
    //MDLCAMER CANNOT MAKE IT TO SCNCAMERA WITH chromaticAberration, TOTALLY USELESS!!!!!!!!!!!!!!!!!!!!!!
    //AND PBR MATERIALs IN MODELIO ALSO DONT SUPPORT SCENEKIT, WTF
    
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
//    cameraNode.camera.zNear = 0.000000001f;
//    cameraNode.camera.zFar = 9999999999.0f;
    cameraNode.camera.automaticallyAdjustsZRange = YES;
    [PlanetSceneKitView.scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 0, 100);
    
//    
//    //atomsphere
//    JZ_Atomsphere *atmosphere = [JZ_Atomsphere node];
//    atmosphere.sphereRadius = 200.0f;
//    [atmosphere initAtomsphere];
//    [PlanetSceneKitView.scene.rootNode addChildNode:atmosphere];
    
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
    
    SCNBox *SCNBoxToSphereMapping = [SCNBox boxWithWidth:200.0f height:200.0f length:200.0f chamferRadius:0.0f];
    SCNBoxToSphereMapping.widthSegmentCount = SubMesh;
    SCNBoxToSphereMapping.heightSegmentCount = SubMesh;
    SCNBoxToSphereMapping.lengthSegmentCount = SubMesh;
    
    //SCNBox automatically recreates its set of geometry elements depending on how many materials you assign
    //(that way it doesn't need six draw calls to render if it doesn't have six materials).
    NSMutableArray *Mats = [NSMutableArray array];
    for (int i = 0; i < 6; i++)
    {
        SCNMaterial *mat = [SCNMaterial material];
        mat.diffuse.contents = [[CubeMappingImages objectAtIndex:0] objectAtIndex:i];
        mat.normal.contents = [[CubeMappingImages objectAtIndex:2] objectAtIndex:i];
        [Mats addObject:mat];
    }
    SCNBoxToSphereMapping.materials = Mats;
    
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
    
    
    
    NSMutableArray * HeightMaterialsArray = [CubeMappingImages objectAtIndex:1];
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
        //NSLog (@"X %d Y %d Z %d",(int)x,(int)y,(int)z);
        
        // Face 2 - X+
        // Face 4 - X-
        // Face 5 - Y+
        // Face 6 - Y-
        // Face 1 - Z+
        // Face 3 - Z-
        float SphereX = x*sqrt(1-pow(y,2)/2.0f-pow(z,2)/2.0f + pow(y*z,2)/3.0f) * SCNBoxToSphereMapping.width / 2.0f;
        float SphereY = y*sqrt(1-pow(z,2)/2.0f-pow(x,2)/2.0f + pow(x*z,2)/3.0f) * SCNBoxToSphereMapping.width / 2.0f;
        float SphereZ = z*sqrt(1-pow(x,2)/2.0f-pow(y,2)/2.0f + pow(y*x,2)/3.0f) * SCNBoxToSphereMapping.width / 2.0f;
        
        CGPoint spacePositionPoint;
        CGPoint TextureMappingPoint;
        UIImage *OneFaceImage;
        UIColor *color;
        CGFloat GreyScale;

        if ((int)round(z*SubMesh) == SubMesh)
        {
            // Face 1
            // Map HeightMap with x,y
            
            //                    (-1)-(+1)--->X+
            //                (+1)
            //                 |
            //                (-1)
            //                 |
            //                 |
            //                 V Y-
            OneFaceImage = [HeightMaterialsArray objectAtIndex:0];
            spacePositionPoint = CGPointMake(x, y);
            TextureMappingPoint = CGPointMake((x+1.0f)/2.0f, (1.0f-y)/2.0f);
            color = [[JZ_ImageHelper sharedManager] colorFromImage:OneFaceImage sampledAtPoint:TextureMappingPoint];
            GreyScale = [[JZ_ImageHelper sharedManager] greyScaleFromUIColor:color];
            
            SphereX = SphereX * (1.10-GreyScale*0.10);
            SphereY = SphereY * (1.10-GreyScale*0.10);
            SphereZ = SphereZ * (1.10-GreyScale*0.10);
            
        }else if ((int)round(z*SubMesh) == -SubMesh)
        {
            // Face 3
            // Map HeightMap with x,y
            
            //                    (+1)-(-1)--->X-
            //                (+1)
            //                 |
            //                (-1)
            //                 |
            //                 |
            //                 V Y-
            OneFaceImage = [HeightMaterialsArray objectAtIndex:2];
            spacePositionPoint = CGPointMake(x, y);
            TextureMappingPoint = CGPointMake((1.0f-x)/2.0f, (1.0f-y)/2.0f);
            color = [[JZ_ImageHelper sharedManager] colorFromImage:OneFaceImage sampledAtPoint:TextureMappingPoint];
            GreyScale = [[JZ_ImageHelper sharedManager] greyScaleFromUIColor:color];
            
            SphereX = SphereX * (1.10-GreyScale*0.10);
            SphereY = SphereY * (1.10-GreyScale*0.10);
            SphereZ = SphereZ * (1.10-GreyScale*0.10);
            
        }else if ((int)round(x*SubMesh) == SubMesh)
        {
            // Face 2
            // Map HeightMap with z,y
            
            //                    (+1)-(-1)--->Z-
            //                (+1)
            //                 |
            //                (-1)
            //                 |
            //                 |
            //                 V Y-
            OneFaceImage = [HeightMaterialsArray objectAtIndex:1];
            spacePositionPoint = CGPointMake(z, y);
            TextureMappingPoint = CGPointMake((1.0f-z)/2.0f, (1.0f-y)/2.0f);
            color = [[JZ_ImageHelper sharedManager] colorFromImage:OneFaceImage sampledAtPoint:TextureMappingPoint];
            GreyScale = [[JZ_ImageHelper sharedManager] greyScaleFromUIColor:color];
            
            SphereX = SphereX * (1.10-GreyScale*0.10);
            SphereY = SphereY * (1.10-GreyScale*0.10);
            SphereZ = SphereZ * (1.10-GreyScale*0.10);
            
        }else if ((int)round(x*SubMesh) == -SubMesh)
        {
            // Face 4
            // Map HeightMap with z,y
            
            //                    (-1)-(+1)--->Z+
            //                (+1)
            //                 |
            //                (-1)
            //                 |
            //                 |
            //                 V Y-
            OneFaceImage = [HeightMaterialsArray objectAtIndex:3];
            spacePositionPoint = CGPointMake(z, y);
            TextureMappingPoint = CGPointMake((z+1.0f)/2.0f, (1.0f-y)/2.0f);
            color = [[JZ_ImageHelper sharedManager] colorFromImage:OneFaceImage sampledAtPoint:TextureMappingPoint];
            GreyScale = [[JZ_ImageHelper sharedManager] greyScaleFromUIColor:color];
            
            SphereX = SphereX * (1.10-GreyScale*0.10);
            SphereY = SphereY * (1.10-GreyScale*0.10);
            SphereZ = SphereZ * (1.10-GreyScale*0.10);
            
        }else if ((int)round(y*SubMesh) == -SubMesh)
        {
            // Face 6
            // Map HeightMap with x,z
            
            //                    (-1)-(+1)--->X+
            //                (+1)
            //                 |
            //                (-1)
            //                 |
            //                 |
            //                 V Z-
            OneFaceImage = [HeightMaterialsArray objectAtIndex:5];
            spacePositionPoint = CGPointMake(x, z);
            TextureMappingPoint = CGPointMake((x+1.0f)/2.0f, (1.0f-z)/2.0f);
            color = [[JZ_ImageHelper sharedManager] colorFromImage:OneFaceImage sampledAtPoint:TextureMappingPoint];
            GreyScale = [[JZ_ImageHelper sharedManager] greyScaleFromUIColor:color];
            
            SphereX = SphereX * (1.10-GreyScale*0.10);
            SphereY = SphereY * (1.10-GreyScale*0.10);
            SphereZ = SphereZ * (1.10-GreyScale*0.10);
            
        }else if ((int)round(y*SubMesh) == SubMesh)
        {
            // Face 5
            // Map HeightMap with x,z
            
            //                    (-1)-(+1)--->X+
            //                (-1)
            //                 |
            //                (+1)
            //                 |
            //                 |
            //                 V Z+
            OneFaceImage = [HeightMaterialsArray objectAtIndex:4];
            spacePositionPoint = CGPointMake(x, z);
            TextureMappingPoint = CGPointMake((x+1.0f)/2.0f, (z+1.0f)/2.0f);
            color = [[JZ_ImageHelper sharedManager] colorFromImage:OneFaceImage sampledAtPoint:TextureMappingPoint];
            GreyScale = [[JZ_ImageHelper sharedManager] greyScaleFromUIColor:color];
            
            SphereX = SphereX * (1.10-GreyScale*0.10);
            SphereY = SphereY * (1.10-GreyScale*0.10);
            SphereZ = SphereZ * (1.10-GreyScale*0.10);
            
        }

        
        // ... Maybe even save it as an SCNVector3 for later use ...
        //[vertices addObject:[NSValue valueWithSCNVector3:SCNVector3Make(SphereX, SphereY, SphereZ)]];
        SCNVector3 SphereVector3 = SCNVector3Make(SphereX, SphereY, SphereZ);
        vertices[i] = SphereVector3;
        
        // ... or just log it
        //NSLog(@"x:%f, y:%f, z:%f", x, y, z);
        //NSLog(@"SphereX:%f, SphereY:%f, SphereX:%f", SphereX, SphereY, SphereZ);
    }
    
    SCNGeometrySource *DeformedGeometrySource = [SCNGeometrySource geometrySourceWithVertices:vertices count:vectorCount];
    NSMutableArray *SCNGeometrySourceArray = [NSMutableArray arrayWithObject:DeformedGeometrySource];
    [SCNGeometrySourceArray addObject:[geometrySources objectAtIndex:2]];
    
    NSArray *DeformGeometryElement = [PlanetNode.geometry geometryElements];
    SCNGeometry *DeformedGeometry = [SCNGeometry geometryWithSources:SCNGeometrySourceArray elements:DeformGeometryElement];
    
    
    MDLMesh *DeformedGeometryUsingMDL = [MDLMesh meshWithSCNGeometry:DeformedGeometry];
    [DeformedGeometryUsingMDL addNormalsWithAttributeNamed:MDLVertexAttributeNormal creaseThreshold:0.2f];
    
    DeformedGeometry = [SCNGeometry geometryWithMDLMesh:DeformedGeometryUsingMDL];
    PlanetNode.geometry = DeformedGeometry;
    PlanetNode.geometry.materials = Mats;
    


    
//    NSURL *ShaderURL = [[NSBundle mainBundle]
//                                URLForResource:@"/SCNShaderModifierEntryPointLightingModel_Toon" withExtension:@"shader"];
//    NSString *Shader = [[NSString alloc] initWithContentsOfURL:ShaderURL
//                                                            encoding:NSUTF8StringEncoding
//                                                               error:NULL];
//    PlanetNode.geometry.firstMaterial.shaderModifiers = @{ SCNShaderModifierEntryPointLightingModel : Shader};

    
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

    PlanetNode.geometry.materials = [self NoiseCubemapWithSeed:SCNVector3Make(10.0f*sender.value*2, 2.0f*sender.value*2, 0.6f*sender.value*2)];
}

#pragma mark - Update Method
- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time
{
    [PlanetSceneKitView.scene.rootNode enumerateChildNodesUsingBlock:^(SCNNode *child,
                                                                      BOOL *stop)
    {
        if ([child respondsToSelector:@selector(LogicUpdate)])
        {
            [child performSelector:@selector(LogicUpdate)];
        }
    }];
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
