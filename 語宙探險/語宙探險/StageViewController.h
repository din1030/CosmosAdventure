//
//  StageViewController.h
//  語宙探險
//
//  Created by GoGoDin on 2014/12/10.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApadViewController.h"
#import "BookViewController.h"

@protocol StageViewControllerDelegate;

@interface StageViewController : UIViewController<UIPopoverControllerDelegate, ApadViewControllerDelegate, BookViewControllerDelegate>

@property (nonatomic, assign) id<StageViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *curtain;
@property (strong, nonatomic) IBOutlet UIImageView *stage_bg;
@property (weak, nonatomic) IBOutlet UIButton *btnDictionary;
@property (weak, nonatomic) IBOutlet UIButton *btnApad;

@end

@protocol StageViewControllerDelegate <NSObject>

- (void)changeViewController:(NSString*)toView;

@end