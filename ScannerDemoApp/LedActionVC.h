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
 *  Description:  LedActionVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AlertView.h"
#import <UIKit/UIKit.h>

@interface zt_LedActionVC : UITableViewController
{
    int m_ScannerID;
    NSString *m_ScannerModel;
    NSMutableArray *m_LedNames;
    NSMutableArray *m_LedValues;
    BOOL m_RequiredLedAction;
    zt_AlertView *activityView;
}

- (void)setScannerID:(int)scanner_id;
- (void)performLedAction:(NSString*)param;
- (void)performLedControl:(NSNumber*)ledCode;

@end
