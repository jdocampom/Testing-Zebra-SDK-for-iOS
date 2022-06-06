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
 *  Description:  ScannerConfiguration.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ScannerConfiguration.h"

@implementation zt_ScannerConfiguration

- (id)initWithName:(NSString*)name withCode:(NSString*)code
{
    self = [super init];
    if (self != nil)
    {
        m_ConfigurationName = [[NSString alloc] initWithFormat:@"%@", name];
        m_ConfigurationCode = [[NSString alloc] initWithFormat:@"%@", code];
    }
    return self;
}

- (void)dealloc
{
    if (m_ConfigurationCode != nil)
    {
        [m_ConfigurationCode release];
    }
    
    if (m_ConfigurationName != nil)
    {
        [m_ConfigurationName release];
    }
    [super dealloc];
}

- (NSString*)getConfigurationName
{
    return m_ConfigurationName;
}

- (NSString*)getConfigurationCode
{
    return m_ConfigurationCode;
}

@end
