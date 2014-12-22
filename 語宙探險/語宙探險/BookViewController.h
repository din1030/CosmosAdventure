//
//  BookViewController.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/22.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagesViewController.h"

@protocol BookViewControllerDelegate;

@interface BookViewController : UIPageViewController<UIPageViewControllerDataSource, PagesViewControllerDelegate>

@property (nonatomic, assign) id<BookViewControllerDelegate> delegateOCR;

@end

@protocol BookViewControllerDelegate <NSObject>

- (void)startOCR:(int)did word:(NSString *)word;

@end