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
static Institution *lastPush;
@implementation AppDelegate

bool openedFromNotification;

BOOL firststart;
long lastPushNotificationTimeStamp;

@synthesize locationManager,firstView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [LocalDataBase checkIfUserIsAlreadyRegistered];
    firststart=true;
    self.window = [[MBFingerTipWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
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
    
    
    
    
    
    
    firstView = [[MainViewController alloc] init];
    
    UINavigationController *navigationController= [[UINavigationController alloc] initWithRootViewController:firstView];
    
    self.window.rootViewController = navigationController;
    
    [locationManager startUpdatingLocation];
    [navigationController setNavigationBarHidden:YES animated:NO];
    
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // do your background tasks here
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/get/articles/%f/%f?radius=%@&user=%@",[IP getIP],newLocation.coordinate.latitude,newLocation.coordinate.longitude,[LocalDataBase meter],[LocalDataBase UUID]]]];
        
        //NSLog([NSString stringWithFormat:@"http://%@/get/articles/%f/%f?radius=1000&user=%@",[IP getIP],newLocation.coordinate.latitude,newLocation.coordinate.longitude,[LocalDataBase UUID]]);
        //    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://google.de/%f/%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude]]];
        
        [request setHTTPMethod:@"GET"];
        
        NSString *post = nil;
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        [request setHTTPBody:postData];
        
        NSURLResponse *response;
        NSError *err;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        
        // when that method finishes you can run whatever you need to on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            if(responseData) {
                //NSString *result =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                //NSLog(result);
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                
                
                NSArray *institutionen = [dic objectForKey:@"notes"];
                
                NSMutableArray *institutions = [[NSMutableArray alloc] init];
                
                
                
                if(institutionen && [institutionen count]>0) {
                    for(NSDictionary *institutionDic in institutionen) {
                        Institution *institution = [[Institution alloc] init];
                        double lat = [[[institutionDic objectForKey:@"gps"] objectForKey:@"lat"] doubleValue];
                        double lon = [[[institutionDic objectForKey:@"gps"] objectForKey:@"lon"] doubleValue];
                        
                        
                        
                        institution.name=[institutionDic objectForKey:@"name"];
                        
                        institution.imageURL=[institutionDic objectForKey:@"imageurl"];
                        institution.location=CLLocationCoordinate2DMake(lat, lon);
                        institution.distance= [newLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:institution.location.latitude longitude:institution.location.longitude]];
                        
                        institution.uuid=[institutionDic objectForKey:@"pageid"];
                        institution.openingHours=[institutionDic objectForKey:@"opening_hours"];
                        institution.url=[institutionDic objectForKey:@"url"];

                        NSLog(institution.openingHours.description);
                       

                       
                        NSLog(@"Öffnungszeiten%@", [institution getOpeningHours]);

                        
                        
                        institution.keywords=[institutionDic objectForKey:@"schlagworte"];
                        if([institutionDic objectForKey:@"address"]!=[NSNull null]) {
                            institution.stadt=[[[[[institutionDic objectForKey:@"address"] componentsSeparatedByString:@", Germany"] objectAtIndex:0] componentsSeparatedByString:@" "] lastObject];
                        } else {
                            institution.stadt=@"";
                        }
                        
                        if([institutionDic objectForKey:@"type"]!=[NSNull null]) {
                            institution.type=[institutionDic objectForKey:@"type"];
                        } else {
                            institution.type=@"";
                        }
                        
                        [institutions addObject:institution];
                        
                    }
                    
                    [AktuellsteListe aktuelleListe:institutions];
                    
                    if([institutions count]>0) {
                        Institution *pushInstitution = [institutions objectAtIndex:0];
                        lastPush=pushInstitution;
                        
                        UILocalNotification *notification = [[UILocalNotification alloc] init];
                        notification.fireDate = [NSDate date];
                        notification.alertBody = [NSString stringWithFormat:@"%@ | %.0f m",pushInstitution.name,pushInstitution.distance];
                        notification.category=@"Boring";
                        notification.soundName=@"Widdewiddewiddbummbumm.mp3";
                        
                        if([[NSDate date] timeIntervalSince1970]-lastPushNotificationTimeStamp>=[[LocalDataBase time] intValue]*60) {
                            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                            NSLog(@"Push Notification Sent");
                            if ( [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
                                lastPushNotificationTimeStamp=[[NSDate date] timeIntervalSince1970];
                                NSLog(@"timer refreshed");
                            } else {
                                NSLog(@"timer not refrehed, because app is active");
                            }
                        } else {
                            NSLog(@"push not sent, user settings");
                        }
                        
                    } else {
                        NSLog(@"1keine geeigneten Museen in der Nähe gefunden");
                    }
                } else {
                    NSLog(@"2keine geeigneten Museen in der Nähe gefunden");
                }
            } else {
                NSLog(@"Server nicht verfügbar.");
            }
        });
    });
    
    
    
    
    
    /*
     UILocalNotification *notification = [[UILocalNotification alloc] init];
     notification.fireDate = [NSDate date];
     notification.alertBody = [NSString stringWithFormat:@"bla bla bla"];
     notification.category=@"Boring";
     notification.soundName=@"";
     [[UIApplication sharedApplication] scheduleLocalNotification:notification];
     
     lastPush = [[Institution alloc] init];
     lastPush.name=@"test";
     */
}


//starts when application switches back from background
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [locationManager stopUpdatingLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@",error.description);
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(NSDictionary *)userInfo {
    
    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  || firststart)
    {
        openedFromNotification=YES;
        [firstView newInstitution:lastPush];
        [self.firstView.navigationController popToRootViewControllerAnimated:YES];
        NSLog(@"YES");
        firststart=false;
    }
    
}


@end
