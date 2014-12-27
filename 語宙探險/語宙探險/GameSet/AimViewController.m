//
//  AimViewController.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/23.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "AimViewController.h"
#import "AimView.h"
#import "DialogView.h"
#import "GoalView.h"

#define kUpdateInterval (1.0f / 60.0f)

@interface AimViewController ()
{
    AimView* crosshairs;
    GoalView* glv;
    DialogView* dlg;
}
@end

@implementation AimViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    glv = [[GoalView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [glv.lblTitle setText:@"【知己知彼】"];
    [glv.lblDetail setText:@"移動魔法準星對準目標"];
    [glv.btnConfirm addTarget:self action:@selector(closeGoalView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:glv];
    
    dlg = [[DialogView alloc] initWithFrame:CGRectMake(252, 505, 772, 243)];
    [dlg setHidden:YES];
    [dlg.lblDialog setText:@"【知己知彼】魔法成功！"];
    [dlg.imgCharacter setImage:[UIImage imageNamed:@"c_magic.png"]];
    [self.view addSubview:dlg];
    
    // 設定準星
    crosshairs = [[AimView alloc] initWithFrame:self.view.frame];
    [crosshairs setBackgroundColor:[UIColor clearColor]];
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
        
        // 小男孩顯現
        [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.game_boy_bk.alpha = 0.7;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1f delay:0.1f options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.game_boy_bk.alpha = 1.0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.game_boy_bk.alpha = 0.3;
                } completion:^(BOOL finished) {
                    [self playSound:@"magic"];
                    [UIView animateWithDuration:1.0f delay:0.2f options:UIViewAnimationOptionCurveEaseIn animations:^{
                        self.game_boy_bk.alpha = 1;
                    } completion:^(BOOL finished) {
                        self.game_boy_bk.alpha = 0;
                    }];
                }];
            }];
        }];
        
        // 顯示學校縮影
        [UIView animateWithDuration:0.5f delay:2.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.game_boy setAlpha:0.0];
            [self.game_bg setAlpha:0.3];
        } completion:^(BOOL finished) {
            [crosshairs setHidden:YES];
            [self.game_bg setImage:[UIImage imageNamed:@"stage2.png"]];
            [dlg setAlpha:0];
            [dlg setHidden:NO];
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.game_bg setAlpha:1];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3f delay:1.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [dlg setAlpha:1];
                } completion:^(BOOL finished){
                    UITapGestureRecognizer *tapGestureRecognizer;
                    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(complete)];
                    tapGestureRecognizer.numberOfTapsRequired = 1;
                    [self.view addGestureRecognizer:tapGestureRecognizer];
                }];
            }];
        }];
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
    [self playSound:@"dialog"];
}

- (void)closeGoalView
{
    [self playSound:@"click"];
    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [glv setAlpha:0];
    } completion:^(BOOL finished) {
        [glv removeFromSuperview];
        
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
    }];
}

#pragma mark - AVAudioPlayer Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if([player.url isEqual:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"magic" ofType:@"mp3"]]]) {
    }
    if([player.url isEqual:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"dialog" ofType:@"mp3"]]]) {
        [self.delegate gameComplete];
    }
}

// 播放音效
- (void)playSound:(NSString*)fileName
{
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"]];
    NSError* err;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    if(err) {
        NSLog(@"PlaySound Error: %@", [err localizedDescription]);
    } else {
        [self.audioPlayer setDelegate:self];
        [self.audioPlayer play];
    }
}

@end
