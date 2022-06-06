//
//  VirtualTetherTableViewController.h
//  ScannerDemoApp
//
//  Created by Adrian Danushka on 11/3/20.
//  Copyright © 2020 Alexei Igumnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScannerDetailsVC.h"
#import "ConnectionManager.h"

NS_ASSUME_NONNULL_BEGIN


///Responsible for set/get virtual tether settings
@interface VirtualTetherTableViewController : UITableViewController<VirtualTetherAlarmMonitorProtocol>
{
    int m_ScannerID;
    bool simulationInProgress;
    bool pauseInProgress;

    IBOutlet UITableViewCell *tableViewCellSimulateOutOfRange;
    IBOutlet UITableViewCell *tableViewCellPauseVirtualTetherAlarm;
    
    IBOutlet UILabel *lableSimulateOutOfRangeHeader;

    IBOutlet UISwitch *switchVirtualTether;
    IBOutlet UISwitch *switchSimulateAlarm;

    ///Virutal Tether Host Settings
    
    IBOutlet UILabel *labelHostFeedback;
    IBOutlet UILabel *labelVibrate;
    IBOutlet UILabel *labelAudioAlarm;
    IBOutlet UILabel *labelFlashingScreen;
    IBOutlet UILabel *labelPopupMessage;

    IBOutlet UISwitch *switchHostFeedback;
    IBOutlet UISwitch *switchVibrate;
    IBOutlet UISwitch *switchAudioAlarm;
    IBOutlet UISwitch *switchFlashingScreen;
    IBOutlet UISwitch *switchPopupMessage;
    
    IBOutlet UIButton *buttonSnoozeAlarmOnHost;
    IBOutlet UIButton *buttonSnoozeAlarmOnScanner;
}

- (IBAction)enableVirtualTether:(UISwitch *)sender;

- (void)setScannerID:(int)currentScannerID;

- (IBAction)actionEnableHostFeedback:(UISwitch *)sender;
- (IBAction)actionEnableVibrate:(UISwitch *)sender;
- (IBAction)actionEnableAlarm:(UISwitch *)sender;

- (IBAction)actionSnoozAlarmOnScanner:(UIButton *)sender;
- (IBAction)actionSnoozAlarmOnHost:(UIButton *)sender;

//Protocol function to change host alarm button enable/disable mode
-(void)listenerForChangeInAlarm;
-(void)popToMainViewOnReconnectAlarmStop; ///Close view on reconnect

///Constraints
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *snoozeAlarmScannerBtnHeight;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *stopAlarmHostBtnHeight;


@end

NS_ASSUME_NONNULL_END
