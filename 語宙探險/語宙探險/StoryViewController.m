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

@interface StoryViewController ()
{
    RundownObject* currentRun;
    RundownObject* nextRun;
    
    NSMutableArray* packages;
    NSMutableArray* characters;
}

@end

@implementation StoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 準備劇情
    [self prepareStory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareStory
{
    [self.story_character setHidden:YES];
    [self.story_dialog setHidden:YES];
    [self.story_lines setHidden:YES];
    [self.story_menu setHidden:YES];
    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.curtain.alpha = 0.0;
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
        [self.story_character setHidden:YES];
        [self.story_dialog setHidden:YES];
        [self.story_lines setHidden:YES];
        [self.view addGestureRecognizer:tapGestureRecognizer];
    } else if (currentRun.type == 2) {
        [self.story_animate setImage:[UIImage imageNamed:[NSString stringWithFormat:@"stage%d.png", currentRun.sid/10]]];
        [self.story_character setImage:[UIImage imageNamed:characters[0]]];
        [self.story_character setHidden:NO];
        [self.story_dialog setImage:[UIImage imageNamed:@"dialog.png"]];
        [self.story_dialog setHidden:NO];
        [self.story_lines setText:packages[0]];
        [self.story_lines setHidden:NO];
        [self.view addGestureRecognizer:tapGestureRecognizer];
    } else if (currentRun.type == 3) {
        [self.story_animate setImage:[UIImage imageNamed:[NSString stringWithFormat:@"stage%d.png", currentRun.sid/10]]];
        // 顯示選項
        [self.btnOption1 setTitle:packages[0] forState:UIControlStateNormal];
        [self.btnOption1 setTag:[characters[0] integerValue]];
        [self.btnOption1 addTarget:self action:@selector(btnOptionClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnOption2 setTitle:packages[1] forState:UIControlStateNormal];
        [self.btnOption2 setTag:[characters[1] integerValue]];
        [self.btnOption2 addTarget:self action:@selector(btnOptionClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnOption3 setTitle:packages[2] forState:UIControlStateNormal];
        [self.btnOption3 setTag:[characters[2] integerValue]];
        [self.btnOption3 addTarget:self action:@selector(btnOptionClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.story_menu setHidden:NO];
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
                    [self.story_animate setImage:[UIImage imageNamed:packages[_current_count]]];
                    [self.story_animate setAlpha:1.0];
                } completion:^(BOOL finished) {
                    _current_count ++;
                }];
            }];
        }
        else if(currentRun.type == 2) {
            // 切換下一句對話
            [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.story_lines setAlpha:0.0];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3 delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.story_lines setText:packages[_current_count]];
                    [self.story_lines setAlpha:1.0];
                } completion:^(BOOL finished) {
                    _current_count ++;
                }];
            }];
        } else if(currentRun.type == 3) {
            
        }
    } else {
        // 完成 rundown, 更新狀態
        [self updateRundownState];
        // 畫面變黑
        [UIView animateWithDuration:0.3 animations:^(void) {
            self.curtain.alpha = 1.0;
        }];
        
        if(nextRun) {
            // 下一個 rundown
            if(nextRun.sid == currentRun.sid) {
                // 重新跑一遍 story
                [self performSelector:@selector(prepareStory) withObject:nil afterDelay:0.3];
            } else {
                // 告訴主頁，叫出舞台view
                [self dismissViewControllerAnimated:NO completion:nil];
                [self.delegate changeViewController:@"stage"];
            }
        } else {
            // 最後一個，回主畫面
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
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
- (void)showAlertDialog {
    UITapGestureRecognizer *tapClose;
    tapClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAlertDialog)];
    tapClose.numberOfTapsRequired = 1;
    [self.story_character setImage:[UIImage imageNamed:@"c_shock.png"]];
    [self.story_character setHidden:NO];
    [self.story_dialog setImage:[UIImage imageNamed:@"dialog.png"]];
    [self.story_dialog setHidden:NO];
    [self.story_lines setText:@"這時候用這句好像不太適合耶！？"];
    [self.story_lines setHidden:NO];
    [self.view addGestureRecognizer:tapClose];
}

- (void)closeAlertDialog {
    [self.story_character setHidden:YES];
    [self.story_dialog setHidden:YES];
    [self.story_lines setHidden:YES];
    [self.story_menu setHidden:NO];
}

- (void)btnOptionClicked:(id)sender {
    if([(UIButton*)sender tag] == 1) {
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
        // 對話：選錯了喔
        [self.story_menu setHidden:YES];
        [self showAlertDialog];
    }
}

#pragma mark - Game Delegate

- (void)gameComplete
{
    // 遊戲關卡完成，進行下一個 rundown
    [self updateRundownState];
    
    // 畫面變黑
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.curtain.alpha = 1.0;
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
