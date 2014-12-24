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

@interface ItemViewController ()
{
    
    UIView* noti;
}
@end

@implementation ItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.lblTitle setText:self.gameName];
    
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
        } completion:^(BOOL finished) {
            // 若全找到，回舞台
            if(isAllFound){
                [self dismissViewControllerAnimated:NO completion:nil];
                [self.delegate gameComplete:self.gameName];
                [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.view.alpha = 0.0;
                } completion:nil];
            }
        }];
    }];
}

@end
