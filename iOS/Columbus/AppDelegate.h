//
//  AppDelegate.h
//  Hackathon Stuttgart 2014
//
//  Created by Frederik Riedel on 31.10.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "Institution.h"
#import "MBFingerTipWindow.h"
#import "AktuellsteListe.h"
#import "IP.h"
@import CoreLocation;

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>



@property (strong, nonatomic) MBFingerTipWindow *window;
@property(nonatomic) CLLocationManager *locationManager;
@property(nonatomic) MainViewController *firstView;

@end

