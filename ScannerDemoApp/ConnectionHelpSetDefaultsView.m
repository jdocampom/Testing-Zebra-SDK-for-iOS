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
 *  Description:  ConnectionHelpSetDefaultsView.h
 *
 *  Notes: UIView used to display Set Defaults instructions
 *
 ******************************************************************************/

#import "ConnectionHelpSetDefaultsView.h"
#import "BarcodeImage.h"
#import "UIColor+DarkModeExtension.h"

@interface zt_ConnectionHelpSetDefaultsView()

@property (nonatomic,retain) IBOutlet UIImageView *setDefaultsBarcodeImage;

@end

@implementation zt_ConnectionHelpSetDefaultsView

///Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
- (void) viewWillAppear:(BOOL)animated
{
    [self darkModeCheck:self.traitCollection];
}

/// Draws the receiver’s image within the passed-in rectangle.
/// @param rect The portion of the view’s bounds that needs to be updated.
- (void)drawRect:(CGRect)rect {

    [self.setDefaultsBarcodeImage setImage:[BarcodeImage generateBarcodeImageUsingConfigCode:@"91" withHeight:self.setDefaultsBarcodeImage.frame.size.height andWidth:self.superview.frame.size.width]];
    self.setDefaultsBarcodeImage.tintColor = UIColor.whiteColor;
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.lableInstructions.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
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
