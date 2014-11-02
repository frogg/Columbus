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

-(void) descriptionUsingBlock:(void (^)(NSString *beschriebung))block {
    if(self.beschreibung) {
        block(self.beschreibung);
    }
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/get/details/%@",[IP getIP],self.uuid]]];
    //    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://google.de/%f/%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude]]];
    
    [request setHTTPMethod:@"GET"];
    
    NSString *post = nil;
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    //NSString *result =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    block([dic objectForKey:@"summary"]);

}


@end
