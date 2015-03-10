//
//  QuizView.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/26.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuizView : UIView

@property (strong, nonatomic) UIImageView* imgFrame;
@property (strong, nonatomic) UIButton* btnOptionL;
@property (strong, nonatomic) UIButton* btnOptionM;
@property (strong, nonatomic) UIButton* btnOptionR;

@property (strong, nonatomic) UILabel* lblHint;

- (void)setOptions:(NSMutableArray*)opts tag:(NSMutableArray*)anss;

@end