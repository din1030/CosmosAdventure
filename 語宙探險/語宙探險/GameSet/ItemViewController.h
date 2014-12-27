//
//  ItemViewController.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/24.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ItemViewControllerDelegate;

@interface ItemViewController : UIViewController<AVAudioPlayerDelegate>

@property (nonatomic, assign) id<ItemViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString* gameName;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@protocol ItemViewControllerDelegate <NSObject>

- (void)gameComplete:(NSString *)name;

@end