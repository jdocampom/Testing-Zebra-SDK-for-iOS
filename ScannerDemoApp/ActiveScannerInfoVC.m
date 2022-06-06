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
 *  Description:  ActiveScannerInfoVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ActiveScannerInfoVC.h"
#import "ActiveScannerVC.h"
#import "ConnectionManager.h"
#import "ScannerAppEngine.h"
#import "config.h"
//#import "LedActionVC.h"
//#import "BeeperActionVC.h"
#import "AssetDetailsVC.h"
#import "NSString+Contain.h"

typedef enum {
    SECTION_ACTIONS = 0,
    SECTION_INFORMATION,
    SECTION_DISCONNECT,
    SECTION_TOTAL
} InfoSection;

@interface zt_ActiveScannerInfoVC ()
@end

@implementation zt_ActiveScannerInfoVC

- (id) initWithCoder:(NSCoder*) aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        m_IsBusy = NO;
    }
    return self;
}


- (void) dealloc {
    [self.tableView setDataSource: nil];
    [self.tableView setDelegate: nil];
    [m_lblScannerName release];
    if (activityView != nil) {
        [activityView release];
    }
    [super dealloc];
}


- (void) viewDidLoad {
    [super viewDidLoad];
    activityView = [[zt_AlertView alloc] init];
    /// Initialize the connection manager
    [ConnectionManager sharedConnectionManager];

}


/// Sent to the view controller when the app receives a memory warning.
- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear: animated];
    [self updateUI];
}


- (void) updateUI {
    if ([self.tabBarController isKindOfClass: [zt_ActiveScannerVC class]] == YES) {
        int scanner_id = [(zt_ActiveScannerVC*)self.tabBarController getScannerID];
        SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:scanner_id];
        if (scanner_info != nil) {
            switch ([scanner_info getConnectionType]) {
//                case SBT_CONNTYPE_MFI:
//                    [m_lblScannerName setText: [NSString stringWithFormat: @"%@", [scanner_info getScannerName]]];
//                    break;
                case SBT_CONNTYPE_BTLE:
                    [m_lblScannerName setText: [NSString stringWithFormat: @"%@", [scanner_info getScannerName]]];
                    break;
            }
            return;
        }
    }
}


- (void) terminateCommunicationSession {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.tabBarController isKindOfClass:[zt_ActiveScannerVC class]] == YES) {
            [[ConnectionManager sharedConnectionManager] disconnect];
        }
        m_IsBusy = NO;
    });
}

// MARK:  - TableView Data Source

- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
    /// Return the number of sections.
    return SECTION_TOTAL;
}


- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
    switch (section) {
        case SECTION_DISCONNECT:
            return 1;
        case SECTION_INFORMATION:
            return 2;
        case SECTION_ACTIONS:
            return 2;
        default:
            return 0;
    }
}

// MARK:  - TableView Delegate

- (void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    /// Navigation logic may go here. Create and push another view controller.
//    if ([indexPath section] == SECTION_ACTIONS) /* actions section */
//    {
//        if ([indexPath row] == 0) /* Beeper */
//        {
//            zt_BeeperActionVC *beeper_vc = (zt_BeeperActionVC*)[[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_SCANNER_BEEPER_ACTION_VC];
//            
//            if (beeper_vc != nil)
//            {
//                [beeper_vc setScannerID:[(zt_ActiveScannerVC*)self.tabBarController getScannerID]];
//                [self.navigationController pushViewController:beeper_vc animated:YES];
//                /* beeper_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
//            }
//        }
//        else if ([indexPath row] == 1) /* LED */
//        {
//            zt_LedActionVC *led_vc = (zt_LedActionVC*)[[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_SCANNER_LED_ACTION_VC];
//            
//            if (led_vc != nil)
//            {
//                [led_vc setScannerID:[(zt_ActiveScannerVC*)self.tabBarController getScannerID]];
//                [self.navigationController pushViewController:led_vc animated:YES];
//                /* led_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
//            }
//        }
//    }
    
    if (([indexPath section] == SECTION_DISCONNECT) && ([indexPath row] == 0)) {
        if (NO == m_IsBusy) {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle: ACTIVE_SCANNER_DISCONNECT_ALERT_TITLE message: ZT_SCANNER_DISCONNECT_SCANNER_FROM_APPLICATION_MESSAGE preferredStyle: UIAlertControllerStyleAlert];
            UIAlertAction* yesButton = [UIAlertAction actionWithTitle: ACTIVE_SCANNER_BARCODE_ALERT_CANCEL style: UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                /// Handle your yes please button action here
            }];
            UIAlertAction* noButton = [UIAlertAction actionWithTitle: ACTIVE_SCANNER_BARCODE_ALERT_CONTINUE style: UIAlertActionStyleDefault handler: ^(UIAlertAction * action) {
                m_IsBusy = YES;
                /// Disable all virtual tether options on new scanner disconnect
                [[ConnectionManager sharedConnectionManager] resetAllVirtualTetherHostAlarmSetting];
                [activityView showAlertWithView: self.view withTarget: self withMethod: @selector(terminateCommunicationSession) withObject: nil withString: ZT_SCANNER_DISCONNECTING_MESSAGE];
            }];
            [alert addAction: yesButton];
            [alert addAction: noButton];
            [self presentViewController: alert animated: YES completion: nil];
            [alert release];
        }
    }
    if ([indexPath section] == SECTION_INFORMATION && [indexPath row] == 1) {
        AssetDetailsVC *assets_vc = nil;
        assets_vc = (AssetDetailsVC*)[[UIStoryboard storyboardWithName: SCANNER_STORY_BOARD bundle: [NSBundle mainBundle]] instantiateViewControllerWithIdentifier: ID_ASSET_DETAILS_VC];
        if (assets_vc != nil) {
            SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID: [(zt_ActiveScannerVC*)self.tabBarController getScannerID]];
            [assets_vc setScanner_info: scanner_info];
            [self.navigationController pushViewController: assets_vc animated: YES];
        }
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    if (cell != nil) {
        [tableView deselectRowAtIndexPath: indexPath animated: YES];
//        [cell setSelected: NO animated: YES];
    }
}

@end
