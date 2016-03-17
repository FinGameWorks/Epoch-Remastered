//
//  MainMenuViewController.m
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/17.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "MainMenuViewController.h"
@import SceneKit;

@interface MainMenuViewController ()
@property (weak, nonatomic) IBOutlet SCNView *MainMenuBackgroundSCNView;
@property (weak, nonatomic) IBOutlet UIImageView *LogoImageView;
@property (weak, nonatomic) IBOutlet UIButton *startGameButton;
@property (weak, nonatomic) IBOutlet UIButton *SettingsButton;

@end

@implementation MainMenuViewController

@synthesize MainMenuBackgroundSCNView,LogoImageView;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //SCNSceneSource *source = [SCNSceneSource sceneSourceWithURL:<#(nonnull NSURL *)#> options:nil];
    
    SCNScene * scene = [SCNScene sceneNamed:@"art.scnassets/MainMenuScene.scn"];
    MainMenuBackgroundSCNView.scene = scene;
    MainMenuBackgroundSCNView.playing = YES;
    
//    
//    CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
//    MainMenuBackgroundSCNView.scene.rootNode.filters = @[filter];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)StartGameButtonPressed:(id)sender
{
    
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
