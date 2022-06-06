//
//  DCSBasicVC.m
//  ScannerSDKApp
//
//  Created by pqj647 on 8/1/16.
//  Copyright © 2016 Alexei Igumnov. All rights reserved.
//

#import "DCSBasicVC.h"

@interface DCSBasicVC ()

@end

@implementation DCSBasicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:self.backBTNName style:UIBarButtonItemStylePlain target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)backPressed:(id)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
