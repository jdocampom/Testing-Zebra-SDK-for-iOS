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
 *  Description:  AppSettingsBackgroundVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>

@interface zt_AppSettingsBackgroundVC : UITableViewController
{
    IBOutlet UISwitch *m_swNotificationAvailable;
    IBOutlet UISwitch *m_swNotificationActive;
    IBOutlet UISwitch *m_swNotificationBarcode;
    IBOutlet UISwitch *m_swNotificationImage;
    IBOutlet UISwitch *m_swNotificationVideo;
}

- (IBAction)switchNotificationAvailableValueChanged:(id)sender;
- (IBAction)switchNotificationActiveValueChanged:(id)sender;
- (IBAction)switchNotificationBarcodeValueChanged:(id)sender;
- (IBAction)switchNotificationImageValueChanged:(id)sender;
- (IBAction)switchNotificationVideoValueChanged:(id)sender;

@end
