//
//  MainViewController.h
//  Hackathon Stuttgart 2014
//
//  Created by Frederik Riedel on 31.10.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "SettingsViewController.h"
#import "InstitutionOverviewView.h"
#import "MenuView.h"
#import "KarteViewController.h"
#import "Institution.h"
#import "AktuellsteListe.h"
#import "IP.h"
#import "LocalDataBase.h"

@import QuartzCore;

@interface MainViewController : UIViewController <InstitutionOverViewDelegate,MenuDelegate>

@property(nonatomic) InstitutionOverviewView *institutionOverView;
@property(nonatomic) Institution *institution;
@property(nonatomic) int aktuell;

-(void) newInstitution:(Institution *) institutionneu;
@end
