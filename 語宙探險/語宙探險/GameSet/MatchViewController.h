//
//  MatchViewController.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/23.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol MatchViewControllerDelegate;

@interface MatchViewController : UIViewController<AVAudioPlayerDelegate>

@property (nonatomic, assign) id<MatchViewControllerDelegate> delegate;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (weak, nonatomic) IBOutlet UIImageView *imgPlate;

@property (weak, nonatomic) IBOutlet UIButton *btnItem1;
@property (weak, nonatomic) IBOutlet UIButton *btnItem2;
@property (weak, nonatomic) IBOutlet UIButton *btnItem3;
@property (weak, nonatomic) IBOutlet UIButton *btnItem4;
@property (weak, nonatomic) IBOutlet UIButton *btnItem5;

@end

@protocol MatchViewControllerDelegate <NSObject>

- (void)gameComplete;

@end