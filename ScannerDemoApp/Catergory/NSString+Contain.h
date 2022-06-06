//
//  NSString+Contain.h
//  ScannerDemoApp
//
//  Created by Adrian Danushka on 12/15/20.
//  Copyright © 2020 Alexei Igumnov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// Contain extension method for searching a  string 
@interface NSString (Contain)

-(BOOL)containsSubString: (NSString*)substring;


@end

NS_ASSUME_NONNULL_END
