//
//  UINavigationController+Theme.m
//  ScannerDemoApp
//
//  Created by Sivarajah Pranavan on 2021-07-02.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "UINavigationController+Theme.h"
#import "UIColor+DarkModeExtension.h"

@implementation UINavigationControllerTheme

///Called after the controller's view is loaded into memory.
-(void)viewDidLoad{
    ///Set title text to white color
    NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIColor whiteColor],NSForegroundColorAttributeName,nil];
    self.navigationBar.titleTextAttributes = titleTextAttributes;
    ///Set Navigation bar color
    [[self navigationBar] setBarTintColor:[UIColor getAppPrimaryColor]];
    [[self navigationBar] setTintColor:[UIColor whiteColor]];
}

///Set status bar to light content
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
