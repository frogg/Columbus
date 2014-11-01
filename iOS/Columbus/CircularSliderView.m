//
//  CircularSliderView.m
//  CircularSlider
//
//  Created by Thomas Finch on 4/9/13.
//  Copyright (c) 2013 Thomas Finch. All rights reserved.
//

/*
 Copyright (c) 2013 Thomas Finch
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "CircularSliderView.h"

#define MIN_ANGLE -M_PI/3
#define MAX_ANGLE (4*M_PI)/3

@implementation CircularSliderView


@synthesize barCenter,knobCenter,barRadius,knobRadius,knobAngle,minValue,maxValue,isKnobBeingTouched,valueLabel,delegate;
-(id)initWithMinValue:(float)minimumValue maxValue:(float)maximumValue initialValue:(float)initialValue withType:(int) type
{
    self = [super init];
    if (self)
        
    {
        self.type=type;
        isKnobBeingTouched=false;
        knobRadius=15;
        [self setBackgroundColor:[UIColor clearColor]];
        maxValue = maximumValue;
        minValue = minimumValue;
        
        //calclulate initial angle from initial value
        float percentDone = 1-(initialValue/(maxValue - minValue));
        knobAngle = MIN_ANGLE+(percentDone*(MAX_ANGLE-MIN_ANGLE));
        
        valueLabel = [[UILabel alloc] init];
        valueLabel.textAlignment = NSTextAlignmentCenter;
        valueLabel.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
        valueLabel.font=[UIFont fontWithName:@"Helveticaneue-ultralight" size:50];
        
        
        valueLabel.textColor=[UIColor whiteColor];
        [valueLabel setText:[self displayStringFromValue:[self value]]];
        [self addSubview:valueLabel];
        
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touches.count > 1)
        return;
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    isKnobBeingTouched = false;
    CGFloat xDist = touchLocation.x - knobCenter.x;
    CGFloat yDist = touchLocation.y - knobCenter.y;
    if (sqrt((xDist*xDist)+(yDist*yDist)) <= knobRadius) //if the touch is within the slider knob
    {
        isKnobBeingTouched = true;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isKnobBeingTouched)
    {
        CGPoint touchLocation = [[touches anyObject] locationInView:self];
        float touchVector[2] = {touchLocation.x-knobCenter.x, touchLocation.y-knobCenter.y}; //gets the vector of the difference between the touch location and the knob center
        float tangentVector[2] = {knobCenter.y-barCenter.y, barCenter.x-knobCenter.x}; //gets a vector tangent to the circle at the center of the knob
        float scalarProj = (touchVector[0]*tangentVector[0] + touchVector[1]*tangentVector[1])/sqrt((tangentVector[0]*tangentVector[0])+(tangentVector[1]*tangentVector[1])); //calculates the scalar projection of the touch vector onto the tangent vector
        knobAngle += scalarProj/barRadius;
        
        if (knobAngle > MAX_ANGLE) //ensure knob is always on the bar
            knobAngle = MAX_ANGLE;
        if (knobAngle < MIN_ANGLE)
            knobAngle = MIN_ANGLE;
        
        knobAngle = fmodf(knobAngle, 2*M_PI); //ensures knobAngle is always between 0 and 2*Pi
        
        [valueLabel setText:[self displayStringFromValue:[self value]]];
        
        [self setNeedsDisplay];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    isKnobBeingTouched = false;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    isKnobBeingTouched = false;
}

-(float)value
{
    float percentDone = 1.0-((knobAngle-MIN_ANGLE)/(MAX_ANGLE-MIN_ANGLE));
    return percentDone*(maxValue-minValue);
}

- (void)drawRect:(CGRect)rect
{
    //gets bar and knob coordinates based on the rectangle they're being drawn in
    barCenter.x = CGRectGetMidX(rect);
    barCenter.y = CGRectGetMidY(rect);
    barRadius = (CGRectGetHeight(rect) <= CGRectGetWidth(rect))?CGRectGetHeight(rect)/2:CGRectGetWidth(rect)/2; //gets the width or height, whichever is smallest, and stores it in radius
    barRadius = barRadius*.9;
    
    //finds the center of the knob by converting from polar to cartesian coordinates
    knobCenter.x = barCenter.x+(barRadius*cosf(knobAngle));
    knobCenter.y = barCenter.y-(barRadius*sinf(knobAngle));
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //draw the slider bar
    CGContextSetLineWidth(context, 7.0);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:212.0/255 green:162.0/255 blue:123.0/255 alpha:1.0].CGColor);
    //GContextAddArc(context,barCenter.x,barCenter.y,barRadius,fmodf(MIN_ANGLE+M_PI, 2*M_PI),fmodf(-knobAngle, 2*M_PI),0);
    //CGContextDrawPath(context, kCGPathStroke);
    //CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    //CGContextAddArc(context,barCenter.x,barCenter.y,barRadius,fmodf(-knobAngle, 2*M_PI),fmodf(MAX_ANGLE+M_PI, 2*M_PI),0);
    //CGContextAddArc(context,barCenter.x,barCenter.y,barRadius*1.05,fmodf(MIN_ANGLE, 2*M_PI),fmodf(MAX_ANGLE+M_PI, 2*M_PI),0);
    //CGContextClip(context);
    CGContextAddArc(context,barCenter.x,barCenter.y,barRadius,fmodf(MIN_ANGLE+M_PI, 2*M_PI),fmodf(MAX_ANGLE+M_PI, 2*M_PI),0);
    
    CGContextDrawPath(context, kCGPathStroke);
    
    //draw the knob
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextAddArc(context, knobCenter.x, knobCenter.y, knobRadius, 0, 2*M_PI, 1);
    /*
     //draw gradient in the knob
     CGContextClip(context);
     CGPoint knobTop = {knobCenter.x, knobCenter.y-knobRadius}, knobBottom = {knobCenter.x, knobCenter.y+knobRadius};
     CGFloat locations[2] = {0.0 ,1.0};
     CFArrayRef colors = (__bridge CFArrayRef) [NSArray arrayWithObjects:[UIColor lightGrayColor].CGColor, [UIColor whiteColor].CGColor, nil];
     CGColorSpaceRef colorSpc = CGColorSpaceCreateDeviceRGB();
     CGGradientRef gradient = CGGradientCreateWithColors(colorSpc, colors, locations);
     
     CGContextDrawLinearGradient(context, gradient, knobTop, knobBottom, 0);
     //CGContextDrawRadialGradient(context, gradient, knobCenter, knobRadius*.5, knobCenter, knobRadius, 0);
     */
    CGContextDrawPath(context, kCGPathStroke);
    //CGContextDrawPath(context, kCGPathFill);
}
-(void) layoutSubviews {
    [super layoutSubviews];
    [self displayStringFromValue:self.value];
    valueLabel.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

-(NSString *) displayStringFromValue:(float) value {
    if(self.type==0) {
        if(value<1000) {
            [delegate newOutputString:[NSString stringWithFormat:@"%.0f m",value] forType:0];
            return [NSString stringWithFormat:@"%.0f m",value];
        }
        [delegate newOutputString:[NSString stringWithFormat:@"%.1f km",value/1000] forType:0];
        return [NSString stringWithFormat:@"%.1f km",value/1000];
    }
    
    if(value<60) {
        [delegate newOutputString:[NSString stringWithFormat:@"%.0f min",value] forType:1];
        return [NSString stringWithFormat:@"%.0f min",value];
    }
    
    NSString *stunden = [NSString stringWithFormat:@"%.0f",value/60];
    NSString *minuten = [NSString stringWithFormat:@"%02.0f",value-(60*(floor(value/60.0)))];
    
    [delegate newOutputString:[NSString stringWithFormat:@"%@:%@ h",stunden,minuten] forType:1];
    return [NSString stringWithFormat:@"%@:%@ h",stunden,minuten];
    
}


@end
