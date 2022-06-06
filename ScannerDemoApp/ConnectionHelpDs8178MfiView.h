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
 *  Description:  ConnectionHelpDs8178MfiView.h
 *
 *  Notes: UIView used to display DS8178 MFi connection instructions
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "ConnectionHelpView.h"

@interface zt_ConnectionHelpDs8178MfiView : zt_ConnectionHelpView
@property (retain, nonatomic) IBOutlet UILabel *lableDS8178Instruction1;
@property (retain, nonatomic) IBOutlet UILabel *lableDS8178Instruction2;
@property (retain, nonatomic) IBOutlet UILabel *lableDS8178Instruction3;
@property (retain, nonatomic) IBOutlet UILabel *lableDS8178Instruction4;
@property (retain, nonatomic) IBOutlet UILabel *lableDS8178Instruction5;
@property (retain, nonatomic) IBOutlet UILabel *lableDS8178Instruction6;
@property (retain, nonatomic) IBOutlet UILabel *lableDS8178Instruction7;
@end
