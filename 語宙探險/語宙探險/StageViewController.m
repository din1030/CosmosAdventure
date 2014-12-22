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
    [self.stage_bg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"stage%d.png", currentRun.sid]]];
    
    // 擺放能量
    NSString* qry = [NSString stringWithFormat:@"select * from ENERGY_TABLE where e_sid = %d and e_get = 0;", currentRun.sid];
    FMResultSet *rs3 = [DatabaseManager executeQuery:qry];
    while ([rs3 next])
    {
        UIButton* btnE = [[UIButton alloc] initWithFrame:CGRectMake([rs3 intForColumn:@"e_pointx"], [rs3 intForColumn:@"e_pointy"], 47, 56)];
        //[btnE setBackgroundImage:[UIImage imageNamed:@"bling.png"] forState:UIControlStateNormal];
        [btnE addTarget:self action:@selector(discoverEnergy:) forControlEvents:UIControlEventTouchUpInside];
        //[btnE setAlpha:0.0]; // 按得到嗎？？
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
    
    // 更新資料庫
    NSString* qry = [NSString stringWithFormat:@"update ENERGY_TABLE set e_get = 1 where e_id = %ld", (long)temp.tag];
    [DatabaseManager executeModifySQL:qry];
}

#pragma mark - Delegates

// 開啟OCR視窗
- (void)startOCR:(int)did word:(NSString *)word
{
    [popover dismissPopoverAnimated:YES];
    
    OCRViewController* ocr = [self.storyboard instantiateViewControllerWithIdentifier:@"ocr"];
    ocr.correctWord = word;
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
    
    ////////////////////////////////////
}

@end
