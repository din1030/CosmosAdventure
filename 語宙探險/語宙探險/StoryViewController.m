//
//  StoryViewController.m
//  語宙探險
//
//  Created by GoGoDin on 2014/12/14.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "StoryViewController.h"
#import "FMDatabase.h"
#import "DatabaseManager.h"
#import "RundownObject.h"
#import "DialogView.h"
#import "QuizView.h"

@interface StoryViewController ()
{
    RundownObject* currentRun;
    RundownObject* nextRun;
    
    DialogView* storyDialog;
    QuizView* storyQuiz;
    UIView* storyCurtain;
    NSMutableArray* packages;
    NSMutableArray* characters;
}

@end

@implementation StoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    storyCurtain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [storyCurtain setBackgroundColor:[UIColor blackColor]];
    [storyCurtain setAlpha:1.0];
    [self.view addSubview:storyCurtain];
    
    // 準備劇情
    [self prepareStory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareStory
{
    storyDialog = [[DialogView alloc] initWithFrame:CGRectMake(252, 505, 772, 243)];
    [storyDialog setHidden:YES];
    [self.view addSubview:storyDialog];
    
    storyQuiz = [[QuizView alloc] initWithFrame:CGRectMake(252, 538, 520, 174)];
    [storyQuiz setHidden:YES];
    [self.view addSubview:storyQuiz];
    
    [self.view bringSubviewToFront:storyCurtain];
    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        storyCurtain.alpha = 0.0;
    } completion:nil];
    
    // 點擊手勢
    UITapGestureRecognizer *tapGestureRecognizer;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeAnimate:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    
    // 找出正在進行的 rundown
    currentRun = nil;
    FMResultSet *rs = [DatabaseManager executeQuery:@"select * from RUNDOWN_TABLE where r_state = 1 order by r_id limit 1"];
    while ([rs next])
    {
        currentRun = [RundownObject run:[rs intForColumn:@"r_id"]
                                    sid:[rs intForColumn:@"r_sid"]
                                   note:[rs stringForColumn:@"r_note"]
                                   type:[rs intForColumn:@"r_type"]
                                  state:[rs intForColumn:@"r_state"]
                                   date:[rs stringForColumn:@"r_date"]];
    }
    // 找出下一個 rundown
    nextRun = nil;
    FMResultSet *rs2 = [DatabaseManager executeQuery:@"select * from RUNDOWN_TABLE where r_state = 0 order by r_id limit 1"];
    while ([rs2 next])
    {
        nextRun = [RundownObject run:[rs2 intForColumn:@"r_id"]
                                 sid:[rs2 intForColumn:@"r_sid"]
                                note:[rs2 stringForColumn:@"r_note"]
                                type:[rs2 intForColumn:@"r_type"]
                               state:[rs2 intForColumn:@"r_state"]
                                date:[rs2 stringForColumn:@"r_date"]];
    }
    
    // 取得 rundown package
    packages = [[NSMutableArray alloc] init];
    characters = [[NSMutableArray alloc] init];
    NSString* qry = [NSString stringWithFormat:@"select * from PACKAGE_TABLE where p_rid = %d order by p_id", currentRun.rid];
    FMResultSet *rs3 = [DatabaseManager executeQuery:qry];
    while ([rs3 next])
    {
        [packages addObject:[rs3 stringForColumn:@"p_content"]];
        if([rs3 stringForColumn:@"p_character"])
            [characters addObject:[rs3 stringForColumn:@"p_character"]];
    }
    
    // 第一張圖片
    _current_count = 1;
    if(currentRun.type == 1) {
        [self.story_animate setImage:[UIImage imageNamed:packages[0]]];
        [storyDialog setHidden:YES];
        [storyQuiz setHidden:YES];
        [self.view addGestureRecognizer:tapGestureRecognizer];
    } else if (currentRun.type == 2) {
        [self.story_animate setImage:[UIImage imageNamed:[NSString stringWithFormat:@"stage%d.png", currentRun.sid/10]]];
        [storyDialog.imgCharacter setImage:[UIImage imageNamed:characters[0]]];
        [storyDialog.lblDialog setText:packages[0]];
        [storyDialog setHidden:NO];
        [storyQuiz setHidden:YES];
        [self.view addGestureRecognizer:tapGestureRecognizer];
    } else if (currentRun.type == 3) {
        [self.story_animate setImage:[UIImage imageNamed:[NSString stringWithFormat:@"stage%d.png", currentRun.sid/10]]];
        [storyDialog.imgCharacter setImage:[UIImage imageNamed:@"c_magic.png"]];
        [storyDialog.lblDialog setText:@""];
        [storyDialog setHidden:NO];
        
        // 顯示選項
        [storyQuiz setOptions:packages tag:characters];
        [storyQuiz.btnOptionL addTarget:self action:@selector(checkAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [storyQuiz.btnOptionM addTarget:self action:@selector(checkAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [storyQuiz.btnOptionR addTarget:self action:@selector(checkAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [storyQuiz setHidden:NO];
    }
}

// for 前情提要的 tap gesture event handler
- (void)changeAnimate:(UIGestureRecognizer *)recognizer {
    if(_current_count < packages.count) {
        if(currentRun.type == 1) {
            // 切換下一張圖片
            [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.story_animate setAlpha:0.0];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    if([packages[_current_count] isEqualToString:@"story1_4.png"])
                        [self playSound:@"alien"];
                    if([packages[_current_count] isEqualToString:@"story1_5.png"])
                        [self playSound:@"falling"];
                    if([packages[_current_count] isEqualToString:@"story1_8.png"])
                        [self playSound:@"correct"];
                    if([packages[_current_count] isEqualToString:@"story1_10.png"])
                        [self playSound:@"chorus"];
                    if([packages[_current_count] isEqualToString:@"story1_11.png"])
                        [self playSound:@"ufomove"];
                    if([packages[_current_count] isEqualToString:@"story1_12.png"])
                        [self playSound:@"fallingdown"];
                    [self.story_animate setImage:[UIImage imageNamed:packages[_current_count]]];
                    [self.story_animate setAlpha:1.0];
                    _current_count ++;
                } completion:^(BOOL finished) {
                }];
            }];
        }
        else if(currentRun.type == 2) {
            // 切換下一句對話
            [self playSound:@"dialog"];
            [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                [storyDialog.lblDialog setAlpha:0.0];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3 delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [storyDialog.lblDialog setText:packages[_current_count]];
                    [storyDialog.lblDialog setAlpha:1.0];
                    _current_count ++;
                } completion:^(BOOL finished) {
                }];
            }];
        } else if(currentRun.type == 3) {
            
        }
    } else {
        if(currentRun.type == 2) {
            // 還是要有結束的音效
            [self playSound:@"dialog"];
            [storyDialog setHidden:YES];
        }
        
        // 完成 rundown, 更新狀態
        NSLog(@"完成 rundown, 更新狀態");
        [self updateRundownState];
        // 畫面變黑
        [UIView animateWithDuration:0.3 animations:^(void) {
            storyCurtain.alpha = 1.0;
        }];
        
        if(nextRun) {
            // 下一個 rundown
            if(nextRun.sid == currentRun.sid) {
                // 重新跑一遍 story
                [self performSelector:@selector(prepareStory) withObject:nil afterDelay:0.3];
            } else {
                // 告訴主頁，叫出舞台view
                [self.delegate changeViewController:@"stage"];
            }
        } else {
            // 最後一個，回主畫面
            UILabel* tbc = [[UILabel alloc] initWithFrame:CGRectMake(770, 640, 140, 60)];
            [tbc setFont:[UIFont italicSystemFontOfSize:50]];
            [tbc setTextColor:[UIColor whiteColor]];
            [tbc setText:@"待續..."];
            [tbc setAlpha:0];
            [self.view addSubview:tbc];
            
            [UIView animateWithDuration:0.3 delay:1.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                tbc.alpha = 1.0;
            } completion:^(BOOL finished){
                [self performSelector:@selector(backToMain) withObject:nil afterDelay:3.0];
            }];
        }
    }
}

- (void)backToMain
{
    [self.delegate endOfStory];
}

// 更新資料庫
- (void)updateRundownState
{
    NSString* qry = [NSString stringWithFormat:@"update RUNDOWN_TABLE set r_state = 2 where r_id = %d", currentRun.rid];
    [DatabaseManager executeModifySQL:qry];
    
    if(nextRun) {
        qry = [NSString stringWithFormat:@"update RUNDOWN_TABLE set r_state = 1 where r_id = %d", nextRun.rid];
        [DatabaseManager executeModifySQL:qry];
    }
}

// 選錯成語時的對話
- (void)showAlertDialog
{
    UITapGestureRecognizer *tapClose;
    tapClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAlertDialog)];
    tapClose.numberOfTapsRequired = 1;
    [storyDialog.imgCharacter setImage:[UIImage imageNamed:@"c_shock.png"]];
    [storyDialog.lblDialog setText:@"這時候用這句好像不太適合耶！？"];
    [storyQuiz setHidden:YES];
    [self.view addGestureRecognizer:tapClose];
}

- (void)closeAlertDialog
{
    [storyDialog.imgCharacter setImage:[UIImage imageNamed:@"c_magic.png"]];
    [storyDialog.lblDialog setText:@""];
    [storyQuiz setHidden:NO];
}

- (void)checkAnswer:(id)sender
{
    [storyQuiz setHidden:YES];
    if([(UIButton*)sender tag] == 1) {
        [self playSound:@"correct"];
        // 開啟小遊戲視窗
        if(currentRun.rid == 5) {
            // 劇情關卡一之一：配對物品
            MatchViewController* mtch = [self.storyboard instantiateViewControllerWithIdentifier:@"match"];
            mtch.delegate = self;
            [self presentViewController:mtch animated:NO completion:nil];
        } else if(currentRun.rid == 7) {
            // 劇情關卡一之二：瞄準紅星
            AimViewController* aim = [self.storyboard instantiateViewControllerWithIdentifier:@"aim"];
            aim.delegate = self;
            [self presentViewController:aim animated:NO completion:nil];
        }
    } else {
        [self playSound:@"error"];
        [self showAlertDialog];
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

#pragma mark - Game Delegate

- (void)gameComplete
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // 遊戲關卡完成，進行下一個 rundown
    [self updateRundownState];
    
    // 畫面變黑
    [UIView animateWithDuration:0.3 animations:^(void) {
        storyCurtain.alpha = 1.0;
    }];
    
    if(nextRun) {
        if(nextRun.sid == currentRun.sid) {
            [self performSelector:@selector(prepareStory) withObject:nil afterDelay:0.3];
        } else {
            [self.delegate changeViewController:@"stage"];
        }
    } else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
