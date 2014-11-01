//
//  Institution.h
//  Columbus
//
//  Created by Frederik Riedel on 31.10.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import CoreLocation;

@interface Institution : NSObject

@property(readwrite) NSString *name;
@property(readwrite) double distance;
@property(readwrite) NSNumber *uuid;
@property(readwrite) NSArray *keywords;
@property(readwrite) NSString *type;
@property(readwrite) NSString *openingHours;
@property(readwrite) UIImage *image;
@property(readwrite) NSString *imageURL;
@property(readwrite) NSString *stadt;
@property(readwrite) CLLocationCoordinate2D location;
@property(readwrite) NSString *beschreibung;

-(void) imageUsingBlock:(void (^)(UIImage *image))block;


@end
