//
//  RundownObject.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/21.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "RundownObject.h"

@implementation RundownObject

+ (id)run:(int)rid sid:(int)sid note:(NSString *)note type:(int)type state:(int)state date:(NSString *)date
{
    RundownObject *newRun = [[self alloc] init];
    newRun.rid = rid;
    newRun.sid = sid;
    newRun.note = note;
    newRun.type = type;
    newRun.state = state;
    newRun.date = date;
    
    return newRun;
}

@end
