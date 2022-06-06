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
 *  Description:  SwitchTableViewCell.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>

@protocol ISwitchTableViewCellProtocol <NSObject>
- (void) switchValueChanged:(BOOL) on aIndex:(int) index;
@end

@interface zt_SwitchTableViewCell: UITableViewCell {
    int m_Index;
    id <ISwitchTableViewCellProtocol> m_Delegate;
}

@property (retain, nonatomic) IBOutlet UILabel *cellTitle;
@property (retain, nonatomic) IBOutlet UISwitch *cellSwitch;

- (int) getIndex;
- (void) setIndex:(int) index;
- (void) setDelegate:(id <ISwitchTableViewCellProtocol>) delegate;
- (IBAction) switchSymbologyValueChanged:(id) sender;
- (void) setSwitchOn:(BOOL) on;

@end
