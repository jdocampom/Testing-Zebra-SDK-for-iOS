//
//  ConnectionHelpRFD8500.m
//  ScannerDemoApp
//
//  Created by Adrian Danushka on 9/8/20.
//  Copyright © 2020 Alexei Igumnov. All rights reserved.
//

#import "ConnectionHelpRFD8500.h"
#import "UIColor+DarkModeExtension.h"

/// The implementation of connection help page for RFD8500
@implementation ConnectionHelpRFD8500

///Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
- (void) viewWillAppear:(BOOL)animated
{
    [self darkModeCheck:self.traitCollection];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor,.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    lableInstructionsRFD8500.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.backgroundColor =  [UIColor getDarkModeViewBackgroundColor:traitCollection];
   
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}
@end
