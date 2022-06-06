//
//  ConnectionHelpRFD8500.h
//  ScannerDemoApp
//
//  Created by Adrian Danushka on 9/8/20.
//  Copyright © 2020 Alexei Igumnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHelpView.h"

NS_ASSUME_NONNULL_BEGIN

/// Connection help page for RFD8500
@interface ConnectionHelpRFD8500 : zt_ConnectionHelpView {
 IBOutlet UILabel *lableInstructionsRFD8500;
}
@end

NS_ASSUME_NONNULL_END
