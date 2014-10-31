//
//  AppDelegate.m
//  Hackathon Stuttgart 2014
//
//  Created by Frederik Riedel on 31.10.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = 40;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestAlwaysAuthorization];
    locationManager.delegate = self;
    locationManager.pausesLocationUpdatesAutomatically=NO;
    
    
    UIMutableUserNotificationAction *notificationAction2 = [[UIMutableUserNotificationAction alloc] init];
    notificationAction2.identifier = @"Reject";
    notificationAction2.title = @"Boring!";
    notificationAction2.activationMode = UIUserNotificationActivationModeBackground;
    notificationAction2.destructive = YES;
    notificationAction2.authenticationRequired = NO;
    
    
    
    UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
    notificationCategory.identifier = @"Boring";
    [notificationCategory setActions:@[notificationAction2] forContext:UIUserNotificationActionContextDefault];
    
    
    NSSet *categories = [NSSet setWithObjects:notificationCategory, nil];
    
    UIUserNotificationType notificationType = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationType categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    
    
    
    
    
    MainViewController *firstView = [[MainViewController alloc] init];
    
    UINavigationController *navigationController= [[UINavigationController alloc] initWithRootViewController:firstView];
    
    self.window.rootViewController = navigationController;
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

//starts when the application switches to the background
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"background started");
    [locationManager stopUpdatingLocation];
    [locationManager startUpdatingLocation];
}

//starts automatically with locationManager
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    //    NSLog(@"Location: %f, %f", newLocation.coordinate.longitude, newLocation.coordinate.latitude);
    
    
    NSLog(@"Starting Background Server Loading Request…");
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.1.50:5000/get/locations/pushNotification/%f/%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude]]];
    
    [request setHTTPMethod:@"GET"];
    
    NSString *post = nil;
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    NSString *result =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(result);
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    
    
    NSArray *institutionen = [dic objectForKey:@"notes"];
    
    NSMutableArray *institutions = [[NSMutableArray alloc] init];
    if(institutionen && [institutionen count]>0) {
        for(NSDictionary *institutionDic in institutionen) {
            Institution *institution = [[Institution alloc] init];
            double lat = [[[institutionDic objectForKey:@"gps"] objectForKey:@"lat"] doubleValue];
            double lon = [[[institutionDic objectForKey:@"gps"] objectForKey:@"lon"] doubleValue];
            
            
            
            institution.name=[institutionDic objectForKey:@"name"];
            institution.type=[institutionDic objectForKey:@"typ"];
            institution.location=CLLocationCoordinate2DMake(lat, lon);
            
            [institutions addObject:institution];
            
        }
        
        if([institutions count]>0) {
            Institution *pushInstitution = [institutions objectAtIndex:0];
            
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = [NSDate date];
            notification.alertBody = [NSString stringWithFormat:@"%@ | %@",pushInstitution.name,pushInstitution.type];
            notification.category=@"Boring";
            notification.soundName=@"";
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            NSLog(@"Push Notification Sent");
        } else {
            NSLog(@"keine geeigneten Museen in der Nähe gefunden");
        }
    } else {
        NSLog(@"keine geeigneten Museen in der Nähe gefunden");
    }
}

//starts when application switches back from background
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [locationManager stopUpdatingLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@",error.description);
}



@end
