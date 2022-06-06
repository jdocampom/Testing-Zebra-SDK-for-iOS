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
 *  Description:  ActiveScannerSettingsVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AlertView.h"
#import <UIKit/UIKit.h>

@interface zt_ActiveScannerSettingsVC : UITableViewController
{
    int m_ScannerID;
    BOOL m_HideBeeperSettings;
    zt_AlertView *activityView;
}

- (void)performActionScanEnable:(NSString*)param;
- (void)performActionScanDisable:(NSString*)param;

@end
