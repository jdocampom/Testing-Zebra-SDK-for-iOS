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
 *  Description:  ScannerConfiguration.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>

@interface zt_ScannerConfiguration: NSObject {
    NSString *m_ConfigurationName;
    NSString *m_ConfigurationCode;
}

- (id) initWithName:(NSString*)name withCode:(NSString*) code;
- (NSString*) getConfigurationName;
- (NSString*) getConfigurationCode;

@end
