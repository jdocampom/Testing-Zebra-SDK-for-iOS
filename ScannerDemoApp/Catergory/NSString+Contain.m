//
//  NSString+Contain.m
//  ScannerDemoApp
//
//  Created by Adrian Danushka on 12/15/20.
//  Copyright © 2020 Alexei Igumnov. All rights reserved.
//

#import "NSString+Contain.h"

// Contain extension method for searching a  string
@implementation NSString (Contain)


/// To check is this  string contian given sub string
/// @param substring The sub string which going to search in string
/// @return If sub string contain in string will return true otherwise false
-(BOOL)containsSubString:(NSString *)substring {
    NSRange rangeOfSubstring = [self rangeOfString : substring];
    BOOL subStringFound = ( rangeOfSubstring.location != NSNotFound );
    return subStringFound;
}


@end
