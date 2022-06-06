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
 *  Description:  BeeperSettingsVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "ScannerDetailsVC.h"

@interface zt_BeeperSettingsVC : ScannerDetailsVC
{
    int m_ScannerID;
    BOOL m_SettingsRetrieved;
}

- (void)setScannerID:(int)scanner_id;
- (void)getBeeperSettings;
- (void)setBeeperSettings:(NSString*)param;

@end
