//
//  AimViewController.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/23.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AimViewControllerDelegate;

@interface AimViewController : UIViewController

@property (nonatomic, assign) id<AimViewControllerDelegate> delegate;
- (IBAction)btnTestClicked:(id)sender;
@end

@protocol AimViewControllerDelegate <NSObject>

- (void)gameComplete;

@end