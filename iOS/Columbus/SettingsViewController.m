//
//  SettingsViewController.m
//  Columbus
//
//  Created by Frederik Riedel on 01.11.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize frequenzDetail,radiusDetail;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor darkGrayColor];
    CircularSliderView *maxdistance = [[CircularSliderView alloc] initWithMinValue:100 maxValue:2000 initialValue:250 withType:0];
    maxdistance.frame=CGRectMake(0, 20, self.view.frame.size.width, 200);
    maxdistance.clipsToBounds=NO;
    [self.view addSubview:maxdistance];
    maxdistance.delegate=self;
    
    UILabel *radius = [[UILabel alloc] initWithFrame:CGRectMake(0, 210, self.view.frame.size.width, 44)];
    radius.font=[UIFont fontWithName:@"Helveticaneue-ultralight" size:35];
    radius.text=@"Radius";
    radius.textColor=[UIColor whiteColor];
    radius.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:radius];
    
    
    radiusDetail = [[UILabel alloc] initWithFrame:CGRectMake(50, 254, self.view.frame.size.width-100, 60)];
    [self.view addSubview:radiusDetail];
    radiusDetail.font=[UIFont fontWithName:@"Helveticaneue-ultralight" size:17];
    radiusDetail.numberOfLines=-1;
    radiusDetail.textColor=[UIColor whiteColor];
    radiusDetail.textAlignment=NSTextAlignmentCenter;
    
    UIImageView *trenner = [[UIImageView alloc] initWithFrame:CGRectMake(0, 335, self.view.frame.size.width, 20)];
    trenner.image=[UIImage imageNamed:@"settings_trenner.png"];
    trenner.contentMode=UIViewContentModeScaleAspectFit;
    [self.view addSubview:trenner];
    
    CircularSliderView *sliderView = [[CircularSliderView alloc] initWithMinValue:10 maxValue:180 initialValue:10 withType:1];
    sliderView.frame=CGRectMake(0, 370, self.view.frame.size.width, 200);
    sliderView.clipsToBounds=NO;

    [self.view addSubview:sliderView];
    sliderView.delegate=self;
    
    
    

    UILabel *frequenz = [[UILabel alloc] initWithFrame:CGRectMake(0, 330+230, self.view.frame.size.width, 44)];
    frequenz.font=[UIFont fontWithName:@"Helveticaneue-ultralight" size:35];
    frequenz.text=@"Frequenz";
    frequenz.textColor=[UIColor whiteColor];
    frequenz.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:frequenz];
    
    frequenzDetail = [[UILabel alloc] initWithFrame:CGRectMake(50, 330+230+44, self.view.frame.size.width-100, 60)];
    [self.view addSubview:frequenzDetail];
    frequenzDetail.font=[UIFont fontWithName:@"Helveticaneue-ultralight" size:17];
    frequenzDetail.numberOfLines=-1;
    frequenzDetail.textColor=[UIColor whiteColor];
    frequenzDetail.textAlignment=NSTextAlignmentCenter;
    
    
    UIButton *menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [menu addTarget:self action:@selector(menu) forControlEvents:UIControlEventTouchUpInside];
    [menu setImage:[UIImage imageNamed:@"menu_light.png"] forState:UIControlStateNormal];
    menu.frame=CGRectMake(0, 35, 24+15, 24+15);
    [self.view addSubview:menu];
    
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [back setImage:[UIImage imageNamed:@"back_light.png"] forState:UIControlStateNormal];
    back.frame=CGRectMake(0, 35+25+15, 24+15, 24+15);
    [self.view addSubview:back];

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) back {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) menu {
    MenuView *menu = [[MenuView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:menu];
    [menu einblenden];
}

-(void) newOutputString:(NSString *)string forType:(int)type {
    if(type==0) {
        radiusDetail.text=[NSString stringWithFormat:@"Einrichtungen im Umkreis von %@ suchen.",string];
    }
    if(type==1) {
        frequenzDetail.text=[NSString stringWithFormat:@"Alle %@ nach neuen Einrichtungen suchen.",string];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
