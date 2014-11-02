//
//  MenuView.m
//  Columbus
//
//  Created by Frederik Riedel on 01.11.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import "MenuView.h"

@implementation MenuView
@synthesize tips,karte,delegate;
-(id) initWithFrame:(CGRect)frame {
    self=[super initWithFrame:frame];
    if(self) {
        
        
        karte = [UIButton buttonWithType:UIButtonTypeCustom];
        [karte addTarget:self action:@selector(karteaction) forControlEvents:UIControlEventTouchUpInside];
        [karte setImage:[UIImage imageNamed:@"menu_karte.png"] forState:UIControlStateNormal];
        karte.frame=CGRectMake(0, -self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
        [self addSubview:karte];
        
        
        tips = [UIButton buttonWithType:UIButtonTypeCustom];
        [tips addTarget:self action:@selector(tipsaction) forControlEvents:UIControlEventTouchUpInside];
        [tips setImage:[UIImage imageNamed:@"menu_tips.png"] forState:UIControlStateNormal];
        tips.frame=CGRectMake(0, -self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
        [self addSubview:tips];
        
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [back setImage:[UIImage imageNamed:@"back_dark.png"] forState:UIControlStateNormal];
        back.frame=CGRectMake(15, 35, 24, 24);
        [self addSubview:back];
        
    }
    
    return self;
}

-(void) einblenden {
    [UIView animateWithDuration:0.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         tips.frame=CGRectMake(0, 50, self.frame.size.width, self.frame.size.height/2);
         karte.frame=CGRectMake(0, 50+self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.2
                               delay:0
                             options: UIViewAnimationOptionCurveEaseInOut
                          animations:^
          {
              tips.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2);
              karte.frame=CGRectMake(0, self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
          }
                          completion:^(BOOL finished)
          {
              
          }];
         
     }];
}

-(void) back {
    [self ausblenden];
}

-(void) ausblenden {
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         tips.frame=CGRectMake(0, 50, self.frame.size.width, self.frame.size.height/2);
         karte.frame=CGRectMake(0, 50+self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.5
                               delay:0
                             options: UIViewAnimationOptionCurveEaseInOut
                          animations:^
          {
              tips.frame=CGRectMake(0, -self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
              karte.frame=CGRectMake(0, -self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
          }
                          completion:^(BOOL finished)
          {
              
              [self removeFromSuperview];
          }];
     }];
    
}

-(void) karteaction {
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         tips.frame=CGRectMake(0, 50, self.frame.size.width, self.frame.size.height/2);
         karte.frame=CGRectMake(0, 50+self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.5
                               delay:0
                             options: UIViewAnimationOptionCurveEaseInOut
                          animations:^
          {
              tips.frame=CGRectMake(0, -self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
              karte.frame=CGRectMake(0, -self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
          }
                          completion:^(BOOL finished)
          {
              
              [self removeFromSuperview];
              [delegate karte];
          }];
     }];
    
    
}

-(void) tipsaction {
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         tips.frame=CGRectMake(0, 50, self.frame.size.width, self.frame.size.height/2);
         karte.frame=CGRectMake(0, 50+self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.5
                               delay:0
                             options: UIViewAnimationOptionCurveEaseInOut
                          animations:^
          {
              tips.frame=CGRectMake(0, -self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
              karte.frame=CGRectMake(0, -self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
          }
                          completion:^(BOOL finished)
          {
              
              [self removeFromSuperview];
              [delegate tips];
          }];
     }];
    
    
    
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
