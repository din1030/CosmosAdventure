//
//  BookViewController.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/22.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PagesViewController.h"

@protocol BookViewControllerDelegate;

@interface BookViewController : UIPageViewController<UIPageViewControllerDataSource, AVAudioPlayerDelegate,  PagesViewControllerDelegate>

@property (nonatomic, assign) id<BookViewControllerDelegate> delegateOCR;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@protocol BookViewControllerDelegate <NSObject>

- (void)startOCR:(int)did cutword:(NSString*)word fullword:(NSString*)title description:(NSString *)description;

@end