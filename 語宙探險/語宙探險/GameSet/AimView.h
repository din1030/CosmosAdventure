//
//  AimView.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/25.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface AimView : UIView
{
    float xpoint;
    float ypoint;
    float radius;
    float stroke;
}

- (void)moveCenterTo:(float)x y:(float)y;
- (CGRect)rectOfCircle;

@end
