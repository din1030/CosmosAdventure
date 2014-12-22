//
//  ViewController.m
//  語宙探險
//
//  Created by GoGoDin on 2014/12/10.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "ViewController.h"
#import "FMDatabase.h"
#import "DatabaseManager.h"

@interface ViewController ()
{
    UIStoryboardSegue* goStory;
    UIStoryboardSegue* goStage;
}
- (IBAction)btnPlayClicked:(id)sender;
- (IBAction)btnOpenClicked:(id)sender;
- (IBAction)btnFirstClicked:(id)sender;
- (IBAction)btnGame1Clicked:(id)sender;
- (IBAction)btnGame2Clicked:(id)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnPlayClicked:(id)sender {
    // 繼續遊戲
    // 畫面變黑
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.curtain.alpha = 1.0;
    }];
    // 找出正在進行的 rundown
    FMResultSet *rs = [DatabaseManager executeQuery:@"select r_sid from RUNDOWN_TABLE where r_state=1 order by r_id desc;"];
    
    while ([rs next])
    {
        if([rs intForColumnIndex:0] % 2) {
            // 舞台
            StageViewController* stage = [self.storyboard instantiateViewControllerWithIdentifier:@"stage"];
            [self presentViewController:stage animated:NO completion:nil];
        }
        else {
            StoryViewController* story = [self.storyboard instantiateViewControllerWithIdentifier:@"story"];
            story.delegate = self;
            [self presentViewController:story animated:NO completion:nil];
        }
    }
}

- (IBAction)btnOpenClicked:(id)sender {
}

- (IBAction)btnFirstClicked:(id)sender {
}

- (IBAction)btnGame1Clicked:(id)sender {
}

- (IBAction)btnGame2Clicked:(id)sender {
}

#pragma mark - Delegates

- (void)changeViewController:(NSString *)toView
{
    NSLog(@"changeViewController %@",toView);
    [self dismissViewControllerAnimated:NO completion:nil];
    StageViewController* stage = [self.storyboard instantiateViewControllerWithIdentifier:toView];
    [self presentViewController:stage animated:NO completion:nil];
}

@end
