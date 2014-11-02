//
//  CircularSliderView.h
//  CircularSlider
//
//  Created by Thomas Finch on 4/9/13.
//  Copyright (c) 2013 Thomas Finch. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CircularSliderDelegate <NSObject>
@required
-(void) newOutputString:(NSString *) string forType:(int) type;


@end

@interface CircularSliderView : UIView

@property(nonatomic) CGPoint barCenter, knobCenter;
@property(nonatomic) float barRadius, knobRadius, knobAngle, minValue, maxValue;
@property(nonatomic) bool isKnobBeingTouched;
@property(nonatomic) UILabel* valueLabel;
@property(nonatomic) int type;
@property(nonatomic,weak)id<CircularSliderDelegate> delegate;

-(id)initWithMinValue:(float)minimumValue maxValue:(float)maximumValue initialValue:(float)initialValue withType:(int) type;
-(float)value;

@end
