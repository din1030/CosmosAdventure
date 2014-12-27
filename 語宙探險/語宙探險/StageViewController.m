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
#import "DialogView.h"

@interface StageViewController ()
{
    int lastTwinkleCount;
    RundownObject* currentRun;
    RundownObject* nextRun;
    DialogView* stageDialog;
    UIPopoverController* popover;
    UIView* noti;
    UIView* storyCurtain;
    NSTimer* twinkleTimer;
    NSMutableArray* energyButtons;
}
@end

@implementation StageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    stageDialog = [[DialogView alloc] initWithFrame:CGRectMake(252, 505, 772, 243)];
    [stageDialog setHidden:YES];
    [self.view addSubview:stageDialog];
    
    storyCurtain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [storyCurtain setBackgroundColor:[UIColor blackColor]];
    [storyCurtain setAlpha:1.0];
    [self.view addSubview:storyCurtain];
    
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
    lastTwinkleCount = 0;
    energyButtons = [[NSMutableArray alloc] init];
    NSString* qry = [NSString stringWithFormat:@"select * from ENERGY_TABLE where e_sid = %d and e_get = 0;", currentRun.sid];
    FMResultSet *rs3 = [DatabaseManager executeQuery:qry];
    while ([rs3 next])
    {
        UIButton* btnE = [[UIButton alloc] initWithFrame:CGRectMake([rs3 intForColumn:@"e_pointx"], [rs3 intForColumn:@"e_pointy"], 47, 56)];
        [btnE addTarget:self action:@selector(discoverEnergy:) forControlEvents:UIControlEventTouchUpInside];
        [btnE setTag:[rs3 intForColumn:@"e_id"]];
        [energyButtons addObject:btnE];
        [self.view addSubview:btnE];
    }
    
    [self.btnDictionary addTarget:self action:@selector(openDictionary) forControlEvents:UIControlEventTouchUpInside];
    [self.btnApad addTarget:self action:@selector(openApad) forControlEvents:UIControlEventTouchUpInside];
    
    // 進來就先打開任務清單
    //[self performSelector:@selector(openApad) withObject:nil afterDelay:1.0];
    
    // 閃爍能量
    if(energyButtons.count) {
        twinkleTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(twinkling) userInfo:nil repeats:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 畫面變亮
    [UIView animateWithDuration:1.2 animations:^(void) {
        storyCurtain.alpha = 0.0;
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
    [self playSound:@"book"];
    BookViewController* book = [self.storyboard instantiateViewControllerWithIdentifier:@"book"];
    book.delegateOCR = self;
    popover = [[UIPopoverController alloc] initWithContentViewController:book];
    popover.popoverContentSize = CGSizeMake(488, 615);
    [popover presentPopoverFromRect:self.btnDictionary.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionUp animated:YES];
}

// 打開任務清單
- (void)openApad
{
    [self playSound:@"apad"];
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
    
    // 音效
    [self playSound:@"energy"];
    
    [temp setBackgroundImage:[UIImage imageNamed:@"bling.png"] forState:UIControlStateNormal];
    // 放大消失的動畫
    //temp.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [UIView animateWithDuration:1.0f delay:0.5f options:UIViewAnimationOptionCurveLinear animations:^{
        temp.transform = CGAffineTransformMakeScale(3.0, 3.0);
        temp.alpha = 0;
    } completion:^(BOOL finished) {
        [temp removeFromSuperview];
        [energyButtons removeObject:temp];
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
            [twinkleTimer invalidate];
        }
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
        } completion:nil];
    }];
}

#pragma mark - Delegates

// 開啟OCR視窗
- (void)startOCR:(int)did cutword:(NSString *)word fullword:(NSString *)title description:(NSString*)description
{
    [popover dismissPopoverAnimated:YES];
    
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
    [lnoti setText:@"...裝置準備中..."];
    [noti addSubview:lnoti];
    
    [self.view addSubview:noti];
    
    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [noti setFrame:CGRectMake(365, 768-110, 294, 110)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f delay:1.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [noti setFrame:CGRectMake(365, 768, 294, 110)];
        } completion:nil];
    }];
    
    OCRViewController* ocr = [self.storyboard instantiateViewControllerWithIdentifier:@"ocr"];
    ocr.delegate = self;
    ocr.sid = currentRun.sid;
    ocr.did = did;
    ocr.correctWord = word;
    ocr.fullWord = title;
    ocr.ddescription = description;
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
        [stageDialog.lblDialog setText:@"只要找幾個小道具，\r就能用「聚沙成塔」魔法囉！"];
    } else if([name isEqualToString:@"用OK繃補好UFO的破洞"]) {
        [stageDialog.lblDialog setText:@"這個任務可以使用「言而有信」魔法來達成！"];
    }
    
    [stageDialog.imgCharacter setImage:[UIImage imageNamed:@"c_magic.png"]];
    [stageDialog setHidden:NO];
    
    [UIView animateWithDuration:0.3 delay:2.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        storyCurtain.alpha = 1.0;
    } completion:^(BOOL finished) {
        [stageDialog setHidden:YES];
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
    [self dismissViewControllerAnimated:NO completion:nil];
    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
        // 畫面變亮
        storyCurtain.alpha = 0.0;
    } completion:^(BOOL finished) {
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
        [lnoti setText:@"任務完成！"];
        [noti addSubview:lnoti];
        
        [self.view addSubview:noti];
        
        [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            [noti setFrame:CGRectMake(365, 768-110, 294, 110)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3f delay:1.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [noti setFrame:CGRectMake(365, 768, 294, 110)];
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
    
    if(nextRun) {
        qryUpd = [NSString stringWithFormat:@"update RUNDOWN_TABLE set r_state = 1 where r_id = %d", nextRun.rid];
        [DatabaseManager executeModifySQL:qryUpd];
        
        // 切換到故事view
        [self.delegate changeViewController:@"story"];
    } else {
        [self.delegate endOfStory];
    }
}

- (void)repairedPage:(NSString *)title description:(NSString *)description cutword:(NSString *)cutword
{
    if(twinkleTimer.valid) [twinkleTimer setFireDate:[NSDate distantFuture]];
    [self dismissViewControllerAnimated:NO completion:nil];
    [self playSound:@"magic"];
    
    int cutIndex = [title rangeOfString:cutword].location;
    NSString* cutTitle = [title stringByReplacingCharactersInRange:NSMakeRange(cutIndex,1) withString:@"＋"];
    [self.lblPageTitle setText:cutTitle];
    [self.lblPageDetail setText:description];
    [self.lblCutWord setText:cutword];
    
    [self.imgDirt setFrame:CGRectMake((cutIndex+1)*80 + 268, 198, 90, 90)];
    [self.imgRepair setFrame:CGRectMake((cutIndex+1)*80 + 268, 198, 90, 90)];
    [self.lblCutWord setFrame:CGRectMake((cutIndex+1)*80 + 268, 198, 90, 90)];
    self.imgRepair.alpha = 0;
    self.lblCutWord.alpha = 0;
    self.imgRepair.transform = CGAffineTransformMakeScale(3.0, 3.0);
    self.lblCutWord.transform = CGAffineTransformMakeScale(3.0, 3.0);
    
    // 顯示書頁補丁動畫
    [self.pageView setHidden:NO];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.pageView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f delay:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.imgRepair setAlpha:1];
            [self.lblCutWord setAlpha:1];
            self.imgRepair.transform = CGAffineTransformMakeScale(0.8, 0.8);
            self.lblCutWord.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } completion:^(BOOL finished) {
            self.imgRepair.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.lblCutWord.transform = CGAffineTransformMakeScale(1.0, 1.0);
            
            [stageDialog setHidden:NO];
            [stageDialog setAlpha:0];
            [UIView animateWithDuration:0.3f delay:1.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
                [stageDialog.lblDialog setText:@"太好了！\r補好字典的其中一頁囉～"];
                [stageDialog.imgCharacter setImage:[UIImage imageNamed:@"c_magic.png"]];
                [stageDialog setAlpha:1];
            } completion:^(BOOL finished) {
                UITapGestureRecognizer *tapGestureRecognizer;
                tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePage)];
                tapGestureRecognizer.numberOfTapsRequired = 1;
                [self.pageView addGestureRecognizer:tapGestureRecognizer];
            }];
        }];
    }];
}

- (void)closePage
{
    [self playSound:@"dialog"];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.pageView.alpha = 0;
    } completion:^(BOOL finished) {
        [stageDialog setHidden:YES];
        [self.pageView setHidden:YES];
        if(twinkleTimer.valid) [twinkleTimer setFireDate:[NSDate date]];
    }];
}

#pragma mark - Animation

- (void)twinkling
{
    // 每隔一陣子，閃爍畫面上的能量
    if(lastTwinkleCount >= energyButtons.count) {
        lastTwinkleCount = 0;
    }
    UIButton* temp = energyButtons[lastTwinkleCount];
    temp.alpha = 0;
    [temp setBackgroundImage:[UIImage imageNamed:@"bling.png"] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        temp.alpha = 0.9;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1f delay:0.1f options:UIViewAnimationOptionCurveEaseIn animations:^{
            temp.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                temp.alpha = 0.9;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3f delay:0.2f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    temp.alpha = 0;
                } completion:^(BOOL finished) {
                    temp.alpha = 1;
                    [temp setBackgroundImage:nil forState:UIControlStateNormal];
                }];
            }];
        }];
    }];
    
    lastTwinkleCount ++;
}

#pragma mark - AVAudioPlayer Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
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
