//
//  KarteViewController.m
//  Columbus
//
//  Created by Frederik Riedel on 31.10.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import "KarteViewController.h"

@interface KarteViewController ()

@end

@implementation KarteViewController
@synthesize mapView;
- (void)viewDidLoad {
    [super viewDidLoad];
    RMMapboxSource *onlineSource = [[RMMapboxSource alloc] initWithMapID:@"quappi.k416b1d9"];
    
    mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:onlineSource];
    
    mapView.zoom = 2;
    
    [self.view addSubview:mapView];
    
    
    for(Institution *i in [AktuellsteListe aktuelleListe]) {
        RMPointAnnotation *annotation = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                        coordinate:i.location
                                                                          andTitle:i.name];
        
        [mapView addAnnotation:annotation];
    }
    [self zoomToFitAllAnnotationsAnimated:YES];

    mapView.showsUserLocation=YES;

    
    
    UIButton *menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [menu addTarget:self action:@selector(menu) forControlEvents:UIControlEventTouchUpInside];
    [menu setImage:[UIImage imageNamed:@"menu_light.png"] forState:UIControlStateNormal];
    menu.frame=CGRectMake(15, 35, 24, 24);
    [self.view addSubview:menu];
    
    UIButton *settings = [UIButton buttonWithType:UIButtonTypeCustom];
    [settings addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchUpInside];
    [settings setImage:[UIImage imageNamed:@"settings_light.png"] forState:UIControlStateNormal];
    settings.frame=CGRectMake(self.view.frame.size.width-24-15, 35, 24, 24);
    [self.view addSubview:settings];
    [self setNeedsStatusBarAppearanceUpdate];
    // Do any additional setup after loading the view.
}


-(void)zoomToFitAllAnnotationsAnimated:(BOOL)animated {
    
    NSArray *annotations = mapView.annotations;
    
    if (annotations.count > 0) {
        
        CLLocationCoordinate2D firstCoordinate = [[annotations objectAtIndex:0]coordinate];
        
        //Find the southwest and northeast point
        double northEastLatitude = firstCoordinate.latitude;
        double northEastLongitude = firstCoordinate.longitude;
        double southWestLatitude = firstCoordinate.latitude;
        double southWestLongitude = firstCoordinate.longitude;
        
        for (RMAnnotation *annotation in annotations) {
            CLLocationCoordinate2D coordinate = annotation.coordinate;
            
            northEastLatitude = MAX(northEastLatitude, coordinate.latitude);
            northEastLongitude = MAX(northEastLongitude, coordinate.longitude);
            southWestLatitude = MIN(southWestLatitude, coordinate.latitude);
            southWestLongitude = MIN(southWestLongitude, coordinate.longitude);
            
            
        }
        //Define a margin so the corner annotations aren't flush to the edges
        double margin = 0.005;
        
        [mapView zoomWithLatitudeLongitudeBoundsSouthWest:CLLocationCoordinate2DMake(southWestLatitude-margin, southWestLongitude-margin)
                                             northEast:CLLocationCoordinate2DMake(northEastLatitude+margin, northEastLongitude+margin)
                                              animated:animated];
        
    }
    
    
}



-(void) menu {
    MenuView *menu = [[MenuView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:menu];
    menu.delegate=self;
    [menu einblenden];
}

-(void) settings {
    SettingsViewController *settings = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settings animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void) tips {
    MainViewController *tips = [[MainViewController alloc] init];
    [tips newInstitution:[AktuellsteListe aktuelleListe][0]];
    [self.navigationController pushViewController:tips animated:YES];
}

-(void) karte {
    
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
