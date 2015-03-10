//
//  ApadViewController.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/22.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ApadViewControllerDelegate;

@interface ApadViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate>

@property (nonatomic, assign) id<ApadViewControllerDelegate> delegate;

@property int sid;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (weak, nonatomic) IBOutlet UITableView *missionTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnComplete;
- (IBAction)btnCompleteClicked:(id)sender;

@end

@protocol ApadViewControllerDelegate <NSObject>

- (void)directToDictionary;
- (void)directToGame:(NSString *)name;
- (void)directToStory;

@end