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
 *  Description:  ActiveScannerImageVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AlertView.h"
#import <UIKit/UIKit.h>

@interface zt_ActiveScannerImageVC : UITableViewController
{
    int m_ScannerID;
    zt_AlertView *activityView;
}

- (void)performActionTriggerPullAndRelease:(NSString*)param;

@end
