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
 *  Description:  SymbologiesVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "SwitchTableViewCell.h"
#import "ScannerDetailsVC.h"

@interface zt_SymbologiesVC : ScannerDetailsVC <ISwitchTableViewCellProtocol>
{
    NSMutableArray *m_Symbologies;
    int m_ScannerID;
    BOOL m_SymbologiesRetrieved;
}

- (void)setScannerID:(int)scanner_id;
- (void)getSymbologiesConfiguration;
- (void)setSymbologyConfiguration:(NSString*)param withIndex:(int)index withStatuc:(BOOL)isON;

@end
