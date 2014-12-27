//
//  DialogView.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/26.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "DialogView.h"

@implementation DialogView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        
        // 252.505.772.243
        self.imgFrame = [[UIImageView alloc] initWithFrame:CGRectMake(0, 35, 520, 174)];
        [self.imgFrame setImage:[UIImage imageNamed:@"dialog.png"]];
        
        self.imgCharacter = [[UIImageView alloc] initWithFrame:CGRectMake(457, 0, 315, 243)];
        
        self.lblDialog = [[UILabel alloc] initWithFrame:CGRectMake(35, 69, 450, 105)];
        [self.lblDialog setFont:[UIFont systemFontOfSize:30.0]];
        [self.lblDialog setBackgroundColor:[UIColor clearColor]];
        [self.lblDialog setNumberOfLines:2];
        
        [self addSubview:self.imgFrame];
        [self addSubview:self.lblDialog];
        [self addSubview:self.imgCharacter];
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
