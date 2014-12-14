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

@interface StageViewController ()

@end

@implementation StageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 找出正在進行的 rundown
    FMResultSet *rs = [DatabaseManager executeQuery:@"select * from RUNDOWN_TABLE where r_state=1 order by r_id desc;"];
    
    while ([rs next])
    {
        _r_id = [rs stringForColumn:@"r_id"];
        _r_img_name = [rs stringForColumn:@"r_img_name"];
        _r_img_count = [rs intForColumn:@"r_img_count"];
        NSLog(@"%@", [NSString stringWithFormat:@"%@ %@%d.png", _r_id, _r_img_name, _r_img_count ]);
    }

    // 抓背景
    _bg_pic = [NSString stringWithFormat:@"%@.png", _r_img_name];
    NSLog(@"%@", _bg_pic);
    
    // 先直接放圖檔名測試 XD
    // [self.stage_bg setImage:[UIImage imageNamed:_bg_pic]];
    [self.stage_bg setImage:[UIImage imageNamed:@"stage1.png"]];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
