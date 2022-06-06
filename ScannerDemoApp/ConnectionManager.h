/******************************************************************************
 *
 *       Copyright Zebra Technologies Corporation. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:   ConnectionManager.h
 *
 *  Notes: Manages connections to Zebra scanners
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "ScannerAppEngine.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

@protocol VirtualTetherAlarmMonitorProtocol

@required
-(void)listenerForChangeInAlarm;
-(void)popToMainViewOnReconnectAlarmStop;
@end

@protocol VirtualTetherAlarmEventProtocol

@required
- (void)showVirtualTetherRelatedUI:(int)scannerID;

@end


@interface ConnectionManager : NSObject <IScannerAppEngineDevConnectionsDelegate>{
    NSTimer *vibrateOnLoopTimer; //Vibrate Timer
    BOOL isOnAlarmMode;
    BOOL isVirtualTetherUIPresented;
    BOOL isDirectionFromNotification;
    BOOL isAlarmSoundCanRepeat;
    BOOL isSimulatePlaying;
    int simulateCountValue;
    SystemSoundID alarmSoundID;
}

@property (weak,nonatomic) id <VirtualTetherAlarmMonitorProtocol> delegate; //Delegate for Virtual Tether
@property (weak,nonatomic) id <VirtualTetherAlarmEventProtocol> eventDelegate; //Delegate for Virtual Tether Events

+ (ConnectionManager *) sharedConnectionManager;

- (void) initializeConnectionManager;

// establish connection to the scanner sdk
- (void)connectDeviceUsingScannerId:(int)scannerId;

// disconnect from the scanner sdk
- (void) disconnect;

// get connected scanner id
- (int) getConnectedScannerId;

// are we connected?
- (BOOL) isConnected;

// Alarm Mode
- (BOOL) getIsOnAlarmMode;

//Stop Host Alarm
-(void)stopHostAllAlertAlarm;

//Get Virtual Tether UI Present Mode
-(BOOL)getIsVirtualTetherUIPresented;

//Set Virtual Tether UI Present Mode
-(void)setVirtualTetherUI:(BOOL) isPresented;

//Get Notification Direction
-(BOOL)getIsDirectionFromNotification;

//Set Notification Direction
-(void)setDirectionFromNotification:(BOOL) isDirected;

//Rest all virtual tether host alarm setting
-(void)resetAllVirtualTetherHostAlarmSetting;

//Virutal tether events
-(void)virutalTetherEvents:(int)scannerId simulate:(BOOL)isSimulateAlarm;

//Device reconnected on virtual tether alarm
-(void)scannerReconnectedOnVirtualTetherAlarm;

@end
