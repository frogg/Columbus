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
@synthesize institutionOverView,aktuell;


-(id) init {
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        
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
    }
    
    return self;
}


- (void)viewDidLoad {
    
    
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
    
    Institution *i =[AktuellsteListe aktuelleListe][aktuell%[[AktuellsteListe aktuelleListe] count]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // do your background tasks here
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/post/user/profile/%@/%@?liked=false&time=0",[IP getIP],i.uuid,[LocalDataBase UUID]]]];
        //    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://google.de/%f/%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude]]];
        
        [request setHTTPMethod:@"POST"];
        
        NSString *post = nil;
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        [request setHTTPBody:postData];
        
        NSURLResponse *response;
        NSError *err;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        NSString *result =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
    });
    
    
    
    
    aktuell++;
    [institutionOverView setInstitution:[AktuellsteListe aktuelleListe][aktuell%[[AktuellsteListe aktuelleListe] count]]];
    self.institution=[AktuellsteListe aktuelleListe][aktuell%[[AktuellsteListe aktuelleListe] count]];
    
    
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
    Institution *i =[AktuellsteListe aktuelleListe][aktuell%[[AktuellsteListe aktuelleListe] count]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // do your background tasks here
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/post/user/profile/%@/%@?liked=true&time=2010",[IP getIP],i.uuid,[LocalDataBase UUID]]]];
        #warning HIER IST NOCH EIN HARD CODE (DIE ZEIT DIE ICH ES ANSCHAUE IN MILISEKUNDEN 2010)
        //    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://google.de/%f/%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude]]];
        
        [request setHTTPMethod:@"POST"];
        
        NSString *post = nil;
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        [request setHTTPBody:postData];
        
        NSURLResponse *response;
        NSError *err;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        NSString *result =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

        
    });
    
    
    
    
    aktuell++;
    [institutionOverView setInstitution:[AktuellsteListe aktuelleListe][aktuell%[[AktuellsteListe aktuelleListe] count]]];
    self.institution=[AktuellsteListe aktuelleListe][aktuell%[[AktuellsteListe aktuelleListe] count]];
    
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
