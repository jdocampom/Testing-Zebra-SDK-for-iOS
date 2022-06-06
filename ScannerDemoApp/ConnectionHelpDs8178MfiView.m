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
 *  Description:  ConnectionHelpDs8178View.h
 *
 *  Notes: UIView used to display DS8178 MFi connection instructions
 *
 ******************************************************************************/

#import "ConnectionHelpDs8178MfiView.h"
#import "BarcodeImage.h"
#import "UIColor+DarkModeExtension.h"

@interface zt_ConnectionHelpDs8178MfiView()

@property (nonatomic,retain) IBOutlet UIImageView *resetFactoryDefaultsBarcodeImage;
@property (nonatomic,retain) IBOutlet UIImageView *bluetoothMfiSsiBarcodeImage;

@end

@implementation zt_ConnectionHelpDs8178MfiView

///Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
- (void) viewWillAppear:(BOOL)animated
{
    [self darkModeCheck:self.traitCollection];
}

/// Draws the receiver’s image within the passed-in rectangle.
/// @param rect The portion of the view’s bounds that needs to be updated.
- (void)drawRect:(CGRect)rect {

    [self.resetFactoryDefaultsBarcodeImage setImage:[BarcodeImage generateBarcodeImageUsingConfigCode:@"92" withHeight:self.resetFactoryDefaultsBarcodeImage.frame.size.height andWidth:self.superview.frame.size.width]];
    
    [self.bluetoothMfiSsiBarcodeImage setImage:[BarcodeImage generateBarcodeImageUsingConfigCode:@"N017F13" withHeight:self.bluetoothMfiSsiBarcodeImage.frame.size.height andWidth:self.superview.frame.size.width]];
}


#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.lableDS8178Instruction1.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.lableDS8178Instruction2.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.lableDS8178Instruction3.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.lableDS8178Instruction4.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.lableDS8178Instruction5.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.lableDS8178Instruction6.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.lableDS8178Instruction7.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
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
