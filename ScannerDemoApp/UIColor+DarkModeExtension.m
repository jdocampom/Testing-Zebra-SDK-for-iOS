//
//  UIColor+DarkModeExtension.m
//  ScannerDemoApp
//
//  Created by Adrian Danushka on 9/7/20.
//  Copyright © 2020 Alexei Igumnov. All rights reserved.
//

#import "UIColor+DarkModeExtension.h"

/// The implementation of uicolor extension for color changed, when dark mode changed
@implementation UIColor (DarkModeExtension)

/// Get the lable text color when dark mode changed
/// @param traitCollection  The traits, such as the size class and scale factor.
+(UIColor*) getDarkModeLabelTextColor:(UITraitCollection*) traitCollection {
	if (@available(iOS 12.0, *)) {
		if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
			return UIColor.whiteColor;
		}
	}
	return UIColor.blackColor;
}


/// Get the view  color when dark mode changed
/// @param traitCollection The traits, such as the size class and scale factor.
+ (UIColor*) getDarkModeViewBackgroundColor:(UITraitCollection*) traitCollection {
	if (@available(iOS 12.0, *)) {
		if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
			return UIColor.blackColor;
		}
	}
	return UIColor.whiteColor;
}


/// Get the section view  color when dark mode changed
+ (UIColor*) getDarkModeSectionViewBackgroundColor {
	if (@available(iOS 13.0, *)) {
		return [UIColor systemGroupedBackgroundColor];
	}
	return [UIColor colorWithRed: 243.0/256.0 green: 244.0/256.0 blue: 248.0/256.0 alpha: 1.0];
}


/// Get the primary blue color
+ (UIColor*) getAppPrimaryColor {
	return [UIColor colorWithRed: 0.0/256.0 green: 124.0/256.0 blue: 196.0/256.0 alpha: 1.0];
}

@end
