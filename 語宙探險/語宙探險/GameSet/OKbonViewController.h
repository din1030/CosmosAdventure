//
//  OKbonViewController.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/23.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol OKbonViewControllerDelegate;

@interface OKbonViewController : UIViewController<AVAudioPlayerDelegate>

@property (nonatomic, assign) id<OKbonViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString* gameName;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (weak, nonatomic) IBOutlet UIImageView *game_bg;
@property (weak, nonatomic) IBOutlet UIImageView *imgUFO;
@property (weak, nonatomic) IBOutlet UIProgressView *prgrss;
@property (weak, nonatomic) IBOutlet UIButton *btnFinish;

- (IBAction)btnFinishClicked:(id)sender;

@end

@protocol OKbonViewControllerDelegate <NSObject>

- (void)gameComplete:(NSString *)name;

@end