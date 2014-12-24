//
//  MatchViewController.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/23.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MatchViewControllerDelegate;

@interface MatchViewController : UIViewController

@property (nonatomic, assign) id<MatchViewControllerDelegate> delegate;
- (IBAction)btnTestClicked:(id)sender;
@end

@protocol MatchViewControllerDelegate <NSObject>

- (void)gameComplete;

@end