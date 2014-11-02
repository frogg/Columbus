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

+(void) checkIfUserIsAlreadyRegistered {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString* foofile = [documentsPath stringByAppendingPathComponent:@"uuid.txt"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
    if(!fileExists) {
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/get/userID/",[IP getIP]]]];
        //    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://google.de/%f/%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude]]];
        
        [request setHTTPMethod:@"GET"];
        
        NSString *post = nil;
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        [request setHTTPBody:postData];
        
        NSURLResponse *response;
        NSError *err;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        NSString *result =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        if(![result isEqualToString:@""] && result!=(NSString *) [NSNull null] && result) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            [self setUUID:[NSString stringWithFormat:@"%ld",(long)[[dic objectForKey:@"userID"] integerValue]]];
        }
    }
}

+(void) setMeter:(NSString *)string {
    meter=string;
    [self saveString];
}

+(NSString *) meter {
    if([meter isEqualToString:@""] || meter==[NSNull null] || meter == NULL || !meter) {
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

    if([timeDiff isEqualToString:@""] || timeDiff==[NSNull null] || timeDiff==NULL || !timeDiff) {
        [self getFromFile];
        if([timeDiff isEqualToString:@""]) {
            timeDiff=@"60";
        }
    }
    NSLog(@"---%@",timeDiff);
    return timeDiff;
}


+(void) setUUID:(NSString *)string {
    uuid=string;
    [self saveString];
}

+(NSString *) UUID {
    if([uuid isEqualToString:@""] || !uuid) {
        [self getFromFile];
    }
    NSLog(uuid);
    return uuid;
}

//private
+(void) saveString {
    NSString *string = [NSString stringWithFormat:@"%@\n%@\n%@",uuid,meter,timeDiff];
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *path = [documentsPath stringByAppendingPathComponent:@"uuid.txt"];
    NSLog(path);
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
