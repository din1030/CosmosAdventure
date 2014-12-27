//
//  MatchViewController.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/23.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "MatchViewController.h"
#import "DialogView.h"
#import "GoalView.h"

#define CLOSE_CALL 30

@interface MatchViewController ()
{
    BOOL isCalledComplete;
    BOOL isMatched1;
    BOOL isMatched2;
    BOOL isMatched3;
    BOOL isMatched4;
    BOOL isMatched5;
    CGPoint originalCenter;
    CGPoint destination1;
    CGPoint destination2;
    CGPoint destination3;
    CGPoint destination4;
    CGPoint destination5;
    
    GoalView* glv;
    DialogView* dlg;
    UIView* noti;
    NSString* noticeText;
}
@end

@implementation MatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    glv = [[GoalView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [glv.lblTitle setText:@"【井井有條】"];
    [glv.lblDetail setText:@"把房間的物品放回原來的位置"];
    [glv.btnConfirm addTarget:self action:@selector(closeGoalView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:glv];
    
    dlg = [[DialogView alloc] initWithFrame:CGRectMake(252, 505, 772, 243)];
    [dlg setHidden:YES];
    [dlg.lblDialog setText:@"【井井有條】魔法成功！"];
    [dlg.imgCharacter setImage:[UIImage imageNamed:@"c_magic.png"]];
    [self.view addSubview:dlg];
    
    isMatched1 = NO;
    isMatched2 = NO;
    isMatched3 = NO;
    isMatched4 = NO;
    isMatched5 = NO;
    isCalledComplete = NO;
    destination1 = CGPointMake(562, 381);
    destination2 = CGPointMake(908, 438);
    destination3 = CGPointMake(235, 492);
    destination4 = CGPointMake(280, 413);
    destination5 = CGPointMake(151, 274);
    
    // 放入道具的動畫（大->小->正常）
    
    UIPanGestureRecognizer *panGesture1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag1:)];
    UIPanGestureRecognizer *panGesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag2:)];
    UIPanGestureRecognizer *panGesture3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag3:)];
    UIPanGestureRecognizer *panGesture4 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag4:)];
    UIPanGestureRecognizer *panGesture5 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag5:)];
    [self.btnItem1 addGestureRecognizer:panGesture1];
    [self.btnItem2 addGestureRecognizer:panGesture2];
    [self.btnItem3 addGestureRecognizer:panGesture3];
    [self.btnItem4 addGestureRecognizer:panGesture4];
    [self.btnItem5 addGestureRecognizer:panGesture5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Dragging

- (void) drag1:(UIPanGestureRecognizer *) panGesture{
    CGPoint translation = [panGesture translationInView:self.view];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            originalCenter = self.btnItem1.center;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            self.btnItem1.center = CGPointMake(self.btnItem1.center.x + translation.x,
                                               self.btnItem1.center.y + translation.y);
            
            CGFloat xDist = (destination1.x - self.btnItem1.center.x);
            CGFloat yDist = (destination1.y - self.btnItem1.center.y);
            if(sqrt((xDist * xDist) + (yDist * yDist)) < CLOSE_CALL) {
                isMatched1 = YES;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:{
            if(isMatched1) {
                [UIView animateWithDuration:0.1 animations:^{
                                     self.btnItem1.center = destination1;
                                 } completion:^(BOOL finished){
                                     [self.btnItem1 setUserInteractionEnabled:NO];
                                     noticeText = @"筆筒放回去了！";
                                     [self checkCompeletion];
                                 }];
            } else {
                [UIView animateWithDuration:1 animations:^{
                                     self.btnItem1.center = originalCenter;
                                 } completion:^(BOOL finished){
                                     NSLog(@"Returned");
                                 }];
            }
        }
            break;
        default:
            break;
    }
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void) drag2:(UIPanGestureRecognizer *) panGesture{
    CGPoint translation = [panGesture translationInView:self.view];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            originalCenter = self.btnItem2.center;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            self.btnItem2.center = CGPointMake(self.btnItem2.center.x + translation.x,
                                               self.btnItem2.center.y + translation.y);
            
            CGFloat xDist = (destination2.x - self.btnItem2.center.x);
            CGFloat yDist = (destination2.y - self.btnItem2.center.y);
            if(sqrt((xDist * xDist) + (yDist * yDist)) < CLOSE_CALL) {
                isMatched2 = YES;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:{
            if(isMatched2) {
                [UIView animateWithDuration:0.1 animations:^{
                    self.btnItem2.center = destination2;
                } completion:^(BOOL finished){
                    [self.btnItem2 setUserInteractionEnabled:NO];
                    noticeText = @"火箭放回去了！";
                    [self checkCompeletion];
                }];
            } else {
                [UIView animateWithDuration:1 animations:^{
                    self.btnItem2.center = originalCenter;
                } completion:^(BOOL finished){
                    NSLog(@"Returned");
                }];
            }
        }
            break;
        default:
            break;
    }
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void) drag3:(UIPanGestureRecognizer *) panGesture{
    CGPoint translation = [panGesture translationInView:self.view];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            originalCenter = self.btnItem3.center;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            self.btnItem3.center = CGPointMake(self.btnItem3.center.x + translation.x,
                                               self.btnItem3.center.y + translation.y);
            
            CGFloat xDist = (destination3.x - self.btnItem3.center.x);
            CGFloat yDist = (destination3.y - self.btnItem3.center.y);
            if(sqrt((xDist * xDist) + (yDist * yDist)) < CLOSE_CALL) {
                isMatched3 = YES;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:{
            if(isMatched3) {
                [UIView animateWithDuration:0.1 animations:^{
                    self.btnItem3.center = destination3;
                } completion:^(BOOL finished){
                    [self.btnItem3 setUserInteractionEnabled:NO];
                    noticeText = @"積木放回去了！";
                    [self checkCompeletion];
                }];
            } else {
                [UIView animateWithDuration:1 animations:^{
                    self.btnItem3.center = originalCenter;
                } completion:^(BOOL finished){
                    NSLog(@"Returned");
                }];
            }
        }
            break;
        default:
            break;
    }
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void) drag4:(UIPanGestureRecognizer *) panGesture{
    CGPoint translation = [panGesture translationInView:self.view];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            originalCenter = self.btnItem4.center;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            self.btnItem4.center = CGPointMake(self.btnItem4.center.x + translation.x,
                                               self.btnItem4.center.y + translation.y);
            
            CGFloat xDist = (destination4.x - self.btnItem4.center.x);
            CGFloat yDist = (destination4.y - self.btnItem4.center.y);
            if(sqrt((xDist * xDist) + (yDist * yDist)) < CLOSE_CALL) {
                isMatched4 = YES;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:{
            if(isMatched4) {
                [UIView animateWithDuration:0.1 animations:^{
                    self.btnItem4.center = destination4;
                } completion:^(BOOL finished){
                    [self.btnItem4 setUserInteractionEnabled:NO];
                    noticeText = @"汽車放回去了！";
                    [self checkCompeletion];
                }];
            } else {
                [UIView animateWithDuration:1 animations:^{
                    self.btnItem4.center = originalCenter;
                } completion:^(BOOL finished){
                    NSLog(@"Returned");
                }];
            }
        }
            break;
        default:
            break;
    }
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void) drag5:(UIPanGestureRecognizer *) panGesture{
    CGPoint translation = [panGesture translationInView:self.view];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            originalCenter = self.btnItem5.center;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            self.btnItem5.center = CGPointMake(self.btnItem5.center.x + translation.x,
                                               self.btnItem5.center.y + translation.y);
            
            CGFloat xDist = (destination5.x - self.btnItem5.center.x);
            CGFloat yDist = (destination5.y - self.btnItem5.center.y);
            if(sqrt((xDist * xDist) + (yDist * yDist)) < CLOSE_CALL) {
                isMatched5 = YES;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:{
            if(isMatched5) {
                [UIView animateWithDuration:0.1 animations:^{
                    self.btnItem5.center = destination5;
                } completion:^(BOOL finished){
                    [self.btnItem5 setUserInteractionEnabled:NO];
                    noticeText = @"小熊放回去了！";
                    [self checkCompeletion];
                }];
            } else {
                [UIView animateWithDuration:1 animations:^{
                    self.btnItem5.center = originalCenter;
                } completion:^(BOOL finished){
                    NSLog(@"Returned");
                }];
            }
        }
            break;
        default:
            break;
    }
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void)checkCompeletion
{
    [self playSound:@"item"];
    if(isMatched1 && isMatched2 && isMatched3 && isMatched4 && isMatched5) {
        noticeText = @"房間整理完畢！";
    }
    
    // 彈出訊息視窗
    if(noti) {
        [noti removeFromSuperview];
    }
    noti = [[UIView alloc] initWithFrame:CGRectMake(365, 768, 294, 110)];
    
    [noti setAlpha:0.8];
    [noti setBackgroundColor:[UIColor clearColor]];
    
    UIImageView* bnoti = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_notification.png"]];
    [bnoti setFrame:CGRectMake(0, 0, 294, 110)];
    [noti addSubview:bnoti];
    
    UILabel* lnoti = [[UILabel alloc] initWithFrame:CGRectMake(22, 30, 250, 50)];
    [lnoti setTextColor:[UIColor blackColor]];
    [lnoti setFont:[UIFont systemFontOfSize:21.0]];
    [lnoti setTextAlignment:NSTextAlignmentCenter];
    [lnoti setText:noticeText];
    [noti addSubview:lnoti];
    
    [self.view addSubview:noti];
    
    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [noti setFrame:CGRectMake(365, 768-110, 294, 110)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f delay:1.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [noti setFrame:CGRectMake(365, 768, 294, 110)];
        } completion:^(BOOL finished) {
            // 若全放好，回劇情
            if(isMatched1 && isMatched2 && isMatched3 && isMatched4 && isMatched5 && !isCalledComplete){
                isCalledComplete = YES;
                [self playSound:@"magic"];
            }
        }];
    }];
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
    }];
}

#pragma mark - AVAudioPlayer Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if([player.url isEqual:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"magic" ofType:@"mp3"]]]) {
        [dlg setHidden:NO];
        UITapGestureRecognizer *tapGestureRecognizer;
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(complete)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:tapGestureRecognizer];
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
