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
 *  Description:  ActiveScannerInfoVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AlertView.h"
#import <UIKit/UIKit.h>

@interface zt_ActiveScannerInfoVC : UITableViewController
{
    IBOutlet UILabel *m_lblScannerName;
    BOOL m_IsBusy;
    zt_AlertView *activityView;
}

- (void)updateUI;
- (void)terminateCommunicationSession;

@end
