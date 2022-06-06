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
 *  Description: ConfigurationListVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>

@interface zt_ConfigurationListVC : UITableViewController
{
    NSMutableArray *m_SupportedConfigurations;
    NSInteger m_SelectedIndex;
}

@end
