//
//  StageViewController.m
//  語宙探險
//
//  Created by GoGoDin on 2014/12/10.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "StageViewController.h"
#import "FMDatabase.h"
#import "DatabaseManager.h"
#import "RundownObject.h"
#import "OCRViewController.h"

@interface StageViewController ()
{
    RundownObject* currentRun;
    RundownObject* nextRun;
    UIPopoverController* popover;
    UIView* noti;
}
@end

@implementation StageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 找出正在進行的 rundown
    FMResultSet *rs = [DatabaseManager executeQuery:@"select * from RUNDOWN_TABLE where r_state = 1;"];
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

    // 場景圖片
    [self.stage_bg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"stage%d.png", currentRun.sid/10]]];
    
    // 擺放能量
    NSString* qry = [NSString stringWithFormat:@"select * from ENERGY_TABLE where e_sid = %d and e_get = 0;", currentRun.sid];
    FMResultSet *rs3 = [DatabaseManager executeQuery:qry];
    while ([rs3 next])
    {
        UIButton* btnE = [[UIButton alloc] initWithFrame:CGRectMake([rs3 intForColumn:@"e_pointx"], [rs3 intForColumn:@"e_pointy"], 47, 56)];
        [btnE addTarget:self action:@selector(discoverEnergy:) forControlEvents:UIControlEventTouchUpInside];
        [btnE setTag:[rs3 intForColumn:@"e_id"]];
        [self.view addSubview:btnE];
    }
    
    [self.btnDictionary addTarget:self action:@selector(openDictionary) forControlEvents:UIControlEventTouchUpInside];
    [self.btnApad addTarget:self action:@selector(openApad) forControlEvents:UIControlEventTouchUpInside];
    
    // 進來就先打開任務清單
    [self performSelector:@selector(openApad) withObject:nil afterDelay:1.0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 畫面變亮
    [UIView animateWithDuration:1.2 animations:^(void) {
        self.curtain.alpha = 0.0;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Local

// 打開成語字典
- (void)openDictionary
{
    BookViewController* book = [self.storyboard instantiateViewControllerWithIdentifier:@"book"];
    book.delegateOCR = self;
    popover = [[UIPopoverController alloc] initWithContentViewController:book];
    popover.popoverContentSize = CGSizeMake(488, 615);
    [popover presentPopoverFromRect:self.btnDictionary.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionUp animated:YES];
}

// 打開任務清單
- (void)openApad
{
    ApadViewController* apad = [self.storyboard instantiateViewControllerWithIdentifier:@"apad"];
    apad.delegate = self;
    apad.sid = currentRun.sid;
    popover = [[UIPopoverController alloc] initWithContentViewController:apad];
    popover.popoverContentSize = CGSizeMake(488, 615);
    [popover presentPopoverFromRect:self.btnApad.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionUp animated:YES];
}

// 發現能量
- (void)discoverEnergy:(id)sender
{
    UIButton* temp = (UIButton*)sender;
    [temp setBackgroundImage:[UIImage imageNamed:@"bling.png"] forState:UIControlStateNormal];
    // 放大消失的動畫
    temp.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [UIView animateWithDuration:1.0f delay:0.5f options:UIViewAnimationOptionCurveLinear animations:^{
        temp.transform = CGAffineTransformMakeScale(3.0, 3.0);
        temp.alpha = 0;
    } completion:^(BOOL finished) {
        [temp removeFromSuperview];
    }];
    
    // 更新能量資料庫
    NSString* qry = [NSString stringWithFormat:@"update ENERGY_TABLE set e_get = 1 where e_id = %ld", (long)temp.tag];
    [DatabaseManager executeModifySQL:qry];
    
    NSString* noticeText = @"發現一個魔法能量";
    
    // 是否全部都已找到
    qry = [NSString stringWithFormat:@"select count(e_id) from ENERGY_TABLE where e_sid = %d and e_get = 0;", currentRun.sid];
    FMResultSet *rs = [DatabaseManager executeQuery:qry];
    while ([rs next])
    {
        if([rs intForColumnIndex:0] == 0) {
            noticeText = @"能量全部收集完成！";
        }
    }
    
    // 彈出訊息視窗
    if(noti) {
        [noti removeFromSuperview];
    }
    noti = [[UIView alloc] initWithFrame:CGRectMake(227, 768, 570, 60)];
    
    [noti setAlpha:0.8];
    [noti setBackgroundColor:[UIColor blackColor]];
    
    UILabel* lnoti = [[UILabel alloc] initWithFrame:CGRectMake(41, 8, 488, 33)];
    [lnoti setTextColor:[UIColor whiteColor]];
    [lnoti setFont:[UIFont systemFontOfSize:24.0]];
    [lnoti setTextAlignment:NSTextAlignmentCenter];
    [lnoti setText:noticeText];
    [noti addSubview:lnoti];
    
    [self.view addSubview:noti];
    
    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [noti setFrame:CGRectMake(227, 768-70, 570, 60)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f delay:2.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [noti setFrame:CGRectMake(227, 768, 570, 60)];
        } completion:nil];
    }];
}

#pragma mark - Delegates

// 開啟OCR視窗
- (void)startOCR:(int)did cutword:(NSString *)word fullword:(NSString *)title
{
    [popover dismissPopoverAnimated:YES];
    
    // 彈出訊息視窗
    if(noti) {
        [noti removeFromSuperview];
    }
    noti = [[UIView alloc] initWithFrame:CGRectMake(227, 768, 570, 60)];
    
    [noti setAlpha:0.8];
    [noti setBackgroundColor:[UIColor blackColor]];
    
    UILabel* lnoti = [[UILabel alloc] initWithFrame:CGRectMake(41, 8, 488, 33)];
    [lnoti setTextColor:[UIColor whiteColor]];
    [lnoti setFont:[UIFont systemFontOfSize:24.0]];
    [lnoti setTextAlignment:NSTextAlignmentCenter];
    [lnoti setText:@"...裝置準備中..."];
    [noti addSubview:lnoti];
    
    [self.view addSubview:noti];
    
    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [noti setFrame:CGRectMake(227, 768-70, 570, 60)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f delay:2.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [noti setFrame:CGRectMake(227, 768, 570, 60)];
        } completion:nil];
    }];
    
    OCRViewController* ocr = [self.storyboard instantiateViewControllerWithIdentifier:@"ocr"];
    ocr.sid = currentRun.sid;
    ocr.correctWord = word;
    ocr.fullWord = title;
    [self presentViewController:ocr animated:NO completion:nil];
}

// 關閉Apad, 開啟字典
- (void)directToDictionary
{
    [popover dismissPopoverAnimated:YES];
    
    [self openDictionary];
}

// 關閉Apad, 開啟遊戲
- (void)directToGame:(NSString *)name
{
    [popover dismissPopoverAnimated:YES];
        if([name isEqualToString:@"找到五個電池作為儲備能源"]) {
            [self.stage_lines setText:@"只要再找幾個小道具，\r就能用「聚沙成塔」魔法囉！"];
        } else if([name isEqualToString:@"用OK繃補好UFO的破洞"]) {
            [self.stage_lines setText:@"這個任務可以使用「言之有物」魔法來達成！"];
        }
        [self.stage_lines setHidden:NO];
        [self.stage_dialog setHidden:NO];
        [self.stage_character setImage:[UIImage imageNamed:@"c_smile.png"]];
        [self.stage_character setHidden:NO];
        
        [UIView animateWithDuration:0.3 delay:3.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.curtain.alpha = 1.0;
        } completion:^(BOOL finished) {
            [self.stage_lines setHidden:YES];
            [self.stage_dialog setHidden:YES];
            [self.stage_character setHidden:YES];
        }];
    
    [self performSelector:@selector(presentGameView:) withObject:name afterDelay:2.5];
}

- (void)presentGameView:(NSString *)name
{
    if([name isEqualToString:@"找到五個電池作為儲備能源"]) {
        ItemViewController* itm = [self.storyboard instantiateViewControllerWithIdentifier:@"item"];
        itm.delegate = self;
        itm.gameName = name;
        [self presentViewController:itm animated:NO completion:nil];
    } else if([name isEqualToString:@"用OK繃補好UFO的破洞"]) {
        OKbonViewController* okb = [self.storyboard instantiateViewControllerWithIdentifier:@"okbon"];
        okb.delegate = self;
        okb.gameName = name;
        [self presentViewController:okb animated:NO completion:nil];
    }
}

- (void)gameComplete:(NSString *)name
{
    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
        // 畫面變亮
        self.curtain.alpha = 0.0;
    } completion:^(BOOL finished) {
        // 彈出訊息視窗
        if(noti) {
            [noti removeFromSuperview];
        }
        noti = [[UIView alloc] initWithFrame:CGRectMake(227, 768, 570, 60)];
        
        [noti setAlpha:0.8];
        [noti setBackgroundColor:[UIColor blackColor]];
        
        UILabel* lnoti = [[UILabel alloc] initWithFrame:CGRectMake(41, 8, 488, 33)];
        [lnoti setTextColor:[UIColor whiteColor]];
        [lnoti setFont:[UIFont systemFontOfSize:24.0]];
        [lnoti setTextAlignment:NSTextAlignmentCenter];
        [lnoti setText:[NSString stringWithFormat:@"%@完成！", name]];
        [noti addSubview:lnoti];
        
        [self.view addSubview:noti];
        
        [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            [noti setFrame:CGRectMake(227, 768-70, 570, 60)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3f delay:2.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [noti setFrame:CGRectMake(227, 768, 570, 60)];
            } completion:nil];
        }];
    }];
    
    // 更新任務資料庫
    NSString* qry = [NSString stringWithFormat:@"update MISSION_TABLE set m_complete = 1 where m_description = '%@'", name];
    [DatabaseManager executeModifySQL:qry];
}

- (void)directToStory
{
    NSString* qryUpd = [NSString stringWithFormat:@"update RUNDOWN_TABLE set r_state = 2 where r_id = %d", currentRun.rid];
    [DatabaseManager executeModifySQL:qryUpd];
    NSLog(@"directToStory");
    if(nextRun) {
        qryUpd = [NSString stringWithFormat:@"update RUNDOWN_TABLE set r_state = 1 where r_id = %d", nextRun.rid];
        [DatabaseManager executeModifySQL:qryUpd];
        NSLog(@"切換到故事view");
        // 切換到故事view
        [self.delegate changeViewController:@"story"];
    }
}

@end
