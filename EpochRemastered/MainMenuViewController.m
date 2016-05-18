//
//  MainMenuViewController.m
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/17.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "MainMenuViewController.h"
#import "NoiseDebuggerViewController.h"
@import SceneKit;

@interface MainMenuViewController ()
@property (weak, nonatomic) IBOutlet SCNView *MainMenuBackgroundSCNView;
@property (weak, nonatomic) IBOutlet UIImageView *LogoImageView;
@property (weak, nonatomic) IBOutlet UIButton *startGameButton;
@property (weak, nonatomic) IBOutlet UIButton *SettingsButton;
@property (weak, nonatomic) IBOutlet UIView *leftBarView;

@end

@implementation MainMenuViewController

@synthesize MainMenuBackgroundSCNView,LogoImageView,leftBarView;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //SCNSceneSource *source = [SCNSceneSource sceneSourceWithURL:<#(nonnull NSURL *)#> options:nil];
    
    SCNScene * scene = [SCNScene sceneNamed:@"art.scnassets/MainMenuScene.scn"];
    MainMenuBackgroundSCNView.scene = scene;
    MainMenuBackgroundSCNView.playing = YES;
    

    
    //FADE IN
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 3.0f;
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat:1.0f];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    animation.additive = NO;
    [leftBarView.layer addAnimation:animation forKey:@"opacityIN"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SettingsButtonPressed:(id)sender
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
