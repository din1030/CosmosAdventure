//
//  AimView.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/25.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "AimView.h"

@implementation AimView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        
        xpoint = 300.0;
        ypoint = 300.0;
        radius = 30.0;
        stroke = 3.0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] set];
    
    CGContextRef contextX = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(contextX, stroke);
    CGContextSetLineJoin(contextX, kCGLineJoinRound);
    CGContextMoveToPoint(contextX, xpoint, 0);
    CGContextAddLineToPoint(contextX, xpoint, self.frame.size.height);
    CGContextStrokePath(contextX);
    
    CGContextRef contextY = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(contextY, stroke);
    CGContextSetLineJoin(contextY, kCGLineJoinRound);
    CGContextMoveToPoint(contextY, 0, ypoint);
    CGContextAddLineToPoint(contextY, self.frame.size.width, ypoint);
    CGContextStrokePath(contextY);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, stroke);
    CGContextSetRGBStrokeColor(context, 255.0, 0.0, 0.0, 1.0);
    CGContextStrokeEllipseInRect(context, CGRectMake(xpoint - radius, ypoint - radius, radius*2, radius*2));
    
}

- (void)moveCenterTo:(float)x y:(float)y
{
    xpoint = x;
    ypoint = y;
    
    [self setNeedsDisplay];
}

- (CGRect)rectOfCircle
{
    return CGRectMake(xpoint - radius, ypoint - radius, radius*2, radius*2);
}

@end
