//
//  MainViewTabBarController.h
//  ScannerDemoApp
//
//  Created by Sivarajah Pranavan on 2021-07-02.
//  Copyright © 2021 Zebra Technologies Corp. and/or its affiliates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScannerAppEngine.h"
#import "ConnectionManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BarcodeEventTriggerDelegate
@required
- (void) showActiveScannerVC:(NSNumber*) scannerID aBarcodeView:(BOOL) barcodeView aAnimated:(BOOL) animated;
- (void) showVirtualTetherUI;
@end

@interface MainViewTabBarController: UITabBarController <IScannerAppEngineDevEventsDelegate, UITabBarControllerDelegate, VirtualTetherAlarmEventProtocol, IScannerAppEngineDevConnectionsDelegate>
@property (retain, nonatomic) IBOutlet UITabBar *tabBarView;
@property (weak,nonatomic) id <BarcodeEventTriggerDelegate> delegateForBle;
@property (weak,nonatomic) id <BarcodeEventTriggerDelegate> delegateForMfi;
@end

NS_ASSUME_NONNULL_END
