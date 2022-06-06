//
//  UIColor+DarkModeExtension.h
//  ScannerDemoApp
//
//  Created by Adrian Danushka on 9/7/20.
//  Copyright © 2020 Alexei Igumnov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///  UIColor extension for color changed, when dark mode changed
@interface UIColor (DarkModeExtension)

+ (UIColor*) getDarkModeLabelTextColor:(UITraitCollection*) traitCollection;
+ (UIColor*) getDarkModeViewBackgroundColor:(UITraitCollection*) traitCollection;
+ (UIColor*) getDarkModeSectionViewBackgroundColor;
+ (UIColor*) getAppPrimaryColor;

@end

NS_ASSUME_NONNULL_END
