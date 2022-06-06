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
 *  Description:  AppSettingsVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "DownPicker.h"

@interface zt_AppSettingsVC : UITableViewController
{
    IBOutlet UITableViewCell *m_cellOpModeBTLE;
    IBOutlet UITableViewCell *m_cellOpModeMFI;
    IBOutlet UITableViewCell *m_cellOpModeBoth;
    IBOutlet UISwitch *m_swScannerDetection;
    IBOutlet UISwitch *m_swNotificationAvailable;
    IBOutlet UISwitch *m_swNotificationActive;
    IBOutlet UISwitch *m_swNotificationBarcode;
    IBOutlet UISwitch *m_swNotificationImage;
    IBOutlet UISwitch *m_swNotificationVideo;
    IBOutlet UITextField *barcodeType;
    IBOutlet UITextField *comProtocol;
    
    IBOutlet UISwitch *m_stDfltsSwitch;
    
    BOOL didNoProtocolShown;
}

- (IBAction)switchScannerDetectionValueChanged:(id)sender;
- (IBAction)switchNotificationAvailableValueChanged:(id)sender;
- (IBAction)switchNotificationActiveValueChanged:(id)sender;
- (IBAction)switchNotificationBarcodeValueChanged:(id)sender;
- (IBAction)switchNotificationImageValueChanged:(id)sender;
- (IBAction)switchNotificationVideoValueChanged:(id)sender;

@end
