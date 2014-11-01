//
//  Institution.m
//  Columbus
//
//  Created by Frederik Riedel on 31.10.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import "Institution.h"

@implementation Institution


-(void) imageUsingBlock:(void (^)(UIImage *image))block {
    if(self.image) {
        block(self.image);
    }
    if(self.imageURL!=[NSNull null]) {
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.imageURL]];
        self.image=[UIImage imageWithData: imageData];
        block(self.image);
    } else {
        block([UIImage imageNamed:@"default_background_error.png"]);
    }
}

@end
