//
//  AimViewController.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/23.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "AimViewController.h"
#import "AimView.h"

#define kUpdateInterval (1.0f / 60.0f)

@interface AimViewController ()
{
    AimView* crosshairs;
}
@end

@implementation AimViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 加入準星
    crosshairs = [[AimView alloc] initWithFrame:self.view.frame];
    [crosshairs setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:crosshairs];
    
    // Movement of aim
    self.lastUpdateTime = [[NSDate alloc] init];
    
    self.currentPoint  = CGPointMake(300, 300);
    self.motionManager = [[CMMotionManager alloc]  init];
    self.queue         = [[NSOperationQueue alloc] init];
    
    self.motionManager.accelerometerUpdateInterval = kUpdateInterval;
    
    [self.motionManager startAccelerometerUpdatesToQueue:self.queue withHandler:
     ^(CMAccelerometerData *accelerometerData, NSError *error) {
         [(id) self setAcceleration:accelerometerData.acceleration];
         [self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Acceleration

- (void)update {
    NSTimeInterval secondsSinceLastDraw = -([self.lastUpdateTime timeIntervalSinceNow]);
    
    self.aimXVelocity = self.aimXVelocity - (self.acceleration.x * secondsSinceLastDraw);
    self.aimYVelocity = self.aimYVelocity - (self.acceleration.y * secondsSinceLastDraw);
    
    CGFloat xDelta = secondsSinceLastDraw * self.aimXVelocity * 500;
    CGFloat yDelta = secondsSinceLastDraw * self.aimYVelocity * 500;
    
    self.currentPoint = CGPointMake(self.currentPoint.x + xDelta, self.currentPoint.y + yDelta);
    
    [self moveCrossHairs];
    
    self.lastUpdateTime = [NSDate date];
}

- (void)moveCrossHairs
{
    [self collideTarget];
    [self collideBounds];
    
    [crosshairs moveCenterTo:self.currentPoint.x y:self.currentPoint.y];
    self.previousPoint = self.currentPoint;
}

#pragma mark - Collision

- (void)collideTarget
{
    if (CGRectIntersectsRect([crosshairs rectOfCircle], CGRectMake(873, 468, 20, 200))) {
        
        [self.motionManager stopAccelerometerUpdates];
        
        // 顯示學校縮影
        [self.game_bg setImage:nil];
        [self.lblOutline setHidden:NO];
        
        // 加入點擊手勢，點後回故事view
        UITapGestureRecognizer *tapGestureRecognizer;
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(complete)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:tapGestureRecognizer];
    }
}

- (void)collideBounds
{
    if (self.currentPoint.x < 0) {
        _currentPoint.x = 0;
        self.aimXVelocity = -(self.aimXVelocity / 1.0);
    }
    
    if (self.currentPoint.y < 0) {
        _currentPoint.y = 0;
        self.aimYVelocity = -(self.aimYVelocity / 1.0);
    }
    
    if (self.currentPoint.x > self.view.bounds.size.width - 30) {
        _currentPoint.x = self.view.bounds.size.width - 30;
        self.aimXVelocity = -(self.aimXVelocity / 1.0);
    }
    
    if (self.currentPoint.y > self.view.bounds.size.height - 30) {
        _currentPoint.y = self.view.bounds.size.height - 30;
        self.aimYVelocity = -(self.aimYVelocity / 1.0);
    }
}

- (void)complete
{
    //[self.game_bg setImage:nil];
    [self.delegate gameComplete];
    [self.lblOutline setHidden:YES];
    [self.game_boy setHidden:YES];
}

@end
