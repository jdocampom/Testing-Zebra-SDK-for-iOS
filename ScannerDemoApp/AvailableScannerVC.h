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
 *  Description:  AvailableScannerVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "ScannerAppEngine.h"

@interface zt_AvailableScannerVC : UITableViewController <IScannerAppEngineDevConnectionsDelegate>
{
    int m_ScannerID;
    IBOutlet UILabel *m_lblScannerID;
    IBOutlet UILabel *m_lblScannerType;
    IBOutlet UILabel *m_lblScannerName;
    BOOL m_DidAppear;
    BOOL m_ShallDisappear;
    UIActivityIndicatorView *m_BusyIndicator;
    BOOL m_IsBusy;
}

- (void)btnConnectPressed;
- (void)establishCommunicationSession;
- (void)setScannerID:(int)scannerID;
- (int)getScannerID;

@end
