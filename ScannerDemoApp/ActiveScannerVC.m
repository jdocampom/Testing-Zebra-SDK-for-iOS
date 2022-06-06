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
 *  Description:  ActiveScannerVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ActiveScannerVC.h"
#import "ActiveScannerBarcodeVC.h"
#import "config.h"
//#import "MFiScannersTableVC.h"
#import "AppSettingsKeys.h"
#import "ConnectionManager.h"
#import "BTLEScanToConnectVC.h"
//#import "MFiScannersTableVC.h"

@interface zt_ActiveScannerVC ()

@end

@implementation zt_ActiveScannerVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_ScannerID = SBT_SCANNER_ID_INVALID;
        m_WillDisappear = NO;
        [[zt_ScannerAppEngine sharedAppEngine] addDevConnectionsDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[zt_ScannerAppEngine sharedAppEngine] removeDevConnectiosDelegate:self];
    [super dealloc];
}

///A Boolean value indicating whether the toolbar at the bottom of the screen is hidden when the view controller is pushed on to a navigation controller.
-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setTitle:ACTIVE_SCANNER_TITLE];
    [[zt_ScannerAppEngine sharedAppEngine] previousScannerpreviousScanner:0];
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithTitle:ACTIVE_SCANNER_BACK_BUTTON_TITLE style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = customBackButton;
}

/// Perform your custom actions back buttom
/// @param sender  button reference
- (void) back:(UIBarButtonItem *)sender {
    [self openDisconnectAlert];
}

- (void)openDisconnectAlert{
    UIAlertController *popupMessageAlert = [UIAlertController alertControllerWithTitle:ACTIVE_SCANNER_DISCONNECT_ALERT_TITLE message:ACTIVE_SCANNER_DISCONNECT_ALERT_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:ACTIVE_SCANNER_DISCONNECT_ALERT_CANCEL style:UIAlertActionStyleDefault
                                   handler:NULL];
    UIAlertAction *contiueAction = [UIAlertAction actionWithTitle:ACTIVE_SCANNER_DISCONNECT_ALERT_CONTINUE style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
        ///Disable all virtual tether options on scanner disconnect
        [[ConnectionManager sharedConnectionManager] resetAllVirtualTetherHostAlarmSetting];
        [[ConnectionManager sharedConnectionManager] disconnect];
    }];
    
    [popupMessageAlert addAction:cancelAction];
    [popupMessageAlert addAction:contiueAction];
    [self presentViewController:popupMessageAlert animated:YES completion:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setScannerID:(int)scannerID
{
    m_ScannerID = scannerID;

        NSMutableArray *vc = [[NSMutableArray alloc] init];
        [vc addObject:[[self viewControllers] objectAtIndex:0]]; /* info tab */
        [vc addObject:[[self viewControllers] objectAtIndex:1]]; /* decode tab */
        [vc addObject:[[self viewControllers] objectAtIndex:3]]; /* settings tab tab */
        [self setViewControllers:vc];
        [vc removeAllObjects];
        [vc release];
    
}

- (int)getScannerID
{
    return m_ScannerID;
}

- (void)showBarcode
{
    [self showBarcodeList];
    [(zt_ActiveScannerBarcodeVC*)[self selectedViewController] showBarcode];
}

- (void)showBarcodeList
{
    /* it should be barcode view controller */
    [self setSelectedViewController:[self.viewControllers objectAtIndex:1]];
}


/// Open firmware update on firmware update complete
/// @param currentScannerID  connected scanner's id
//- (void)showFirmwareUpdate:(int)currentScannerID
//{
//    UpdateFirmwareVC *firmware_vc = [[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_SCANNER_FWUPDATE_DAT_VC];
//    [firmware_vc setScannerID:currentScannerID];
//    [[self navigationController] pushViewController:firmware_vc animated:NO];
//}


- (void)showSettingsPage
{
    [self setSelectedViewController:[self.viewControllers objectAtIndex:2]];
}

/* ###################################################################### */
/* ########## IScannerAppEngineDevConnectionsDelegate Protocol implementation ## */
/* ###################################################################### */
- (BOOL)scannerHasAppeared:(int)scannerID
{
    /* should not matter */
    return NO; /* we have not processed the notification */
}

- (BOOL)scannerHasDisappeared:(int)scannerID
{
    if (scannerID == m_ScannerID)
    {
        ///Keep scanner connect UI for Virutal tether alarm mode
        if ([[ConnectionManager sharedConnectionManager] getIsOnAlarmMode]){
            return NO;
        }
        for (UIViewController *vc in [self.navigationController viewControllers])
        {
            /* nrv364:
                we should pop exactly to BTLEScanToConnectVC or MFiScannersTableVC view controller
                it is actually for non active scanner as active scanner VC
                could be not on the top of the stack (e.g. symbologies or beeper/led action vc
                could be presented)
                as available scanner VC / scan to connect vc should be always on top of navigation
                stack, the available scanner VC / scan to connect VC may just pop itself
             */
            
            if ([vc isKindOfClass:[BTLEScanToConnectVC class]] == YES)
            {
                if (NO == m_WillDisappear)
                {
                    m_WillDisappear = YES;
                    [self.navigationController popToViewController:vc animated:YES];
                }
            }
//            else if([vc isKindOfClass:[MFiScannersTableVC class]] == YES)
//            {
//                if (NO == m_WillDisappear)
//                {
//                    m_WillDisappear = YES;
//                    [self.navigationController popToViewController:vc animated:YES];
//                }
//            }
        }
        return YES; /* we have processed the notification */
    }
    return NO; /* we have not processed the notification */
}

- (BOOL)scannerHasConnected:(int)scannerID
{
    /* should not matter */
    return NO; /* we have not processed the notification */
}

- (BOOL)scannerHasDisconnected:(int)scannerID
{
    if (scannerID == m_ScannerID)
    {
            ///Keep scanner connect UI for Virutal tether alarm mode
            if ([[ConnectionManager sharedConnectionManager] getIsOnAlarmMode]){
                return NO;
            }
            for (UIViewController *vc in [self.navigationController viewControllers])
            {
                /* nrv364:
                    we should pop exactly to BTLEScanToConnectVC or MFiScannersTableVC view controller
                    it is actually for non active scanner as active scanner VC
                    could be not on the top of the stack (e.g. symbologies or beeper/led action vc
                    could be presented)
                    as available scanner VC / scan to connect vc should be always on top of navigation
                    stack, the available scanner VC / scan to connect VC may just pop itself
                 */
                /* after disconnection BTLEScanToConnectVC, MFiScannersTableVC will be shown without animation;
                 the animated poping will cause UI degradation */
                
                if ([vc isKindOfClass:[BTLEScanToConnectVC class]] == YES)
                {
                    if (NO == m_WillDisappear)
                    {
                        m_WillDisappear = YES;
                        [self.navigationController popToViewController:vc animated:NO];
                    }
                }
//                else if([vc isKindOfClass:[MFiScannersTableVC class]] == YES)
//                {
//                    if (NO == m_WillDisappear)
//                    {
//                        m_WillDisappear = YES;
//                        [self.navigationController popToViewController:vc animated:NO];
//                    }
//                }
            }
        return YES; /* we have processed the notification */
    }
    return NO; /* we have not processed the notification */
}

@end
