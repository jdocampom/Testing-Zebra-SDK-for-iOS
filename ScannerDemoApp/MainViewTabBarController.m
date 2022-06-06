//
//  MainViewTabBarController.m
//  ScannerDemoApp
//
//  Created by Sivarajah Pranavan on 2021-07-02.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import "MainViewTabBarController.h"
#import "UINavigationController+Theme.h"
#import "config.h"
#import "ScannerAppEngine.h"
#import "ActiveScannerVC.h"
#import "BTLEScanToConnectVC.h"
//#import "MFiScannersTableVC.h"
#import "AppSettingsKeys.h"
//#import "AboutAppVC.h"
#import "ConnectionManager.h"

@interface MainViewTabBarController ()

@end

@implementation MainViewTabBarController

///Returns an object initialized from data in a given unarchiver.
/// @param decoder An unarchiver object.
/// @return self, initialized using the data in decoder.
-(id)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self != nil)
    {
        [[zt_ScannerAppEngine sharedAppEngine] addDevEventsDelegate:self];
        [[zt_ScannerAppEngine sharedAppEngine] addDevConnectionsDelegate:self];
    }
    return self;
}


///Called after the controller's view is loaded into memory.
- (void)viewDidLoad{
    [super viewDidLoad];
    NSArray *tabbarViewControllersArray = [[NSArray alloc] initWithObjects: [self setupBleViewController], nil];
//    NSArray *tabbarViewControllersArray = [[[NSArray alloc] initWithObjects:[self setupBleViewController],[self setupMfiViewController],[self setupHelpViewController],[self setupSettingsViewController], nil] autorelease];
    [self setViewControllers:tabbarViewControllersArray];
    [self setDelegate:self];
    ///Check mode if MFI only selected then set MFI as selected tab
    NSInteger op_mode = [[NSUserDefaults standardUserDefaults] integerForKey:ZT_SETTING_OPMODE];
    if (op_mode == SBT_OPMODE_MFI) {
        [self setSelectedIndex: MFI_TAB_BAR_INDEX];
    }
    ///Virtual tether event delegate
    [[ConnectionManager sharedConnectionManager] setEventDelegate:self];
}

///Creating BLE Screen
-(id)setupBleViewController{
    UINavigationController *bleHolderNavigation = [[[UINavigationControllerTheme alloc] init] autorelease];
    [bleHolderNavigation setTabBarItem:[[UITabBarItem alloc] initWithTitle:BLE_TAB_BAR_TITLE image:[UIImage imageNamed:BLE_TAB_BAR_IMAGE] tag:TAB_BAR_TAG_0]];
    UIViewController *bleViewController = [[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_BTLE_STC_VC_IPHONE];
    [self setDelegateForBle:(id)bleViewController];
    [bleHolderNavigation showViewController:bleViewController sender:nil];
    return bleHolderNavigation;
}

/////Creating MFI Screen
//-(id)setupMfiViewController{
//    UINavigationController *mfiHolderNavigation = [[[UINavigationControllerTheme alloc] init] autorelease];
//    [mfiHolderNavigation setTabBarItem:[[UITabBarItem alloc] initWithTitle:MFI_TAB_BAR_TITLE image:[UIImage imageNamed:MFI_TAB_BAR_IMAGE] tag:TAB_BAR_TAG_1]];
//    UIViewController *mfiViewController = [[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_MFI_SCANNERS_TABLE_VC];
//    [self setDelegateForMfi:(id)mfiViewController];
//    [mfiHolderNavigation showViewController:mfiViewController sender:nil];
//    return mfiHolderNavigation;
//}
//
/////Creating Help Screen
//-(id)setupHelpViewController{
//    UINavigationController *helpHolderNavigation = [[[UINavigationControllerTheme alloc] init] autorelease];
//    [helpHolderNavigation setTabBarItem:[[UITabBarItem alloc] initWithTitle:HELP_TAB_BAR_TITLE image:[UIImage imageNamed:HELP_TAB_BAR_IMAGE] tag:TAB_BAR_TAG_2]];
//    UIViewController *helpViewController = [[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_APP_CONNECTION_HELP_VC];
//    [helpHolderNavigation showViewController:helpViewController sender:nil];
//    return helpHolderNavigation;
//}
//
/////Creating Settings Screen
//-(id)setupSettingsViewController{
//    UINavigationController *settingsHolderNavigation = [[[UINavigationControllerTheme alloc] init] autorelease];
//    [settingsHolderNavigation setTabBarItem:[[UITabBarItem alloc] initWithTitle:SETTINGS_TAB_BAR_TITLE image:[UIImage imageNamed:SETTINGS_TAB_BAR_IMAGE] tag:TAB_BAR_TAG_3]];
//    UIViewController *settingsViewController = [[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_APP_SETTINGS_VC];
//    [settingsHolderNavigation showViewController:settingsViewController sender:nil];
//    return settingsHolderNavigation;
//}


/// Asks the delegate whether the specified view controller should be made active.
/// @param tabBarController The tab bar controller containing viewController.
/// @param viewController The view controller belonging to the tab that was tapped by the user.
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    NSInteger op_mode = [[NSUserDefaults standardUserDefaults] integerForKey:ZT_SETTING_OPMODE];
    if (viewController == tabBarController.viewControllers[0]) {
        if (op_mode == SBT_OPMODE_MFI) {
            [self displayAlertForDisableMode:YES];
            return NO;
        }
    }else if (viewController == tabBarController.viewControllers[1]){
        if (op_mode == SBT_OPMODE_BTLE) {
            [self displayAlertForDisableMode:NO];
            return NO;
        }
    }
    return YES;
}


/// Display alert view for disabled op mode.
/// @param isBleDisable To check if alert for BLE or MFI
-(void)displayAlertForDisableMode:(BOOL)isBleDisabled{
    NSString *alertMessage = @"";
    if(isBleDisabled) {
        alertMessage = DISABLED_BLE_MODE_ALERT_MESSAGE;
    }else{
        alertMessage = DISABLED_MFI_MODE_ALERT_MESSAGE;
    }
    UIAlertController *popupMessageAlert = [UIAlertController alertControllerWithTitle:DISABLED_MODE_ALERT_TITLE message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:OK style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
        
    }];
    [popupMessageAlert addAction:okAction];
    [self presentViewController:popupMessageAlert animated:YES completion:nil];
}


/// Display barcode on receive bar code event
/// @param scannerId Received scanner's id for bar code
- (void) displayBarcodeFromScannerId:(int)scannerId
{
    // when a barcode is processed, automatically open the active scanner view controller
    // and show the barcode screen. this will happen no matter what screen the user is on.
    // this function will setup the view controllers to display the barcode information.
    
    // check if the active scanner vc is on top of the navigation stack.
    UIViewController *currentVisibileVC = [[self selectedViewController] visibleViewController];
    
    // Pop view when in about page

//    if ([currentVisibileVC isKindOfClass:[zt_AboutAppVC class]] == YES){
//        [[currentVisibileVC navigationController] popViewControllerAnimated:NO];
//    }
    
    // is this view controller the active scanner vc?
    if ([currentVisibileVC isKindOfClass:[zt_ActiveScannerVC class]] == YES)
    {
        // is this active scanner vc for the current scanner id?
        if ([(zt_ActiveScannerVC*)currentVisibileVC getScannerID] == scannerId)
        {
            // yes it is, show the barcode information
            [(zt_ActiveScannerVC*)currentVisibileVC showBarcode];
        }
        return;
    }
    
    //if the top view controller is not the active scanner vc but in the child view controllers
    NSArray *childViewControllersArray = [[self selectedViewController] childViewControllers];
    for(UIViewController *childViewController in childViewControllersArray){
        if ([childViewController isKindOfClass:[zt_ActiveScannerVC class]] == YES){
            // pop out the view controllers, and only include the scanner's vc
            // and the active scanner vc corresponding to the scanner id.
            if ([(zt_ActiveScannerVC*)childViewController getScannerID] == scannerId){
                // yes it is, show the barcode information
                [[(zt_ActiveScannerVC*)childViewController navigationController] popViewControllerAnimated:NO];
                [(zt_ActiveScannerVC*)childViewController showBarcode];
            }
            return;
        }
    }
    
    // the top view controller is not the active scanner vc and also not in child view controllers
    [self onBarcodeEventToRedirectFromTab:scannerId];
}


/// Show barcode list view from any main view tab.
/// @param scannerId  scanner's id to identify connected scanner and mode.
-(void)onBarcodeEventToRedirectFromTab:(int)scannerId{
    SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:scannerId];
    
    if ([scanner_info getConnectionType] == SBT_CONNTYPE_BTLE)
    {
        ///Check and select Bluetooth Low Energy tab bar on Bluetooth Low Energy barcode event
        if ([self selectedIndex] != BLE_TAB_BAR_INDEX) {
            [self setSelectedIndex:BLE_TAB_BAR_INDEX];
        }
        [self.delegateForBle showActiveScannerVC:[NSNumber numberWithInt:scannerId] aBarcodeView:YES aAnimated:NO];
    }else{
        ///Check and select MFi tab bar on MFi barcode event
        if ([self selectedIndex] != MFI_TAB_BAR_INDEX) {
            [self setSelectedIndex:MFI_TAB_BAR_INDEX];
        }
        [self.delegateForMfi showActiveScannerVC:[NSNumber numberWithInt:scannerId] aBarcodeView:YES aAnimated:NO];
    }
}


//MARK:- IScannerAppEngineDevEventsDelegate Protocol implementation

/// Received  barcode event
/// @param barcodeData Received bar code data
/// @param barcodeType Received bar code type
/// @param scannerID Scanner's id for bar code
- (void)scannerBarcodeEvent:(NSData*)barcodeData barcodeType:(int)barcodeType fromScanner:(int)scannerID
{
    [self displayBarcodeFromScannerId:scannerID];
}


/// Display scanner realted ui for notification event
/// @param scannerID Scanner id
/// @param barcode Check if event related to barcode
- (void)showScannerRelatedUI:(int)scannerID barcodeNotification:(BOOL)barcode
{
    /* do not update UI for barcode notification. the UI update to handle this
       is already accounted for in the barcode event callback */
    if (barcode == NO)
    {
        /* check whether particular scanner is available, active or disappeared */
        SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:scannerID];
        
        UINavigationController *main_navigation_vc = nil;
        UIViewController *root_vc = nil;
        
        main_navigation_vc = self.navigationController;
        root_vc = self.navigationController;
        
        /* check appearance of modal barcode event vc and destroy it */
         if (([root_vc presentedViewController] != nil) && ([[root_vc presentedViewController] isKindOfClass:[UINavigationController class]] == YES))
         {
             [root_vc dismissViewControllerAnimated:NO completion:nil];
         }
             
        /* restore initial app state -> pop to root controller */
        if ([[main_navigation_vc viewControllers] count] > 1)
        {
            /* if there are more than 1 vc in navigation stack than
             main app vc isn't a top controller */

            [main_navigation_vc popToRootViewControllerAnimated:NO];
        }
        
        /* push to scanner table vc */
        zt_ActiveScannerVC *activeScannerVC = [[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_ACTIVE_SCANNER_VC];

        [self.navigationController pushViewController:activeScannerVC animated:NO];
        
        if (scanner_info != nil)
        {
            /* particular scanner is alive, either as active or available */
            if ([scanner_info isActive] == YES)
            {
                [activeScannerVC showBarcodeList];
            }
        }
    }
}

//MARK:- IScannerAppEngineDevConnectionsDelegate Protocol implementation

/// Notify's the scanner has appered or not.
/// @param scannerId Received scanner's id from connected scanner.
- (BOOL)scannerHasAppeared:(int)scannerID
{
    return NO; /* we have not processed the notification */
}

/// Notify's the scanner has disappered or not.
/// @param scannerId Received scanner's id from connected scanner.
- (BOOL)scannerHasDisappeared:(int)scannerID
{
    return NO; /* we have not processed the notification */
}

/// Notify's the scanner has connected or not.
/// @param scannerId Received scanner's id from connected scanner.
- (BOOL)scannerHasConnected:(int)scannerID
{
    // check if the about us vc is on top of the navigation stack.
    UIViewController *currentVisibileVC = [[self selectedViewController] visibleViewController];

    // Pop view when in about page

//    if ([currentVisibileVC isKindOfClass:[zt_AboutAppVC class]] == YES){
//
//        [[currentVisibileVC navigationController] popViewControllerAnimated:NO];
//    }
    
    SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:scannerID];
    
    if ([scanner_info getConnectionType] == SBT_CONNTYPE_MFI)
    {
        ///Check and select ble tab bar on ble barcode event
        if ([self selectedIndex] != MFI_TAB_BAR_INDEX) {
            [self setSelectedIndex:MFI_TAB_BAR_INDEX];
        }
        return  NO;
    }else if ([scanner_info getConnectionType] == SBT_CONNTYPE_BTLE)
    {
        ///Check and select ble tab bar on ble barcode event
        if ([self selectedIndex] != BLE_TAB_BAR_INDEX) {
            [self setSelectedIndex:BLE_TAB_BAR_INDEX];
        }
        return  NO;
    }
    return YES; /* we have processed the notification */
}

/// Notify's the scanner has disconnected or not.
/// @param scannerId Received scanner's id from connected scanner.
- (BOOL)scannerHasDisconnected:(int)scannerID
{
    return NO; /* we have not processed the notification */
}

//MARK:- Virtual Tether Protocol implementation
- (void)showVirtualTetherRelatedUI:(int)scannerID{
    //Check if Virtual Tether UI already present
    if ([[ConnectionManager sharedConnectionManager] getIsVirtualTetherUIPresented]) {
        return;
    }
    
    // when virtual tether alarm on, automatically open virtual tether view controller
    
    SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:scannerID];
    
    if ([scanner_info getConnectionType] == SBT_CONNTYPE_BTLE)
    {
        ///Check and select Bluetooth Low Energy tab bar on Bluetooth Low Energy barcode event
        if ([self selectedIndex] != BLE_TAB_BAR_INDEX) {
            [self setSelectedIndex:BLE_TAB_BAR_INDEX];
        }
        [self.delegateForBle showVirtualTetherUI];
    }else{
        ///Check and select MFi tab bar on MFi barcode event
        if ([self selectedIndex] != MFI_TAB_BAR_INDEX) {
            [self setSelectedIndex:MFI_TAB_BAR_INDEX];
        }
        [self.delegateForMfi showVirtualTetherUI];
    }
}

- (void)dealloc {
    [_tabBarView release];
    [[zt_ScannerAppEngine sharedAppEngine] removeDevEventsDelegate:self];
    [[zt_ScannerAppEngine sharedAppEngine] removeDevConnectiosDelegate:self];
    [[ConnectionManager sharedConnectionManager] setEventDelegate:NULL];
    [self setDelegateForMfi:NULL];
    [self setDelegateForBle:NULL];
    [super dealloc];
}

@end
