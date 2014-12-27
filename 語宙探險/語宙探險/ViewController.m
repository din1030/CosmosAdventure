//
//  ViewController.m
//  語宙探險
//
//  Created by GoGoDin on 2014/12/10.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "ViewController.h"
#import "FMDatabase.h"
#import "DatabaseManager.h"

@interface ViewController ()
{
    UIStoryboardSegue* goStory;
    UIStoryboardSegue* goStage;
}
- (IBAction)btnPlayClicked:(id)sender;
- (IBAction)btnRestartClicked:(id)sender;
- (IBAction)btnDemoClicked:(id)sender;
- (IBAction)btnStoryClicked:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self playSound:@"bg_music"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnPlayClicked:(id)sender {
    // 繼續遊戲
    [self.audioPlayer setVolume:self.audioPlayer.volume/4];
    // 畫面變黑
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.curtain.alpha = 1.0;
    }];
    // 找出正在進行的 rundown
    FMResultSet *rs = [DatabaseManager executeQuery:@"select r_sid from RUNDOWN_TABLE where r_state=1 order by r_id desc;"];
    
    while ([rs next])
    {
        if([rs intForColumnIndex:0] % 2) {
            // 舞台
            StageViewController* stage = [self.storyboard instantiateViewControllerWithIdentifier:@"stage"];
            stage.delegate = self;
            [self presentViewController:stage animated:NO completion:nil];
        }
        else {
            StoryViewController* story = [self.storyboard instantiateViewControllerWithIdentifier:@"story"];
            story.delegate = self;
            [self presentViewController:story animated:NO completion:nil];
        }
    }
}

- (IBAction)btnRestartClicked:(id)sender {
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* dbPath = [docPath stringByAppendingPathComponent:@"dump.sqlite"];
    NSError *error = nil;
    
    // 刪除已有資料庫
    if (![[NSFileManager defaultManager] removeItemAtPath:dbPath error:&error]) {NSLog(@"Error: %@", error);}
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        // database doesn't exist in your library path... copy it from the bundle
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"dump" ofType:@"sqlite"];
        
        if (![[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:dbPath error:&error]) {
            NSLog(@"Copy DB file Error: %@", error);
        }
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"初始化資料庫成功！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

// 任務完成一半(Demo)
- (IBAction)btnDemoClicked:(id)sender {
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* dbPath = [docPath stringByAppendingPathComponent:@"dump.sqlite"];
    NSError *error = nil;
    
    // 刪除已有資料庫
    if (![[NSFileManager defaultManager] removeItemAtPath:dbPath error:&error]) {NSLog(@"Error: %@", error);}
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        // database doesn't exist in your library path... copy it from the bundle
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"dumpDemo" ofType:@"sqlite"];
        
        if (![[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:dbPath error:&error]) {
            NSLog(@"Copy DB file Error: %@", error);
        }
    }
    
    // 複製照片檔
    NSString* jpgPath = [docPath stringByAppendingPathComponent:@"井井有條.jpg"];
    if (![[NSFileManager defaultManager] removeItemAtPath:jpgPath error:&error]) {NSLog(@"Error: %@", error);}
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"井井有條" ofType:@"jpg"];
    if (![[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:jpgPath error:&error]) {
        NSLog(@"Copy jpg file Error: %@", error);
    }
    jpgPath = [docPath stringByAppendingPathComponent:@"表裡如一.jpg"];
    if (![[NSFileManager defaultManager] removeItemAtPath:jpgPath error:&error]) {NSLog(@"Error: %@", error);}
    sourcePath = [[NSBundle mainBundle] pathForResource:@"表裡如一" ofType:@"jpg"];
    if (![[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:jpgPath error:&error]) {
        NSLog(@"Copy jpg file Error: %@", error);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"前進探險中成功！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

// 所有任務完成
- (IBAction)btnStoryClicked:(id)sender {
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* dbPath = [docPath stringByAppendingPathComponent:@"dump.sqlite"];
    NSError *error = nil;
    
    // 刪除已有資料庫
    if (![[NSFileManager defaultManager] removeItemAtPath:dbPath error:&error]) {NSLog(@"Error: %@", error);}
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        // database doesn't exist in your library path... copy it from the bundle
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"dumpStory" ofType:@"sqlite"];
        
        if (![[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:dbPath error:&error]) {
            NSLog(@"Copy DB file Error: %@", error);
        }
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"進入劇情前成功！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Delegates

- (void)changeViewController:(NSString *)toView
{
    [self dismissViewControllerAnimated:NO completion:nil];
    if([toView isEqualToString:@"stage"]) {
        StageViewController* stage = [self.storyboard instantiateViewControllerWithIdentifier:toView];
        stage.delegate = self;
        [self presentViewController:stage animated:NO completion:nil];
    } else if([toView isEqualToString:@"story"]) {
        StoryViewController* story = [self.storyboard instantiateViewControllerWithIdentifier:toView];
        story.delegate = self;
        NSLog(@"it is story");
        [self presentViewController:story animated:NO completion:nil];
    }
}

- (void)endOfStory
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // 畫面變亮
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.curtain.alpha = 0.0;
        [self.audioPlayer setVolume:self.audioPlayer.volume*4];
    }];
}

// 播放音樂
- (void)playSound:(NSString*)fileName
{
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"]];
    NSError* err;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    if(err) {
        NSLog(@"PlaySound Error: %@", [err localizedDescription]);
    } else {
        [self.audioPlayer setDelegate:self];
        [self.audioPlayer setNumberOfLoops:-1];
        [self.audioPlayer play];
    }
}

@end
