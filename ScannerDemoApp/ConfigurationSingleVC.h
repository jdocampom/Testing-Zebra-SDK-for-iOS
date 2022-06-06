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
 *  Description:  ConfigurationSingleVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "ScannerConfiguration.h"

@interface zt_ConfigurationSingleVC : UIViewController
{
    zt_ScannerConfiguration *m_Configuration;
    
    IBOutlet UIImageView *m_imgConfigurationBarcode;    
    IBOutlet UILabel *m_lblConfigurationNotice;
}

- (void)setConfiguration:(zt_ScannerConfiguration*)config;
- (void)drawConfigurationBarcode;

@end
