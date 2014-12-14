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

@interface StoryViewController ()

@end

@implementation StoryViewController

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

    if (_r_img_count != 0) {
        // 設定關卡前情提要第一張圖
        _current_count = 1;
        _animation_pic = [NSString stringWithFormat:@"%@%d.png", _r_img_name, _current_count];
        NSLog(@"%@", _animation_pic);
        [self.story_animate setImage:[UIImage imageNamed:_animation_pic]];
        _current_count++;
    
        UITapGestureRecognizer *tapGestureRecognizer;
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeAnimate:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:tapGestureRecognizer];

    } else {
        // 若非前情提要，直接抓背景，還要抓對話？
    
        _animation_pic = [NSString stringWithFormat:@"%@.png", _r_img_name];
        NSLog(@"%@", _animation_pic);
        [self.story_animate setImage:[UIImage imageNamed:_animation_pic]];
    
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// for 前情提要的 tap gesture event handler
- (void)changeAnimate:(UIGestureRecognizer *)recognizer {
    if ( _current_count<= _r_img_count) {
        _animation_pic = [NSString stringWithFormat:@"%@%d.png", _r_img_name, _current_count];
        NSLog(@"%@", _animation_pic);
        [self.story_animate setImage:[UIImage imageNamed:_animation_pic]];
        _current_count++;
    } else {
        #warning 前情提要播完了，改 db 狀態
        // 去關卡頁面
        [self performSegueWithIdentifier:@"toStage" sender:self];
    }
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
