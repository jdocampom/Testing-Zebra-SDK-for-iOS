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
 *  Description:  AboutAppVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AboutAppVC.h"
#import "config.h"
#import "ScannerAppEngine.h"
#import "UIColor+DarkModeExtension.h"

@interface zt_AboutAppVC ()

@end

@implementation zt_AboutAppVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [m_lblVersion release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"About"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
    [m_lblVersion setText:[NSString stringWithFormat:@"%@ v.%@\n%@ v.%@\n\n %@ %@", ZT_INFO_SCANNER_APP_NAME, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], ZT_INFO_SCANNER_SDK_NAME, [[zt_ScannerAppEngine sharedAppEngine] getSDKVersion],  ZT_INFO_COPYRIGHT_YEAR, ZT_INFO_COPYRIGHT_TEXT]];
    [self darkModeCheck:self.traitCollection];
}

///A Boolean value indicating whether the toolbar at the bottom of the screen is hidden when the view controller is pushed on to a navigation controller.
-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}
#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor,.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    m_lblVersion.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
     
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}

@end
