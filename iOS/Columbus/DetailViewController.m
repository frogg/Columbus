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
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor blueColor];
    
    
    institutionImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    [self performSelectorInBackground:@selector(blurImageInBackground:) withObject:[UIImage imageNamed:@"default.png"]];
    [self.view addSubview:institutionImage];
    
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Zurück" forState:UIControlStateNormal];
    button.backgroundColor=[UIColor greenColor];
    button.frame=CGRectMake(100, 100, 100, 100);
    [self.view addSubview:button];
    
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, self.view.frame.size.height-200)];
    [self.view addSubview:webView];
    [webView loadHTMLString:@"TEST<br><b>Test</b>" baseURL:nil];
    
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
    image = [image applyBlurWithRadius:10 tintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0] saturationDeltaFactor:0.0 maskImage:nil];
    [institutionImage performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
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
