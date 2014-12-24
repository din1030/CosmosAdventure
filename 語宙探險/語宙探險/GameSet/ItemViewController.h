//
//  ItemViewController.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/24.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ItemViewControllerDelegate;

@interface ItemViewController : UIViewController

@property (nonatomic, assign) id<ItemViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString* gameName;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end

@protocol ItemViewControllerDelegate <NSObject>

- (void)gameComplete:(NSString *)name;

@end