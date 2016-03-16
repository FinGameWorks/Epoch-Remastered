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
@property (nonatomic) CGPoint speedSliderFullScreemViewStartPoint;




@property (nonatomic) float joystickReleaseDistance;
@end
@implementation JZ_ControlView
@synthesize joystickPoint,joystickBaseSize,joystickTouchSize;
@synthesize joystickLeftBaseImageView,joystickLeftTouchImageView;
@synthesize speedSliderFullScreemView;
@synthesize joystickReleaseDistance;
@synthesize JoystickTouchVector,speedSliderDirection,speedSliderFullScreemViewStartPoint;

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
    UIPanGestureRecognizer *speedSliderFullScreemViewPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSpeedSliderFullScreemViewPan:)];
    [speedSliderFullScreemView addGestureRecognizer:speedSliderFullScreemViewPanGestureRecognizer];
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
    
    joystickReleaseDistance = sqrt(powf(joystickLeftBaseImageView.frame.size.width/2, 2.0f) + powf(joystickLeftBaseImageView.frame.size.height/2, 2.0f));
}

- (void)handlejoystickLeftBaseImageViewPan:(UIPanGestureRecognizer *)gesture
{
    //Check if Joystick touch image have be dragged out the Base Image's Bounds;
    
    CGPoint point = [gesture locationInView:joystickLeftBaseImageView];
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        JoystickTouchVector = CGPointMake(0.0f, 0.0f);
    }else
    {
        JoystickTouchVector = CGPointMake((point.x - joystickLeftBaseImageView.frame.size.width/2)/joystickReleaseDistance, (point.y - joystickLeftBaseImageView.frame.size.height/2)/joystickReleaseDistance);
    }
    
    CGFloat distance = sqrt(powf(JoystickTouchVector.x, 2.0f) + powf(JoystickTouchVector.y, 2.0f));
    
    
    if (distance > 1.0f)
    {
        //JoystickTouchVector = CGPointMake(0.0f, 0.0f);
        JoystickTouchVector = CGPointMake((point.x - joystickLeftBaseImageView.frame.size.width/2)/joystickReleaseDistance, (point.y - joystickLeftBaseImageView.frame.size.height/2)/joystickReleaseDistance);
        JoystickTouchVector  = CGPointMake(JoystickTouchVector.x / distance, JoystickTouchVector.y / distance);
    }

    joystickLeftTouchImageView.center = CGPointMake(JoystickTouchVector.x * joystickReleaseDistance+ joystickLeftBaseImageView.frame.size.width/2, JoystickTouchVector.y * joystickReleaseDistance + joystickLeftBaseImageView.frame.size.height/2);
    
    NSLog(@"joystick : X:%f  Y:%f",JoystickTouchVector.x,JoystickTouchVector.y);
}

- (void)handleSpeedSliderFullScreemViewPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        speedSliderFullScreemViewStartPoint =[gesture locationInView:speedSliderFullScreemView];
    }
    else
    {
        CGPoint speedSliderFullScreemViewStopPoint = [gesture locationInView:speedSliderFullScreemView];
        CGFloat distanceY = speedSliderFullScreemViewStartPoint.y - speedSliderFullScreemViewStopPoint.y;
        CGFloat percentage = distanceY / speedSliderFullScreemView.frame.size.height;
        
        speedSliderDirection += percentage;
        
        if (speedSliderDirection < 0.0f)
        {
            speedSliderDirection = 0.0f;
        }
        else if (speedSliderDirection > 1.0f)
        {
            speedSliderDirection = 1.0f;
        }
        
        NSLog(@"speedSliderDirection: %f",speedSliderDirection);
    }
}


@end
