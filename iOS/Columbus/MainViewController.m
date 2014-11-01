//
//  MainViewController.m
//  Hackathon Stuttgart 2014
//
//  Created by Frederik Riedel on 31.10.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize institutionOverView;
int aktuell=0;
- (void)viewDidLoad {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewDidLoad];
    self.title=@"Columbus";
    self.view.backgroundColor=[UIColor whiteColor];
    
    

    
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:self.view.frame];
    image.image=[UIImage imageNamed:@"loading_screen.png"];
    image.contentMode=UIViewContentModeScaleAspectFill;
    [self.view addSubview:image];
    
        [UIView animateWithDuration:0.5
                              delay:2
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             image.alpha=0;
         }
                         completion:^(BOOL finished)
         {
         }];

    institutionOverView = [[InstitutionOverviewView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:institutionOverView];
    institutionOverView.delegate=self;
    
    UIButton *menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [menu addTarget:self action:@selector(menu) forControlEvents:UIControlEventTouchUpInside];
    [menu setImage:[UIImage imageNamed:@"menu_dark.png"] forState:UIControlStateNormal];
    menu.frame=CGRectMake(0, 35-15, 24+15, 24+15);
    [self.view addSubview:menu];
    
    UIButton *settings = [UIButton buttonWithType:UIButtonTypeCustom];
    [settings addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchUpInside];
    [settings setImage:[UIImage imageNamed:@"settings_dark.png"] forState:UIControlStateNormal];
    settings.frame=CGRectMake(self.view.frame.size.width-24-30, 35-15, 24+30, 24+15);
    [self.view addSubview:settings];
    
    // Do any additional setup after loading the view.
}

-(void) menu {
    //KarteViewController *k = [[KarteViewController alloc] init];
    //[self.navigationController pushViewController:k animated:YES];
    
    
    MenuView *menu = [[MenuView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:menu];
    menu.delegate=self;
    [menu einblenden];
}

-(void) tips {
    
}

-(void) karte {
    KarteViewController *karte = [[KarteViewController alloc] init];
    [self.navigationController pushViewController:karte animated:YES];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) boring {
    aktuell++;
    [institutionOverView setInstitution:[AktuellsteListe aktuelleListe][aktuell]];
    
    
    
    CATransition *animation = [CATransition animation];
    animation.type = @"suckEffect";
    animation.duration = 0.7f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    [institutionOverView.layer addAnimation:animation forKey:@"transitionViewAnimation"];
    
}

-(void) details {
    DetailViewController *detail = [[DetailViewController alloc] initWithInstitution:self.institution];
    detail.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.navigationController presentViewController:detail animated:YES completion: nil];
}

-(void) like {
    aktuell++;
    [institutionOverView setInstitution:[AktuellsteListe aktuelleListe][aktuell]];
    
    CATransition *animation = [CATransition animation];
    animation.type = @"rippleEffect";
    animation.duration = 0.7f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    [institutionOverView.layer addAnimation:animation forKey:@"transitionViewAnimation"];
}

-(void) settings {
    SettingsViewController *settings = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settings animated:YES];
}

-(void) newInstitution:(Institution *) institutionneu {
    
    self.institution=institutionneu;
    [institutionOverView setInstitution:self.institution];

}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
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
