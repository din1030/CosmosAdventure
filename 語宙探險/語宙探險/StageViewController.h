//
//  StageViewController.h
//  語宙探險
//
//  Created by GoGoDin on 2014/12/10.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ApadViewController.h"
#import "BookViewController.h"
#import "OKbonViewController.h"
#import "ItemViewController.h"

@protocol StageViewControllerDelegate;

@interface StageViewController : UIViewController<UIPopoverControllerDelegate, ApadViewControllerDelegate, BookViewControllerDelegate, OKbonViewControllerDelegate, ItemViewControllerDelegate>

@property (nonatomic, assign) id<StageViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *curtain;
@property (strong, nonatomic) IBOutlet UIImageView *stage_bg;
@property (weak, nonatomic) IBOutlet UIImageView *stage_dialog;
@property (weak, nonatomic) IBOutlet UIImageView *stage_character;
@property (weak, nonatomic) IBOutlet UILabel *stage_lines;

@property (weak, nonatomic) IBOutlet UIButton *btnDictionary;
@property (weak, nonatomic) IBOutlet UIButton *btnApad;

@end

@protocol StageViewControllerDelegate <NSObject>

- (void)changeViewController:(NSString*)toView;

@end