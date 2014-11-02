//
//  AktuellsteListe.m
//  Columbus
//
//  Created by Frederik Riedel on 01.11.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import "AktuellsteListe.h"

@implementation AktuellsteListe

static NSMutableArray *liste;

+(void) aktuelleListe:(NSArray *) neueListe {
    liste=[neueListe mutableCopy];
}

+(NSArray *) aktuelleListe {
    return [liste copy];
}

@end
