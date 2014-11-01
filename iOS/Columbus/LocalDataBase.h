//
//  LocalDataBase.h
//  Columbus
//
//  Created by Frederik Riedel on 01.11.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalDataBase : NSObject

+(void) setUUID:(NSString *)string;
+(NSString *) UUID;

+(void) setMeter:(NSString *)string;
+(NSString *) meter;

+(void) setTime:(NSString *)string;
+(NSString *) time;



@end
