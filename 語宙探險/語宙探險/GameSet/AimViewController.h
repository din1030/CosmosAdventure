//
//  AimViewController.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/23.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <QuartzCore/CAAnimation.h>

@protocol AimViewControllerDelegate;

@interface AimViewController : UIViewController

@property (nonatomic, assign) id<AimViewControllerDelegate> delegate;

@property (assign, nonatomic) CGPoint currentPoint;
@property (assign, nonatomic) CGPoint previousPoint;
@property (assign, nonatomic) CGFloat aimXVelocity;
@property (assign, nonatomic) CGFloat aimYVelocity;
@property (assign, nonatomic) CMAcceleration acceleration;
@property (strong, nonatomic) CMMotionManager  *motionManager;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSDate *lastUpdateTime;

@property (weak, nonatomic) IBOutlet UIImageView *game_bg;
@property (weak, nonatomic) IBOutlet UIImageView *game_boy;
@property (weak, nonatomic) IBOutlet UILabel *lblOutline;

@end

@protocol AimViewControllerDelegate <NSObject>

- (void)gameComplete;

@end