//
//  GoalView.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/27.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "GoalView.h"

@implementation GoalView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIView* backView = [[UIView alloc] initWithFrame:self.frame];
        [backView setBackgroundColor:[UIColor blackColor]];
        [backView setAlpha:0.6];
        
        // full screen
        UIImageView* imgFrame = [[UIImageView alloc] initWithFrame:CGRectMake(280, 219, 465, 330)];
        [imgFrame setImage:[UIImage imageNamed:@"bg_usemagic.png"]];
        
        UIImageView* imgCharacter = [[UIImageView alloc] initWithFrame:CGRectMake(81, 429, 350, 270)];
        [imgCharacter setImage:[UIImage imageNamed:@"c_book.png"]];
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(337, 293, 350, 50)];
        [self.lblTitle setFont:[UIFont systemFontOfSize:28.0]];
        [self.lblTitle setBackgroundColor:[UIColor clearColor]];
        [self.lblTitle setTextAlignment:NSTextAlignmentCenter];
        
        self.lblDetail = [[UILabel alloc] initWithFrame:CGRectMake(337, 359, 350, 50)];
        [self.lblDetail setFont:[UIFont systemFontOfSize:25.0]];
        [self.lblDetail setBackgroundColor:[UIColor clearColor]];
        [self.lblDetail setTextAlignment:NSTextAlignmentCenter];
        
        self.btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(476, 463, 73, 42)];
        [self.btnConfirm setBackgroundImage:[UIImage imageNamed:@"btn_confirm.png"] forState:UIControlStateNormal];
        
        [self addSubview:backView];
        [self addSubview:imgFrame];
        [self addSubview:imgCharacter];
        [self addSubview:self.lblTitle];
        [self addSubview:self.lblDetail];
        [self addSubview:self.btnConfirm];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
