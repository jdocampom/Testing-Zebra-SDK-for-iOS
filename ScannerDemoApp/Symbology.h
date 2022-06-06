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
 *  Description:  Symbology.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>

@interface zt_Symbology: NSObject {
    NSString *m_SymbologyName;
    int m_RMDAttributeID;
    BOOL m_Enabled;
    BOOL m_Supported;
}

- (id) init:(NSString*)name aRMDAttr:(int)attr_id;
- (void) dealloc;
- (int) getRMDAttributeID;
- (BOOL) isEnabled;
- (NSString*) getSymbologyName;
- (void) setEnabled:(BOOL) enabled;
- (BOOL) isSupported;
- (void) setSupported:(BOOL) supported;

@end
