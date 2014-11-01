//
//  DetailViewController.h
//  Columbus
//
//  Created by Frederik Riedel on 31.10.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+ImageEffects.h"
#import "Institution.h"

@interface DetailViewController : UIViewController

@property(nonatomic) UIImageView *institutionImage;
@property(nonatomic) UIWebView *webView;
@property(nonatomic) Institution *institution;

-(id) initWithInstitution:(Institution *) institution;

@end
