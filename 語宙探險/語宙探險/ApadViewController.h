//
//  ApadViewController.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/22.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ApadViewControllerDelegate;

@interface ApadViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<ApadViewControllerDelegate> delegate;

@property int sid;
@property (weak, nonatomic) IBOutlet UITableView *missionTableView;

@end

@protocol ApadViewControllerDelegate <NSObject>

- (void)directToDictionary;
- (void)directToGame:(NSString *)name;

@end