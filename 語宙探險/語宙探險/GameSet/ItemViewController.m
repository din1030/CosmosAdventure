//
//  ItemViewController.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/24.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "ItemViewController.h"
#import "FMDatabase.h"
#import "DatabaseManager.h"
#import "DialogView.h"
#import "GoalView.h"

@interface ItemViewController ()
{
    UIView* noti;
    GoalView* glv;
    DialogView* dlg;
}
@end

@implementation ItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    glv = [[GoalView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [glv.lblTitle setText:@"【聚沙成塔】"];
    [glv.lblDetail setText:self.gameName];
    [glv.btnConfirm addTarget:self action:@selector(closeGoalView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:glv];
    
    dlg = [[DialogView alloc] initWithFrame:CGRectMake(252, 505, 772, 243)];
    [dlg setHidden:YES];
    [dlg.lblDialog setText:@"【聚沙成塔】魔法成功！"];
    [dlg.imgCharacter setImage:[UIImage imageNamed:@"c_magic.png"]];
    [self.view addSubview:dlg];
    
    // 擺放道具
    NSString* qry = [NSString stringWithFormat:@"select t_id, t_mid, t_pointx, t_pointy, t_name, t_get from ITEM_TABLE, MISSION_TABLE where t_mid = m_id and m_description = '%@' and t_get = 0;", self.gameName];
    FMResultSet *rs = [DatabaseManager executeQuery:qry];
    while ([rs next])
    {
        UIButton* btnE = [[UIButton alloc] initWithFrame:CGRectMake([rs intForColumn:@"t_pointx"], [rs intForColumn:@"t_pointy"], 33, 65)];
        [btnE setTitle:[rs stringForColumn:@"t_name"] forState:UIControlStateDisabled];
        [btnE addTarget:self action:@selector(discoverItem:) forControlEvents:UIControlEventTouchUpInside];
        [btnE setTag:[rs intForColumn:@"t_id"]];
        [self.view addSubview:btnE];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 發現道具
- (void)discoverItem:(id)sender
{
    [self playSound:@"item"];
    
    UIButton* temp = (UIButton*)sender;
    NSString* itemName = [temp titleForState:UIControlStateDisabled];
    [temp setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", itemName]] forState:UIControlStateNormal];
    // 放大消失的動畫
    temp.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [UIView animateWithDuration:1.0f delay:0.5f options:UIViewAnimationOptionCurveLinear animations:^{
        temp.transform = CGAffineTransformMakeScale(3.0, 3.0);
        temp.alpha = 0;
    } completion:^(BOOL finished) {
        [temp removeFromSuperview];
    }];
    
    // 更新道具資料庫
    NSString* qry = [NSString stringWithFormat:@"update ITEM_TABLE set t_get = 1 where t_id = %ld", (long)temp.tag];
    [DatabaseManager executeModifySQL:qry];
    
    NSString* noticeText = [NSString stringWithFormat:@"發現一個%@！", itemName];
    
    // 是否全部都已找到
    BOOL isAllFound = NO;
    qry = [NSString stringWithFormat:@"select count(t_id) from ITEM_TABLE, MISSION_TABLE where t_mid = m_id and m_description = '%@' and t_get = 0;", self.gameName];
    FMResultSet *rs = [DatabaseManager executeQuery:qry];
    while ([rs next])
    {
        if([rs intForColumnIndex:0] == 0) {
            isAllFound = YES;
            noticeText = @"道具全部收集完成！";
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
        } completion:^(BOOL finished) {
            // 若全找到，回舞台
            if(isAllFound){
                [self playSound:@"magic"];
            }
        }];
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
