//
//  StageViewController.h
//  語宙探險
//
//  Created by GoGoDin on 2014/12/10.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StageViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *stage_bg;
@property (retain, nonatomic) NSString *r_id;
@property (retain, nonatomic) NSString *r_img_name;
@property (nonatomic) int r_img_count;
@property (retain, nonatomic) NSString *bg_pic;
@end
