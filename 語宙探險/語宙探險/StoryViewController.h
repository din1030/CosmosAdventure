//
//  StoryViewController.h
//  語宙探險
//
//  Created by GoGoDin on 2014/12/14.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchViewController.h"
#import "AimViewController.h"

@protocol StoryViewControllerDelegate;

@interface StoryViewController : UIViewController<MatchViewControllerDelegate, AimViewControllerDelegate>

@property (nonatomic, assign) id<StoryViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *curtain;
@property (strong, nonatomic) IBOutlet UIImageView *story_animate;
@property (weak, nonatomic) IBOutlet UIImageView *story_dialog;
@property (weak, nonatomic) IBOutlet UIImageView *story_character;
@property (weak, nonatomic) IBOutlet UILabel *story_lines;
@property (weak, nonatomic) IBOutlet UIView *story_menu;
@property (weak, nonatomic) IBOutlet UILabel *lblMenuTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnOption1;
@property (weak, nonatomic) IBOutlet UIButton *btnOption2;
@property (weak, nonatomic) IBOutlet UIButton *btnOption3;
@property (nonatomic) int r_img_count;
@property (nonatomic) int current_count;

@end

@protocol StoryViewControllerDelegate <NSObject>

- (void)changeViewController:(NSString*)toView;
- (void)endOfStory;

@end