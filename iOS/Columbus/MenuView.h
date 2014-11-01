//
//  MenuView.h
//  Columbus
//
//  Created by Frederik Riedel on 01.11.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import <UIKit/UIKit.h>




@protocol MenuDelegate <NSObject>
@required
-(void) tips;
-(void) karte;


@end

@interface MenuView : UIView

@property(nonatomic)UIButton *karte;
@property(nonatomic)UIButton *tips;


-(void) einblenden;

@property(nonatomic,weak)id<MenuDelegate> delegate;

@end
