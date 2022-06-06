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
 *  Description:  ConnectionHelpSetDefaultsView.h
 *
 *  Notes: UIView used to display Set Defaults instructions
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "ConnectionHelpView.h"

@interface zt_ConnectionHelpSetDefaultsView : zt_ConnectionHelpView
 @property (retain, nonatomic) IBOutlet UILabel *lableInstructions;

@end
