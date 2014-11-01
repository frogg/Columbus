//
//  LocalDataBase.m
//  Columbus
//
//  Created by Frederik Riedel on 01.11.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import "LocalDataBase.h"

@implementation LocalDataBase

NSString *uuid;
NSString *meter;
NSString *timeDiff;


+(void) setMeter:(NSString *)string {
    meter=string;
    [self saveString];
}

+(NSString *) meter {
    if([meter isEqualToString:@""]) {
        [self getFromFile];
        if([meter isEqualToString:@""]) {
            meter=@"250";
        }
    }
    return meter;
}

+(void) setTime:(NSString *)string {
    timeDiff=string;
    [self saveString];
}

+(NSString *) time {
    if([timeDiff isEqualToString:@""]) {
        [self getFromFile];
        if([timeDiff isEqualToString:@""]) {
            timeDiff=@"60";
        }
    }
    return timeDiff;
}


+(void) setUUID:(NSString *)string {
    uuid=string;
    [self saveString];
}

+(NSString *) UUID {
    if([uuid isEqualToString:@""]) {
        [self getFromFile];
        //ggf neue beantragen
    }
    return uuid;
}

//private
+(void) saveString {
    NSString *string = [NSString stringWithFormat:@"%@\n%@\n%@",uuid,meter,timeDiff];
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsPath stringByAppendingPathComponent:@"uuid.txt"];
    [string writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

//private
+(NSString *) getFromFile {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [documentsPath stringByAppendingPathComponent:@"uuid.txt"];
    NSString* string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    if(string) {
        uuid = [string componentsSeparatedByString:@"\n"][0];
        meter = [string componentsSeparatedByString:@"\n"][1];
        timeDiff = [string componentsSeparatedByString:@"\n"][2];
    }
    return string;
}

@end
