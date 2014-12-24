//
//  PagesViewController.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/22.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DictionaryObject.h"

@protocol PagesViewControllerDelegate;

@interface PagesViewController : UIViewController

@property (nonatomic, assign) id<PagesViewControllerDelegate> delegate;

@property NSUInteger pageIndex;
@property (strong, nonatomic) DictionaryObject *thePage;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblPage;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnPrevious;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

- (IBAction)btnCloseClicked:(id)sender;
- (IBAction)btnNextClicked:(id)sender;
- (IBAction)btnPreviousClicked:(id)sender;

@end

@protocol PagesViewControllerDelegate <NSObject>

- (void)shouldStartOCR:(int)did cutword:(NSString*)word fullword:(NSString*)title;

@end