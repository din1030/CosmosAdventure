//
//  QuizView.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/26.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "QuizView.h"

@implementation QuizView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        [self setBackgroundColor:[UIColor clearColor]];
        
        // 252.558.520.174
        self.imgFrame = [[UIImageView alloc] initWithFrame:CGRectMake(0, 35, 520, 174)];
        [self.imgFrame setImage:[UIImage imageNamed:@"dialog.png"]];
        
        self.btnOptionL = [[UIButton alloc] initWithFrame:CGRectMake(24, 77, 158, 65)];
        self.btnOptionM = [[UIButton alloc] initWithFrame:CGRectMake(181, 77, 158, 65)];
        self.btnOptionR = [[UIButton alloc] initWithFrame:CGRectMake(338, 77, 158, 65)];
        
        self.lblHint = [[UILabel alloc] initWithFrame:CGRectMake(35, 28, 450, 40)];
        [self.lblHint setFont:[UIFont systemFontOfSize:30.0]];
        [self.lblHint setBackgroundColor:[UIColor clearColor]];
        [self.lblHint setText:@"選擇使用魔法："];
        
        //[self addSubview:self.imgFrame];
        [self addSubview:self.lblHint];
        [self addSubview:self.btnOptionL];
        [self addSubview:self.btnOptionM];
        [self addSubview:self.btnOptionR];
    }
    return self;
}

- (void)setOptions:(NSMutableArray*)opts tag:(NSMutableArray*)anss
{
    [self.btnOptionL setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_%@.png", opts[0]]] forState:UIControlStateNormal];
    [self.btnOptionL setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_%@_click.png", opts[0]]] forState:UIControlStateHighlighted];
    [self.btnOptionL setTag:[anss[0] integerValue]];
    
    [self.btnOptionM setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_%@.png", opts[1]]] forState:UIControlStateNormal];
    [self.btnOptionM setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_%@_click.png", opts[1]]] forState:UIControlStateHighlighted];
    [self.btnOptionM setTag:[anss[1] integerValue]];
    
    [self.btnOptionR setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_%@.png", opts[2]]] forState:UIControlStateNormal];
    [self.btnOptionR setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_%@_click.png", opts[2]]] forState:UIControlStateHighlighted];
    [self.btnOptionR setTag:[anss[2] integerValue]];
}

@end
