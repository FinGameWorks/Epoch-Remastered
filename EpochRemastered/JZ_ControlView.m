//
//  JZ_JoystickView.m
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/12.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "JZ_ControlView.h"

@interface JZ_ControlView ()<UIGestureRecognizerDelegate>
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


@synthesize JoystickTouchVector,speedSliderDirection;

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
    speedSliderFullScreemView.userInteractionEnabled = YES;
    //Swipe Down Gesture
    UISwipeGestureRecognizer * speedSliderFullScreemViewSwipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSpeedSliderFullScreemViewSwipe:)];
    speedSliderFullScreemViewSwipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    //Swipe Up Gesture
    UISwipeGestureRecognizer * speedSliderFullScreemViewSwipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSpeedSliderFullScreemViewSwipe:)];
    speedSliderFullScreemViewSwipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    // Added Gesture;
    [speedSliderFullScreemView addGestureRecognizer:speedSliderFullScreemViewSwipeDownGestureRecognizer];
    [speedSliderFullScreemView addGestureRecognizer:speedSliderFullScreemViewSwipeUpGestureRecognizer];
    [self addSubview:speedSliderFullScreemView];
    
    
    
    joystickLeftBaseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"joystickLeftBaseImage"]];
    joystickLeftBaseImageView.userInteractionEnabled = YES;
    UIPanGestureRecognizer * joystickLeftBaseImageViewPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlejoystickLeftBaseImageViewPan:)];
    [joystickLeftBaseImageViewPanGestureRecognizer setMinimumNumberOfTouches:1];
    [joystickLeftBaseImageViewPanGestureRecognizer setMaximumNumberOfTouches:1];
    [joystickLeftBaseImageView addGestureRecognizer:joystickLeftBaseImageViewPanGestureRecognizer];
    [self addSubview:joystickLeftBaseImageView];
    
    
    joystickLeftTouchImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"joystickLeftTouchImage"]];
    joystickLeftTouchImageView.userInteractionEnabled = NO;
    [joystickLeftBaseImageView addSubview:joystickLeftTouchImageView];
    
    
    
    //caluate joystick pos
    [self layoutElements];
}

- (void)layoutElements
{
    joystickPoint = CGPointMake(self.frame.size.width/10*2, self.frame.size.height/10*8);
    joystickBaseSize = CGSizeMake(self.frame.size.height/10*2, self.frame.size.height/10*2);
    joystickTouchSize = CGSizeMake(self.frame.size.height/20*2, self.frame.size.height/20*2);
    
    joystickLeftBaseImageView.frame = CGRectMake(joystickPoint.x - joystickBaseSize.width/2, joystickPoint.y - joystickBaseSize.height/2, joystickBaseSize.width, joystickBaseSize.height);
    
    joystickLeftTouchImageView.frame = CGRectMake(joystickBaseSize.width/2 - joystickTouchSize.width/2, joystickBaseSize.height/2 - joystickTouchSize.height/2, joystickTouchSize.width, joystickTouchSize.height);
}

- (void)handlejoystickLeftBaseImageViewPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        JoystickTouchVector = CGPointMake(0.0f, 0.0f);
    }else
    {
        JoystickTouchVector = CGPointMake([gesture locationInView:joystickLeftBaseImageView].x - joystickLeftBaseImageView.frame.size.width/2, [gesture locationInView:joystickLeftBaseImageView].y - joystickLeftBaseImageView.frame.size.height/2);
    }
    
    joystickLeftTouchImageView.center = CGPointMake(JoystickTouchVector.x + joystickLeftBaseImageView.frame.size.width/2, JoystickTouchVector.y + joystickLeftBaseImageView.frame.size.height/2);
    
    NSLog(@"joystick : X:%f  Y:%f",JoystickTouchVector.x,JoystickTouchVector.y);
}


- (void)handleSpeedSliderFullScreemViewSwipe:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionUp)
    {
        speedSliderDirection = 1;
    }
    else if (gesture.direction == UISwipeGestureRecognizerDirectionDown)
    {
        speedSliderDirection = -1;
    }
    else
    {
        speedSliderDirection = 0;
    }
}



@end
