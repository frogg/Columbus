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

- (void)viewDidLoad {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewDidLoad];
    self.title=@"Columbus";
    self.view.backgroundColor=[UIColor whiteColor];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(deatils) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Details" forState:UIControlStateNormal];
    button.backgroundColor=[UIColor greenColor];
    button.frame=CGRectMake(100, 100, 100, 100);
    [self.view addSubview:button];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) deatils {
    DetailViewController *suche = [[DetailViewController alloc] init];
    
    
    suche.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [self.navigationController presentViewController:suche animated:YES completion: nil];
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
