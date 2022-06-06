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
 *  Description:  Symbology.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "Symbology.h"

@implementation zt_Symbology

- (id)init:(NSString*)name aRMDAttr:(int)attr_id
{
    self = [super init];
    if (self != nil)
    {
        m_SymbologyName = [[NSString alloc] initWithFormat:@"%@", name];
        m_RMDAttributeID = attr_id;
        m_Enabled = NO;
        m_Supported = NO;
    }
    return self;
}

- (void)dealloc
{
    if (m_SymbologyName != nil)
    {
        [m_SymbologyName release];
    }

    [super dealloc];
}

- (int)getRMDAttributeID
{
    return m_RMDAttributeID;
}

- (BOOL)isEnabled
{
    return m_Enabled;
}

- (NSString*)getSymbologyName
{
    return m_SymbologyName;
}

- (void)setEnabled:(BOOL)enabled
{
    m_Enabled = enabled;
}

- (BOOL)isSupported
{
    return m_Supported;
}

- (void)setSupported:(BOOL)supported
{
    m_Supported = supported;
}

@end
