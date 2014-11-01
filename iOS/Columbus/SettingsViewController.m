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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor darkGrayColor];
    CircularSliderView *maxdistance = [[CircularSliderView alloc] initWithMinValue:100 maxValue:2000 initialValue:250 withType:0];
    maxdistance.frame=CGRectMake(0, 30, self.view.frame.size.width, 230);
    maxdistance.clipsToBounds=NO;
    [self.view addSubview:maxdistance];
    
    
    CircularSliderView *sliderView = [[CircularSliderView alloc] initWithMinValue:10 maxValue:180 initialValue:60 withType:1];
    sliderView.frame=CGRectMake(0, 330, self.view.frame.size.width, 230);
    sliderView.clipsToBounds=NO;
    [self.view addSubview:sliderView];
    

    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
