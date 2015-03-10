//
//  DictionaryObject.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/22.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictionaryObject : NSObject

@property int did;
@property (nonatomic, copy) NSString *dtitle;
@property (nonatomic, copy) NSString *ddescription;
@property int dcutout;
@property int dsid;
@property int dget;
@property (nonatomic, copy) NSString *ddate;

+ (id)page:(int)did title:(NSString*)dtitle description:(NSString*)ddescription cutout:(int)dcutout sid:(int)dsid get:(int)dget date:(NSString*)ddate;

@end
