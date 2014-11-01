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
@synthesize institutionImage,webView;

-(id) initWithInstitution:(Institution *) institution {
    self=[super initWithNibName:nil bundle:nil];
    
    if(self) {
        self.view.backgroundColor=[UIColor whiteColor];
        self.institution=institution;
        institutionImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
        institutionImage.contentMode=UIViewContentModeScaleAspectFill;
        institutionImage.clipsToBounds=YES;
        void (^block)(UIImage *) = ^(UIImage *image) {
            [self performSelectorInBackground:@selector(blurImageInBackground:) withObject:image];
        };
        
        [institution performSelectorInBackground:@selector(imageUsingBlock:) withObject:block];
        
        
        
        
        [self.view addSubview:institutionImage];
        
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-100)];
        [self.view addSubview:webView];
        
        
        
        
        webView.opaque=NO;
        webView.backgroundColor=[UIColor clearColor];
        
        void (^blocki)(NSString *) = ^(NSString *beschreibung) {
            self.institution.beschreibung=beschreibung;
            [webView loadHTMLString:[self getHTMlString] baseURL:nil];
        };
        
        
        [institution performSelectorInBackground:@selector(descriptionUsingBlock:) withObject:blocki];
        
        
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [back setImage:[UIImage imageNamed:@"back_light.png"] forState:UIControlStateNormal];
        back.frame=CGRectMake(15, 35, 24, 24);
        [self.view addSubview:back];
        
        [webView loadHTMLString:[self getHTMlString] baseURL:nil];
        
    }
    return self;
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
    image = [image applyBlurWithRadius:10 tintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6] saturationDeltaFactor:1.0 maskImage:nil];
    [institutionImage performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
}

-(NSString *) getHTMlString {
    
    return [NSString stringWithFormat:@"<html><head><style type=\"text/css\">a{color: #BD997C;}  tit {	font-size: 27;    font-family: HelveticaNeue-Medium;    color: #BD997C;} sub {	font-size: 17;    font-family: HelveticaNeue-light;    color: #BD997C;}  txt {	font-size: 17;    font-family: HelveticaNeue-light;    color: #000000;}    </style></head><center><tit>%@</tit><br><sub>%@</sub><br><br><br><br></center><txt>%@<br><br><a href=''><i>Read more on  Wikipedia.</i></a><br><br><br>Hours of opening:<br>SU: 10:00 - 19:00</txt></br></html>",self.institution.name,self.institution.type,self.institution.beschreibung];
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
