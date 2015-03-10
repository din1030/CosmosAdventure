//
//  StageViewController.h
//  語宙探險
//
//  Created by GoGoDin on 2014/12/10.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ApadViewController.h"
#import "BookViewController.h"
#import "OKbonViewController.h"
#import "ItemViewController.h"
#import "OCRViewController.h"

@protocol StageViewControllerDelegate;

@interface StageViewController : UIViewController<UIPopoverControllerDelegate, AVAudioPlayerDelegate, ApadViewControllerDelegate, BookViewControllerDelegate, OKbonViewControllerDelegate, ItemViewControllerDelegate, OCRViewControllerDelegate>

@property (nonatomic, assign) id<StageViewControllerDelegate> delegate;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (strong, nonatomic) IBOutlet UIImageView *stage_bg;

@property (weak, nonatomic) IBOutlet UIButton *btnDictionary;
@property (weak, nonatomic) IBOutlet UIButton *btnApad;
@property (weak, nonatomic) IBOutlet UIView *pageView;
@property (weak, nonatomic) IBOutlet UILabel *lblPageTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblPageDetail;
@property (weak, nonatomic) IBOutlet UILabel *lblCutWord;
@property (weak, nonatomic) IBOutlet UIImageView *imgDirt;
@property (weak, nonatomic) IBOutlet UIImageView *imgRepair;

@end

@protocol StageViewControllerDelegate <NSObject>

- (void)changeViewController:(NSString*)toView;
- (void)endOfStory;

@end