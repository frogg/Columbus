//
//  InstitutionOverviewView.m
//  Columbus
//
//  Created by Frederik Riedel on 01.11.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import "InstitutionOverviewView.h"

@implementation InstitutionOverviewView
@synthesize institution,institutionImage,schablone,wait,information,delegate;
-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        
        
        UIImageView *backgroundMap = [[UIImageView alloc] initWithFrame:self.frame];
        backgroundMap.image=[UIImage imageNamed:@"default_background.png"];
        [self addSubview:backgroundMap];
        
        
        
        
        institutionImage = [[UIImageView alloc] initWithFrame:CGRectMake(60, 60, self.frame.size.width-120, 300)];
        institutionImage.contentMode=UIViewContentModeScaleAspectFill;
        institutionImage.clipsToBounds=YES;
        [self addSubview:institutionImage];
        
        schablone = [[UIImageView alloc] initWithFrame:self.frame];
        schablone.image=[UIImage imageNamed:@"schablone.png"];
        [self addSubview:schablone];
        
        wait = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        wait.hidesWhenStopped=YES;
        wait.center=CGPointMake(self.frame.size.width/2, 180);
        [self addSubview:wait];
        
        information=[[UIWebView alloc] initWithFrame:CGRectMake(0, 350, self.frame.size.width, 180)];
        [self addSubview:information];
        information.opaque=NO;
        information.backgroundColor=[UIColor clearColor];
        information.userInteractionEnabled=NO;
        
    }
    
    if(institution) {
        [wait startAnimating];
        void (^block)(UIImage *) = ^(UIImage *image) {
            institutionImage.image=image;
        };
        
        [institution imageUsingBlock:block];
        [wait stopAnimating];
        [information loadHTMLString:[self getInformationHTML] baseURL:nil];
        
        
    }
    [information loadHTMLString:[self getInformationHTML] baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    
    
    UIButton *details = [UIButton buttonWithType:UIButtonTypeCustom];
    [details addTarget:self action:@selector(details) forControlEvents:UIControlEventTouchUpInside];
    [details setImage:[UIImage imageNamed:@"details.png"] forState:UIControlStateNormal];
    details.frame=CGRectMake(140, 550, 100, 25);
    [self addSubview:details];

    UIButton *boring = [UIButton buttonWithType:UIButtonTypeCustom];
    [boring addTarget:self action:@selector(boring) forControlEvents:UIControlEventTouchUpInside];
    [boring setImage:[UIImage imageNamed:@"boring.png"] forState:UIControlStateNormal];
    boring.frame=CGRectMake(195, 590, 62, 62);
    [self addSubview:boring];
    
    UIButton *like = [UIButton buttonWithType:UIButtonTypeCustom];
    [like addTarget:self action:@selector(like) forControlEvents:UIControlEventTouchUpInside];
    [like setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
    like.frame=CGRectMake(115, 590, 62, 62);
    [self addSubview:like];
    
    
    return self;
    
}

-(void) details {
    [delegate details];
}


-(void) boring {
    [delegate boring];
}

-(void) like {
    [delegate like];
}

-(void) setInstitution:(Institution *) _institution {
    institution=_institution;
    institutionImage.image=nil;
    [wait startAnimating];
    
    void (^block)(UIImage *) = ^(UIImage *image) {
        institutionImage.image=image;
            [wait stopAnimating];
    };
    
    [institution performSelectorInBackground:@selector(imageUsingBlock:) withObject:block];
    [information loadHTMLString:[self getInformationHTML] baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}


-(NSString *) getInformationHTML {
    
    NSString *keywords = [institution.keywords componentsJoinedByString:@" | "];
    
    NSString *subtitle=@"";
    
    if(![institution.type isEqualToString:@""] && ![institution.stadt isEqualToString:@""]) {
        subtitle = [NSString stringWithFormat:@"%@ | %@",institution.type,institution.stadt];
    } else if(![institution.type isEqualToString:@""] && [institution.stadt isEqualToString:@""]) {
        subtitle = [NSString stringWithFormat:@"%@",institution.type];
    } else if([institution.type isEqualToString:@""] && ![institution.stadt isEqualToString:@""]) {
        subtitle = [NSString stringWithFormat:@"%@",institution.stadt];
    }
    
    
    
    return [NSString stringWithFormat:@"<html><head><style type=\"text/css\">tit {	font-size: 27;    font-family: HelveticaNeue-Medium;    color: #BD997C;}  sub {	font-size: 17;    font-family: HelveticaNeue-light;    color: #BD997C;} td {	font-size: 17;    font-family: HelveticaNeue-Medium;    color: #BD997C;}  key {	font-size: 12;    font-family: HelveticaNeue-light;  color: #888078;}  body {    margin: 0; padding: 0;} html {    -webkit-text-size-adjust: none;}  </style></head><center><tit>%@</tit><br><sub>%@</sub></br><table><tr><td><img src=\"a.png\" width=74></td><td>%.0f m</td><td><img src=\"b.png\" width=74></td></tr></table><table width=250><tr><td><center><key>%@</key></center></td></tr></table></center></html>",institution.name,subtitle,institution.distance,keywords];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
