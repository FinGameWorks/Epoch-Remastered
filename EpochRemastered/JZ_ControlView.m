//
//  JZ_JoystickView.m
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/12.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "JZ_ControlView.h"

@interface JZ_ControlView ()
@property (nonatomic,strong) UIImageView *joystickLeftBaseImageView;
@property (nonatomic,strong) UIImageView *joystickLeftTouchImageView;
@property (nonatomic) CGPoint joystickPoint;
@property (nonatomic) CGSize joystickBaseSize;
@property (nonatomic) CGSize joystickTouchSize;

@property (nonatomic,strong) UIImageView *buttonRightPressedImageView;
@property (nonatomic,strong) UIImageView *buttonRightNormalImageView;

@property (nonatomic,strong) UIView *speedSliderFullScreemView;
@end
@implementation JZ_ControlView
@synthesize joystickPoint,joystickBaseSize,joystickTouchSize;
@synthesize joystickLeftBaseImageView,joystickLeftTouchImageView;
@synthesize speedSliderFullScreemView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self initControl];
    }
    return self;
}

- (void) initControl
{
    speedSliderFullScreemView = [[UIView alloc] initWithFrame:[self frame]];
    [self addSubview:speedSliderFullScreemView];
    
    joystickLeftBaseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"joystickLeftBaseImage"]];
    [self addSubview:joystickLeftBaseImageView];
    joystickLeftTouchImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"joystickLeftTouchImage"]];
    [self addSubview:joystickLeftTouchImageView];
    
    
    
    //caluate joystick pos
    [self layoutElements];
}

- (void)layoutElements
{
    joystickPoint = CGPointMake(self.frame.size.width/10*3, self.frame.size.height/10*7);
    joystickBaseSize = CGSizeMake(self.frame.size.height/10*3, self.frame.size.height/10*3);
    joystickTouchSize = CGSizeMake(self.frame.size.height/20*3, self.frame.size.height/20*3);
    
    joystickLeftBaseImageView.frame = CGRectMake(joystickPoint.x - joystickBaseSize.width/2, joystickPoint.y - joystickBaseSize.height/2, joystickBaseSize.width, joystickBaseSize.height);
    
    joystickLeftTouchImageView.frame = CGRectMake(joystickPoint.x - joystickTouchSize.width/2, joystickPoint.y - joystickTouchSize.height/2, joystickTouchSize.width, joystickTouchSize.height);
}

@end
