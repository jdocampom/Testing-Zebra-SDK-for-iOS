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
 *  Description:  ConnectionHelpCs4070View.h
 *
 *  Notes: UIView used to display CS4070 connection instructions
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "ConnectionHelpView.h"

@interface zt_ConnectionHelpCs4070View : zt_ConnectionHelpView
 @property (nonatomic,retain) IBOutlet UIImageView *resetFactoryDefaultsBarcodeImage;
 @property (nonatomic,retain) IBOutlet UIImageView *bluetoothMfiSsiBarcodeImage;

 @property (retain, nonatomic) IBOutlet UILabel *lableCS4070lbInstructions1;
 @property (retain, nonatomic) IBOutlet UILabel *lableCS4070lbInstructions2;
 @property (retain, nonatomic) IBOutlet UILabel *lableCS4070lbInstructions3;
 @property (retain, nonatomic) IBOutlet UILabel *lableCS4070lbInstructions4;
 @property (retain, nonatomic) IBOutlet UILabel *lableCS4070lbInstructions5;
 @property (retain, nonatomic) IBOutlet UILabel *lableCS4070lbInstructions6;

@end
