//
//  DatabaseManager
//  語宙探險
//
//  Created by GoGoDin on 2014/12/10.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DatabaseManager : NSObject

+ (FMResultSet *)executeQuery:(NSString *)strSQL;
+ (void)executeModifySQL:(NSString *)strSQL;

@end
