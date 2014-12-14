//
//  DatabaseManager.m
//  語宙探險
//
//  Created by GoGoDin on 2014/12/10.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "DatabaseManager.h"

@implementation DatabaseManager

// Connect to Database
+ (FMDatabase *)connectToDataBase
{
    
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* dbPath = [docPath stringByAppendingPathComponent:@"dump.sqlite"];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if(![fm fileExistsAtPath:dbPath])
    {
        NSError* error;
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"dump.sqlite"];
        BOOL success = [fm copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        if(!success){
            NSLog(@"can't copy db template.");
            assert(false);
        }
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open])
    {
        NSLog(@"Could not open db.");
        return nil;
    }
    return db;
}

// Select Table Content
+ (FMResultSet *)executeQuery:(NSString *)strSQL
{
    FMDatabase *db = [self connectToDataBase];
    return [db executeQuery:strSQL];
}

// Modify Table
+ (void)executeModifySQL:(NSString *)strSQL
{
    FMDatabase *db = [self connectToDataBase];
    [db executeUpdate:strSQL];
}

@end
