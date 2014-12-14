//
//  StoryViewController.h
//  語宙探險
//
//  Created by GoGoDin on 2014/12/14.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *story_animate;
@property (retain, nonatomic) NSString *r_id;
@property (retain, nonatomic) NSString *r_img_name;
@property (nonatomic) int r_img_count;
@property (nonatomic) int current_count;
@property (retain, nonatomic) NSString *animation_pic;
@end
