//
//  Institution.h
//  Columbus
//
//  Created by Frederik Riedel on 31.10.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface Institution : NSObject

@property(readwrite) NSString *name;
@property(readwrite) NSString *uuid;
@property(readwrite) NSArray *keywords;
@property(readwrite) NSArray *type;
@property(readwrite) NSString *openingHours;
@property(readwrite) CLLocationCoordinate2D location;




@end
