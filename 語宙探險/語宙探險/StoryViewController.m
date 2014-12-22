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
    
    // 點擊手勢
    UITapGestureRecognizer *tapGestureRecognizer;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeAnimate:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    // 準備劇情
    [self prepareStory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareStory
{
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.curtain.alpha = 0.0;
    }];
    
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
    } else if (currentRun.type == 2) {
        [self.story_animate setImage:[UIImage imageNamed:[NSString stringWithFormat:@"stage%d.png", currentRun.sid]]];
        [self.story_character setImage:[UIImage imageNamed:characters[0]]];
        [self.story_character setHidden:NO];
        [self.story_dialog setImage:[UIImage imageNamed:@"dialog.png"]];
        [self.story_dialog setHidden:NO];
        [self.story_lines setText:packages[0]];
        [self.story_lines setHidden:NO];
    } else if (currentRun.type == 3) {
        [self.story_animate setImage:[UIImage imageNamed:[NSString stringWithFormat:@"stage%d.png", currentRun.sid]]];
        // 顯示選項
        
        
    }
}

// for 前情提要的 tap gesture event handler
- (void)changeAnimate:(UIGestureRecognizer *)recognizer {
    NSLog(@"_current_count:%d, packages.count %lu",_current_count,(unsigned long)packages.count);
    if(_current_count < packages.count) {
        if(currentRun.type == 1) {
            // 切換下一張圖片
            [UIView animateWithDuration:0.5 animations:^(void) {
                [self.story_animate setAlpha:0.0];
            }];
            
            [UIView animateWithDuration:0.3 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
                [self.story_animate setImage:[UIImage imageNamed:packages[_current_count]]];
                [self.story_animate setAlpha:1.0];

            } completion:nil];
        }
        else if(currentRun.type == 2) {
            // 切換下一句對話
            [UIView animateWithDuration:0.3 animations:^(void) {
                [self.story_lines setAlpha:0.0];
            }];
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
                [self.story_lines setText:packages[_current_count]];
                [self.story_lines setAlpha:1.0];
                
            } completion:nil];
        } else if(currentRun.type == 3) {
            // 檢查是否選到正確答案
            
            // 正確答案，叫出Game視窗
            
            // Game 完成後回來重新讀取 rundown
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
                [self.delegate changeViewController:@"stage"];
            }
        } else {
            // 最後一個，回主畫面
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    _current_count ++;
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

@end
