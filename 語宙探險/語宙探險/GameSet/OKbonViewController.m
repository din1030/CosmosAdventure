//
//  OKbonViewController.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/23.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "OKbonViewController.h"
#import "DialogView.h"
#import "GoalView.h"

#define GOAL_COUNT      12   // 四的倍數
#define HOLE_SIZE       400  // 四的倍數
#define DETECT_PULSE    0.6

@interface OKbonViewController ()
{
    int totalCount;
    double lowPassResults;
    double lastDetectTime;
    NSTimer *levelTimer;
    NSMutableArray *okbons;
    AVAudioRecorder *recorder;
    GoalView* glv;
    DialogView* dlg;
}
@end

@implementation OKbonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    glv = [[GoalView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [glv.lblTitle setText:@"【言而有信】"];
    [glv.lblDetail setText:self.gameName];
    [glv.btnConfirm addTarget:self action:@selector(closeGoalView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:glv];
    
    dlg = [[DialogView alloc] initWithFrame:CGRectMake(252, 505, 772, 243)];
    [dlg setHidden:YES];
    [dlg.lblDialog setText:@"【言而有信】魔法成功！"];
    [dlg.imgCharacter setImage:[UIImage imageNamed:@"c_magic.png"]];
    [self.view addSubview:dlg];
    
    totalCount = 0;
    lastDetectTime = 0;
    okbons = [[NSMutableArray alloc] init];
    
    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if (recorder) {
    } else {
        NSLog(@"Error! %@", [error description]);
    }

    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    self.prgrss.transform = CGAffineTransformMakeScale(1.0f, 25.0f);
    [self.prgrss setProgress:0];
    [self.prgrss setTintColor:[UIColor redColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Blowing

- (void)levelTimerCallback:(NSTimer *)timer
{
    [recorder updateMeters];
    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;

    [self.prgrss setProgress:lowPassResults];
    
    if (lowPassResults > 0.65) {
        [self.prgrss setTintColor:[UIColor greenColor]];
        // 避免馬上就完成
        if(recorder.currentTime - lastDetectTime >= DETECT_PULSE) {
            // 貼上一個OK繃
            [self.view addSubview:[self randomOKbon]];
            [self playSound:@"item"];
            totalCount ++;
            
            if(totalCount == GOAL_COUNT) {
                // 完成任務
                [recorder stop];
                [levelTimer invalidate];
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                [self.prgrss setHidden:YES];
                [self.btnFinish setHidden:NO];
                
                for(int i = 0; i < okbons.count; i++) {
                    [UIView animateWithDuration:0.8 animations:^{
                        [(UIImageView*)okbons[i] setAlpha:0];
                    }];
                }
                
                [UIView animateWithDuration:1.6f delay:0.8f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [self.imgUFO setAlpha:0.0];
                    [self playSound:@"magic"];
                } completion:^(BOOL finished) {
                }];
            }
            lastDetectTime = recorder.currentTime;
        }
    }
    else {
        [self.prgrss setTintColor:[UIColor redColor]];
    }
}

- (UIImageView*)randomOKbon
{
    UIImageView* okb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"okbon.png"]];
    
    int x = 0;
    int y = arc4random_uniform(HOLE_SIZE) + 81;
    // 平均分配
    if(totalCount < GOAL_COUNT*0.25) {
        x = arc4random_uniform(HOLE_SIZE*0.25) + (1024-HOLE_SIZE)/2;
    } else if(totalCount >= GOAL_COUNT*0.25 && totalCount < GOAL_COUNT * 0.5) {
        x = arc4random_uniform(HOLE_SIZE*0.25) + (1024-HOLE_SIZE)/2 + HOLE_SIZE * 0.25;
    } else if(totalCount >= GOAL_COUNT*0.5 && totalCount < GOAL_COUNT * 0.75) {
        x = arc4random_uniform(HOLE_SIZE*0.25) + (1024-HOLE_SIZE)/2 + HOLE_SIZE * 0.5;
    } else if(totalCount >= GOAL_COUNT*0.75 && totalCount < GOAL_COUNT) {
        x = arc4random_uniform(HOLE_SIZE*0.25) + (1024-HOLE_SIZE)/2 + HOLE_SIZE * 0.75;
    }
    
    [okb setFrame:CGRectMake(x, y, 112, 262)];
    
    // 旋轉
    int angle = arc4random_uniform(180);
    okb.transform = CGAffineTransformMakeRotation(angle);
    
    [okbons addObject:okb];
    
    return okb;
}

- (IBAction)btnFinishClicked:(id)sender
{
    [self playSound:@"dialog"];
    [UIView animateWithDuration:0.2 animations:^{
        [self.view setAlpha:0];
    }];
}

- (void)complete
{
    [self playSound:@"dialog"];
    [UIView animateWithDuration:0.2 animations:^{
        [self.view setAlpha:0];
    }];
}

- (void)closeGoalView
{
    [self playSound:@"click"];
    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [glv setAlpha:0];
    } completion:^(BOOL finished) {
        [glv removeFromSuperview];
        
        [recorder record];
        levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
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
        [self.delegate gameComplete:self.gameName];
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
