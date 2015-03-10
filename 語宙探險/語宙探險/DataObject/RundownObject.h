//
//  RundownObject.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/21.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RundownObject : NSObject

@property int rid;
@property int sid;
@property (nonatomic, copy) NSString *note;
@property int type;
@property int state;
@property (nonatomic, copy) NSString *date;

+ (id)run:(int)rid sid:(int)sid note:(NSString*)note type:(int)type state:(int)state date:(NSString*)date;

@end
