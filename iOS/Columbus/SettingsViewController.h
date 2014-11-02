//
//  SettingsViewController.h
//  Columbus
//
//  Created by Frederik Riedel on 01.11.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircularSliderView.h"
#import "MenuView.h"
#import "LocalDataBase.h"

@interface SettingsViewController : UIViewController<CircularSliderDelegate>
@property(nonatomic) UILabel *frequenzDetail;
@property(nonatomic) UILabel *radiusDetail;
@property(nonatomic) CircularSliderView *sliderView;
@property(nonatomic) CircularSliderView *maxdistance;
@end
