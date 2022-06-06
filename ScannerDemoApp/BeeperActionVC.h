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
 *  Description:  BeeperActionVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AlertView.h"
#import <UIKit/UIKit.h>

@interface zt_BeeperActionVC : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSMutableArray *m_BeeperActionNames;
    NSMutableArray *m_BeeperActionValues;
    int m_ScannerID;
    NSString *m_ScannerModel;
    IBOutlet UIPickerView *m_ActionPicker;
    IBOutlet UIButton *m_btnBeep;
    NSInteger m_SelectedBeeperActionIndex;
    zt_AlertView *activityView;
}

- (IBAction)btnBeepPressed:(id)sender;
- (void)setScannerID:(int)scanner_id;
- (void)performBeeperAction:(NSString*)param;
- (void)performBeeperControl:(NSNumber*)beepCode;
@end
