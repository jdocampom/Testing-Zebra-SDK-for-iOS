/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  ConnectionHelpCs4070View.h
 *
 *  Notes: UIView used to display CS4070 connection instructions
 *
 ******************************************************************************/

#import "ConnectionHelpCs4070View.h"
#import "BarcodeImage.h"
#import "UIColor+DarkModeExtension.h"


@implementation zt_ConnectionHelpCs4070View

///Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
- (void) viewWillAppear:(BOOL)animated
{
    [self darkModeCheck:self.traitCollection];
}

/// Draws the receiver’s image within the passed-in rectangle.
/// @param rect The portion of the view’s bounds that needs to be updated.
- (void)drawRect:(CGRect)rect {

    [self.resetFactoryDefaultsBarcodeImage setImage:[BarcodeImage generateBarcodeImageUsingConfigCode:@"L01" withHeight:self.resetFactoryDefaultsBarcodeImage.frame.size.height andWidth:self.superview.frame.size.width]];
    
    [self.bluetoothMfiSsiBarcodeImage setImage:[BarcodeImage generateBarcodeImageUsingConfigCode:@"N051704" withHeight:self.bluetoothMfiSsiBarcodeImage.frame.size.height andWidth:self.superview.frame.size.width]];
}

/// Deallocates the memory occupied by the receiver.
- (void)dealloc {
    [_resetFactoryDefaultsBarcodeImage release];
    [_bluetoothMfiSsiBarcodeImage release];
    [super dealloc];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.lableCS4070lbInstructions1.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.lableCS4070lbInstructions2.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.lableCS4070lbInstructions3.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.lableCS4070lbInstructions4.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.lableCS4070lbInstructions5.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.lableCS4070lbInstructions6.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
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
