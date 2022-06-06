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
 *  Description:  ConnectionHelpVC.h
 *
 *  Notes: Table View controller used to navigate connection help screen
 *         for supported devices.
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>

@interface zt_ConnectionHelpVC : UITableViewController {
  IBOutlet UILabel *labelHelpCS4070Title;
  IBOutlet UILabel *labelHelpRFD8500Title;
  IBOutlet UILabel *labelHelpDS3678Title;
  IBOutlet UILabel *labelHelpDS8178Title;
  IBOutlet UILabel *labelHelpDS2278Title;
  IBOutlet UILabel *labelHelpRS5100Title;
  IBOutlet UILabel *labelHelpSetDefaultTitle;
}
@end
