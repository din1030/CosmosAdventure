//
//  StoryViewController.h
//  語宙探險
//
//  Created by GoGoDin on 2014/12/14.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StoryViewControllerDelegate;

@interface StoryViewController : UIViewController

@property (nonatomic, assign) id<StoryViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *curtain;
@property (strong, nonatomic) IBOutlet UIImageView *story_animate;
@property (weak, nonatomic) IBOutlet UIImageView *story_dialog;
@property (weak, nonatomic) IBOutlet UIImageView *story_character;
@property (weak, nonatomic) IBOutlet UILabel *story_lines;
@property (nonatomic) int r_img_count;
@property (nonatomic) int current_count;

@end

@protocol StoryViewControllerDelegate <NSObject>

- (void)changeViewController:(NSString*)toView;

@end