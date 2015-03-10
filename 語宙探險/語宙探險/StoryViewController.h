//
//  StoryViewController.h
//  語宙探險
//
//  Created by GoGoDin on 2014/12/14.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MatchViewController.h"
#import "AimViewController.h"

@protocol StoryViewControllerDelegate;

@interface StoryViewController : UIViewController<AVAudioPlayerDelegate, MatchViewControllerDelegate, AimViewControllerDelegate>

@property (nonatomic, assign) id<StoryViewControllerDelegate> delegate;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (strong, nonatomic) IBOutlet UIImageView *story_animate;

@property (nonatomic) int r_img_count;
@property (nonatomic) int current_count;

@end

@protocol StoryViewControllerDelegate <NSObject>

- (void)changeViewController:(NSString*)toView;
- (void)endOfStory;

@end