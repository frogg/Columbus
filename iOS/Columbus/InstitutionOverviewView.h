//
//  InstitutionOverviewView.h
//  Columbus
//
//  Created by Frederik Riedel on 01.11.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Institution.h"


@protocol InstitutionOverViewDelegate <NSObject>
@required
-(void) details;
-(void) boring;
-(void) like;

@end


@interface InstitutionOverviewView : UIView
@property(nonatomic) Institution *institution;
@property(nonatomic) UIImageView *schablone;
@property(nonatomic) UIImageView *institutionImage;
@property(nonatomic) UIWebView *information;
@property(nonatomic) UIActivityIndicatorView *wait;

@property(nonatomic,weak)id<InstitutionOverViewDelegate> delegate;

@end
