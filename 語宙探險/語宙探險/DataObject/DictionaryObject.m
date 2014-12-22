//
//  DictionaryObject.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/22.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "DictionaryObject.h"

@implementation DictionaryObject

+ (id)page:(int)did title:(NSString*)dtitle description:(NSString*)ddescription cutout:(int)dcutout sid:(int)dsid get:(int)dget date:(NSString*)ddate
{
    DictionaryObject *newPage = [[self alloc] init];
    newPage.did = did;
    newPage.dtitle = dtitle;
    newPage.ddescription = ddescription;
    newPage.dcutout = dcutout;
    newPage.dsid = dsid;
    newPage.dget = dget;
    newPage.ddate = ddate;
    
    return newPage;
}

@end
