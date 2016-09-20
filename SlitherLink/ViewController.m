//
//  ViewController.m
//  SlitherLink
//
//  Created by Rakesh Patole on 9/8/16.
//  Copyright © 2016 Rakesh Patole. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@dynamic view;

- (void)viewDidLoad {
    [super viewDidLoad];
    SLGrid *grid = [SLGrid gridWithSize:CGSizeMake( 7, 7)];
    [[self view] setGrid:grid];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)generateGrid:(id)sender {
    SLGrid *grid = [SLGrid gridWithSize:CGSizeMake( 7, 7)];
    [[self view] setGrid:grid];
    [[self view] setNeedsDisplay];
}

@end
