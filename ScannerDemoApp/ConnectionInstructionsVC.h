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
 *  Description:  ConnectionInstructionsVC.h
 *
 *  Notes: Collection View controller used to display connection instruction 
 *         steps.
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>

typedef enum
{
    INSTRUCTION_INVALID = 0,
    INSTRUCTION_PAIR_CS4070,
    INSTRUCTION_PAIR_RFD8500,
    INSTRUCTION_PAIR_LI_DS3678,
    INSTRUCTION_PAIR_DS2278,
    INSTRUCTION_PAIR_RS5100,
    INSTRUCTION_PAIR_DS8178_BTLE,
    INSTRUCTION_PAIR_DS8178_MFI,
    INSTRUCTION_SET_DEFAULTS,

} CONNECTION_INSTRUCTION;

@interface zt_ConnectionInstructionsVC : UIViewController <UIScrollViewDelegate>

- (void) loadInstructionsFor:(CONNECTION_INSTRUCTION)instructions;

@end
