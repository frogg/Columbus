//
//  DetailViewController.m
//  Columbus
//
//  Created by Frederik Riedel on 31.10.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize institutionImage,webView,scrollView;

-(id) initWithInstitution:(Institution *) institution {
    self=[super initWithNibName:nil bundle:nil];
    
    if(self) {
        self.view.backgroundColor=[UIColor whiteColor];
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-53)];
        [self.view addSubview:scrollView];
        
        self.institution=institution;
        institutionImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
        institutionImage.contentMode=UIViewContentModeScaleAspectFill;
        institutionImage.clipsToBounds=YES;
        void (^block)(UIImage *) = ^(UIImage *image) {
            [self performSelectorInBackground:@selector(blurImageInBackground:) withObject:image];
            
        };
        
        [institution performSelectorInBackground:@selector(imageUsingBlock:) withObject:block];
        
        
        
        
        [scrollView addSubview:institutionImage];
        scrollView.delegate=self;
        
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-100)];
        [scrollView addSubview:webView];
        webView.delegate=self;
        
        webView.userInteractionEnabled=YES;
        webView.scrollView.scrollEnabled=NO;
        
        webView.opaque=NO;
        webView.backgroundColor=[UIColor clearColor];
        
        void (^blocki)(NSString *) = ^(NSString *beschreibung) {
            self.institution.beschreibung=beschreibung;
            [webView loadHTMLString:[self getHTMlString] baseURL:nil];
        };
        
        
        [institution performSelectorInBackground:@selector(descriptionUsingBlock:) withObject:blocki];
        
        

        

        UIButton *google = [UIButton buttonWithType:UIButtonTypeCustom];
        [google addTarget:self action:@selector(route) forControlEvents:UIControlEventTouchUpInside];
        [google setImage:[UIImage imageNamed:@"btn_google_maps.png"] forState:UIControlStateNormal];
        google.frame=CGRectMake(0, self.view.frame.size.height-53, self.view.frame.size.width/3-1, 53);
        [self.view addSubview:google];
        
        UIButton *favorize = [UIButton buttonWithType:UIButtonTypeCustom];
        [favorize addTarget:self action:@selector(fav) forControlEvents:UIControlEventTouchUpInside];
        [favorize setImage:[UIImage imageNamed:@"btn_heart.png"] forState:UIControlStateNormal];
        favorize.frame=CGRectMake(self.view.frame.size.width/3+1, self.view.frame.size.height-53, self.view.frame.size.width/3-1, 53);
        [self.view addSubview:favorize];
        
        UIButton *map = [UIButton buttonWithType:UIButtonTypeCustom];
        [map addTarget:self action:@selector(fav) forControlEvents:UIControlEventTouchUpInside];
        [map setImage:[UIImage imageNamed:@"btn_karte.png"] forState:UIControlStateNormal];
        map.frame=CGRectMake(2*(self.view.frame.size.width/3)+2, self.view.frame.size.height-53, self.view.frame.size.width/3, 53);
        [self.view addSubview:map];
        
        UIButton *menu = [UIButton buttonWithType:UIButtonTypeCustom];
        [menu addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [menu setImage:[UIImage imageNamed:@"menu_light.png"] forState:UIControlStateNormal];
        menu.frame=CGRectMake(0, 35, 24+15, 24+15);
        [self.view addSubview:menu];
        
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [back setImage:[UIImage imageNamed:@"back_light.png"] forState:UIControlStateNormal];
        back.frame=CGRectMake(0, 35+25+10, 24+15, 24+15);
        [self.view addSubview:back];
        
        UIButton *settings = [UIButton buttonWithType:UIButtonTypeCustom];
        [settings addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [settings setImage:[UIImage imageNamed:@"settings_light.png"] forState:UIControlStateNormal];
        settings.frame=CGRectMake(self.view.frame.size.width-24-30, 35-15, 24+30, 24+15);
        [self.view addSubview:settings];
        
        
        
    }
    return self;
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

-(void) webViewDidFinishLoad:(UIWebView *)currentwebView {
    
    scrollView.contentSize=CGSizeMake(self.view.frame.size.width, currentwebView.scrollView.contentSize.height+currentwebView.frame.origin.y);
    if(currentwebView.scrollView.contentSize.height+currentwebView.frame.origin.y<scrollView.frame.size.height) {
        scrollView.contentSize=CGSizeMake(self.view.frame.size.width, scrollView.frame.size.height+1);
    }
    currentwebView.frame=CGRectMake(0, 100, self.view.frame.size.width, currentwebView.scrollView.contentSize.height);
    NSLog(@"%f",currentwebView.scrollView.contentSize.height);
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y<0) {
        institutionImage.frame=CGRectMake(0, scrollView.contentOffset.y, self.view.frame.size.width, 200-scrollView.contentOffset.y);
    } else {
        institutionImage.frame=CGRectMake(0, 0, self.view.frame.size.width, 200);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) back {
    [self dismissModalViewControllerAnimated:YES];
}

-(void) blurImageInBackground:(UIImage *) image {
    image = [image applyBlurWithRadius:10 tintColor:[UIColor colorWithRed:79.0/255 green:74.0/255 blue:69.0/255 alpha:0.7] saturationDeltaFactor:0.0 maskImage:nil];
    [institutionImage performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
}

-(NSString *) getHTMlString {
    
    return [NSString stringWithFormat:@"<html><head><style type=\"text/css\">a{color: #BD997C;}  tit {	font-size: 27;    font-family: HelveticaNeue-Medium;    color: #FFFFFF;} sub {	font-size: 17;    font-family: HelveticaNeue-light;    color: #FFFFFF;}  txt {	font-size: 15;    font-family: HelveticaNeue-light;    color: #888078;}    </style></head><center><tit>%@</tit><br><sub>%@</sub><br><br><br></center><table cellspacing=\"20\"><tr><td><txt>%@<br><br><a href='%@'><i>Read more on  Wikipedia.</i></a><br><br><br>%@</txt></td></tr></table></br></html>",self.institution.name,self.institution.type,self.institution.beschreibung,self.institution.url,[self.institution getOpeningHours]];
    #warning HIER IST NOCH EIN HARD CODE (DIE ÖFFNUNGSZEITEN)
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void) route {

    [[UIApplication sharedApplication] openURL:
     [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f?saddr=?directionsmode=walking",self.institution.location.latitude,self.institution.location.longitude]]];
}

-(void) fav {
    
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
