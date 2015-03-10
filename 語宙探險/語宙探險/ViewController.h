//
//  ViewController.h
//  語宙探險
//
//  Created by GoGoDin on 2014/12/10.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <sqlite3.h>
#import "StoryViewController.h"
#import "StageViewController.h"

@interface ViewController : UIViewController<AVAudioPlayerDelegate, StoryViewControllerDelegate, StageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *curtain;
@property (retain, nonatomic) NSString *r_id;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

