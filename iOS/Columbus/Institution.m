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

-(NSString*) getOpeningHours{
    @try {
        NSMutableArray *weekdaysUnChanged = [[NSMutableArray alloc] initWithObjects:@"mon", @"tue", @"wed", @"thu", @"fri",@"sat",@"sun", nil];
        NSMutableArray *weekdays = [[NSMutableArray alloc] initWithObjects:@"mon", @"tue", @"wed", @"thu", @"fri",@"sat",@"sun", nil];
        NSMutableArray *weekdaysKlartext = [[NSMutableArray alloc] initWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday",@"Saturday",@"Sunday", nil];
        
        
        if(self.openingHours!=(NSDictionary*)[NSNull null]){
            for(id key in self.openingHours){
               //find array position
                int position = -1;
                for(int i=0; i<[weekdays count]; i++){
                    if([key isEqualToString:[weekdays objectAtIndex:i]]){
                        position =i ;
                    }
                }

                if(position > -1){
                    NSArray* arr =[self.openingHours objectForKey:key];
                    int changed = 0;
                    for(int i=0; i<[arr count]; i++){
                        
                        if(arr[i] !=(NSString*)[NSNull null]){
                            if(changed == 0){
                            NSMutableString *mu = [NSMutableString stringWithString:arr[i]];
                            [mu insertString:@":" atIndex:2];
                              [weekdays replaceObjectAtIndex:position withObject:[NSString stringWithFormat:@"%@: %@",[weekdaysKlartext objectAtIndex:position],mu]];
                            }else{
                                NSMutableString *mu = [NSMutableString stringWithString:arr[i]];
                                [mu insertString:@":" atIndex:2];
                                if(changed==1|| changed ==3){
                                    [weekdays replaceObjectAtIndex:position withObject:[NSString stringWithFormat:@"%@-%@",[weekdays objectAtIndex:position],mu]];}
                                if(changed==2){
                                    [weekdays replaceObjectAtIndex:position withObject:[NSString stringWithFormat:@"%@; %@",[weekdays objectAtIndex:position],mu]];
                                }
                            }
                            changed ++;
                        }
                    }

                }
                

                    
                   
                }
            }
    
        NSDateFormatter *wochentag = [[NSDateFormatter alloc] init];
        [wochentag setDateFormat: @"e"];
        int wochentagIndex = (int)[[wochentag stringFromDate:[NSDate date]] integerValue];
        
        NSString* toReturn = @"";
        for(int i=0; i<[weekdays count]; i++){
            if(![[weekdays objectAtIndex:i] isEqualToString:[weekdaysUnChanged objectAtIndex:i]]){
                if(i==wochentagIndex){
                    toReturn = [NSString stringWithFormat:@"%@<b>%@</b><br>",toReturn,[weekdays objectAtIndex:i]] ;
                }else{
                    toReturn = [NSString stringWithFormat:@"%@%@<br>",toReturn,[weekdays objectAtIndex:i]] ;
                }

            }else{
                if(i==wochentagIndex){
             toReturn = [NSString stringWithFormat:@"%@<b>%@</b>: closed<br>",toReturn,[weekdaysKlartext objectAtIndex:i]];
                }else{
                toReturn = [NSString stringWithFormat:@"%@%@: closed<br>",toReturn,[weekdaysKlartext objectAtIndex:i]];
                }

            }
        }
        

        
        return toReturn;
    

    }
    @catch (NSException *exception) {
        return @"10:00-18:00";
    }
    @finally {
    
    }


}


@end
