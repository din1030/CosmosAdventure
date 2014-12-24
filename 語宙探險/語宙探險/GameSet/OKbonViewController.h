//
//  OKbonViewController.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/23.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OKbonViewControllerDelegate;

@interface OKbonViewController : UIViewController

@property (nonatomic, assign) id<OKbonViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString* gameName;
- (IBAction)btnTestClicked:(id)sender;

@end

@protocol OKbonViewControllerDelegate <NSObject>

- (void)gameComplete:(NSString *)name;

@end