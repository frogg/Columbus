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
    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = 40;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestAlwaysAuthorization];
    
    NSLog(@"%f",locationManager.location.coordinate.longitude);
    locationManager.delegate = self;
    
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
    [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
}

//starts automatically with locationManager
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"Location: %f, %f", newLocation.coordinate.longitude, newLocation.coordinate.latitude);
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.sendgrid.com/api/mail.send.json"]];
    [request setHTTPMethod:@"POST"];
    
    NSString *post = nil;
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    NSString *result =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date];
    notification.alertBody = result;
    notification.category=@"Boring";
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
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




@end
