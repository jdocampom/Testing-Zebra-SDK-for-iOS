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
 *  Description:   ConnectionManager.m
 *
 *  Notes: Manages connections to Zebra scanners
 *
 ******************************************************************************/

#import "ConnectionManager.h"
#import "ScannerAppEngine.h"
#import "AppSettingsKeys.h"
#import "config.h"


@interface ConnectionManager ()
{
    int scannerIdToConnect;
}

@property (nonatomic,retain) SbtScannerInfo *connectedScanner;

@end

@implementation ConnectionManager

#pragma mark Singleton methods

static ConnectionManager *sharedConnectionManager = nil;

+ (ConnectionManager *) sharedConnectionManager
{
    @synchronized([ConnectionManager class])
    {
        if (sharedConnectionManager == nil)
        {
            [[self alloc] init];
        }
        
        return sharedConnectionManager;
    }
    
    return nil;
}

+(id)alloc
{
    @synchronized([ConnectionManager class])
    {
        NSAssert(sharedConnectionManager == nil, @"Attempted to allocate a second instance of the connection manager singleton.");
        sharedConnectionManager = [super alloc];
        return sharedConnectionManager;
    }
    
    return nil;
}

+(void)destroy
{
    @synchronized([ConnectionManager class])
    {
        // deallocate here
    }
}

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        [self initializeConnectionManager];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    
    // Unregister for scanner events
    [[zt_ScannerAppEngine sharedAppEngine] removeDevConnectiosDelegate:self];
    [vibrateOnLoopTimer invalidate];
    vibrateOnLoopTimer = nil;
    if (self.connectedScanner)
    {
        [self.connectedScanner release];
    }
    [vibrateOnLoopTimer release];
    [self deleteCreatedHostAlarmSoundFromSystem];
}

- (void) initializeConnectionManager
{
    self.connectedScanner = nil;
    isOnAlarmMode = NO;
    isVirtualTetherUIPresented = NO;
    isAlarmSoundCanRepeat = YES;
    isDirectionFromNotification = NO;
    isSimulatePlaying = NO;
    simulateCountValue = 0;
    //Create host alarm sound in system
    [self createHostAlarmSound];
    // Register for scanner events
    [[zt_ScannerAppEngine sharedAppEngine] addDevConnectionsDelegate:self];
}

// establish connection to the device (scanner and rfid sdk) using the scanner id
- (void)connectDeviceUsingScannerId:(int)scannerId
{
    // Are we attempting to connect to a different scanner than the one that is already connected?
    if ([self.connectedScanner isActive] && scannerId != [self.connectedScanner getScannerID])
    {
        // Yes, so disconnect from the previously connected scanner
        [self disconnect];
    }
    
    // Establish connection with the new scanner
    [[zt_ScannerAppEngine sharedAppEngine] connect:scannerId];
}

// disconnect from both the scanner and rfid sdk using the scanner id
- (void) disconnect
{
    [[zt_ScannerAppEngine sharedAppEngine] disconnect:[self.connectedScanner getScannerID]];
}


- (int) getConnectedScannerId
{
    return [self.connectedScanner getScannerID];
}

- (BOOL) isConnected
{
    return [self.connectedScanner isActive];
}

///Get Alarm mode status for Snooz Host Alarm Button
-(BOOL) getIsOnAlarmMode{
    return isOnAlarmMode;
}

///Get Virtual Tether UI Present Mode
-(BOOL)getIsVirtualTetherUIPresented{
    return isVirtualTetherUIPresented;
}

///Set Virtual Tether UI Present Mode
-(void)setVirtualTetherUI:(BOOL) isPresented{
    isVirtualTetherUIPresented = isPresented;
}

///Get Notification Direction Mode
-(BOOL)getIsDirectionFromNotification{
    return isDirectionFromNotification;
}

///Set Notification Direction Mode
-(void)setDirectionFromNotification:(BOOL) isDirected{
    isDirectionFromNotification = isDirected;
}

#pragma IScannerAppEngineDevConnectionsDelegate

- (BOOL)scannerHasAppeared:(int)scannerID
{
    // do not handle this event
    return FALSE;
}

- (BOOL)scannerHasDisappeared:(int)scannerID
{
    return FALSE;
}

///Function to start Host Feedback
-(void)startHostFeedback{
    ///NSUserDefaults returns NO for isHostVibrateEnable and isHostAlarmEnable if the key doesn't exist.
    NSUserDefaults *stdUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isHostVibrateEnable = (BOOL)[stdUserDefaults boolForKey:ZT_VIRTUAL_TETHER_HOST_VIBRATE];
    BOOL isHostAlarmEnable = (BOOL)[stdUserDefaults boolForKey:ZT_VIRTUAL_TETHER_HOST_ALARM];
    ///Check whether Host Vibrate and Host Alarm are Enable
    if (isHostVibrateEnable) {
        [self vibrateHostOnDeviceDisappeared];
    }
    if (isHostAlarmEnable) {
        [self hostAlarmOnDeviceDisappeared];
    }
    ///Stop simulate alarm on 5 sec. VIRTUAL_TETHER_ALARM_REPEAT_INTERVAL = 2.5 sec (2 Times)
    if (isSimulatePlaying){
        simulateCountValue = simulateCountValue + 1;
        if (simulateCountValue == 2){
            [self stopHostAllAlertAlarm]; ///Stop all alarm on 5th sec
        }
    }
}

///Host Vibrate functions
-(void)vibrateHostOnDeviceDisappeared{
    /*!
    @enum           AudioServices constants
    @constant       kSystemSoundID_Vibrate
                        Use this constant with the play sound APIs to vibrate the device
                        - iOS only
                            - on a device with no vibration capability (like iPad) this will
                            do nothing
    */
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

///Create system sound for Host Virtual Alarm
-(void)createHostAlarmSound{
    NSString *alarmSoundFilePath = [[NSBundle mainBundle]pathForResource:VIRTUAL_TETHER_ALARM_SOUND_FILE ofType:VIRTUAL_TETHER_ALARM_SOUND_FILE_FORMAT];
    //Because the NSURL type is used when using the audio path, we need to convert the file path to the NSURL type.
    NSURL *alarmSoundFileURL = [NSURL fileURLWithPath:alarmSoundFilePath];
    //Need to create a soundID, because when playing the system sound, the system is looking for the soundID, the range of soundID is between 1000-2000.
    /*Create an ID based on the path of the sound (__bridge casts the type between the two frames, the value converts the memory, does not modify the memory management Permissions) When converting data types, you don't want the memory management permissions of the object to change. It turns out to be an MRC type, and it is converted to MRC. */
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(alarmSoundFileURL), &alarmSoundID);
}

///Delete created system sound form system for Host Virtual Alarm
-(void)deleteCreatedHostAlarmSoundFromSystem{
    AudioServicesDisposeSystemSoundID(alarmSoundID);
}

///Host Alarm Sound
-(void)hostAlarmOnDeviceDisappeared{
    if (isOnAlarmMode && isAlarmSoundCanRepeat) {
        isAlarmSoundCanRepeat = NO;
        AudioServicesPlaySystemSoundWithCompletion(alarmSoundID, ^{
            isAlarmSoundCanRepeat = YES;
        });
    }
}

///Stop Host Alarm
-(void)stopHostAllAlertAlarm{
    if (!isOnAlarmMode){
        return;
    }
    [vibrateOnLoopTimer invalidate];
    vibrateOnLoopTimer = nil;
    isOnAlarmMode = NO;
    ///Check weak reference delegate
    if (_delegate != NULL){
        [_delegate listenerForChangeInAlarm];
    }
    ///Disable all virtual tether options on new scanner connect
    if (!isSimulatePlaying){
        [self resetAllVirtualTetherHostAlarmSetting];
    }
    isSimulatePlaying = NO;
    simulateCountValue = 0; ///Reset simulate alarm count
}

-(BOOL)scannerHasConnected:(int)scannerID
{
    scannerIdToConnect = scannerID;
    
    // Is there a different scanner that is already connected?
    if ([self isConnected] && [self.connectedScanner getScannerID] != scannerID)
    {
        // Yes, so disconnect from this scanner first before connecting to the new scanner
        [self disconnect];
    }
    else
    {
        // No, set as the new connected scanner
        self.connectedScanner = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:scannerID];
    }
    ///Disable all virtual tether options on new scanner connect
    [self resetAllVirtualTetherHostAlarmSetting];
    return TRUE;
}

///Virutal tether alarm action on scanner auto reconnect
-(void)scannerReconnectedOnVirtualTetherAlarm{
    ///Check weak reference delegate
    [self stopHostAllAlertAlarm];
    if (_delegate != NULL){
        [_delegate popToMainViewOnReconnectAlarmStop];
    }
}

- (BOOL)scannerHasDisconnected:(int)scannerID
{
    [self virutalTetherEvents:scannerID simulate:NO]; ///Trigger virutal tether event on scanner disconnect
    self.connectedScanner = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:scannerIdToConnect];
    return TRUE;
}

/// Virutal tether events
/// @param scannerId Identify disconnected scanner
/// @param isSimulateAlarm check if it's simulate Alarm
-(void)virutalTetherEvents:(int)scannerId simulate:(BOOL)isSimulateAlarm{
    isSimulatePlaying = isSimulateAlarm;
    simulateCountValue = 0;
    ///NSUserDefaults returns NO for isHostFeedbackEnable and isHostVibrateEnable if the key doesn't exist.
    NSUserDefaults *stdUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isHostFeedbackEnable = (BOOL)[stdUserDefaults boolForKey:ZT_VIRTUAL_TETHER_ENABLE_HOST_FEEDBACK];
    
    ///isOnAlarmMode for while on Alarm mode to avoid dupilcate call for Disappeared and Disconnect Events
    if (isHostFeedbackEnable && !isOnAlarmMode && ([[ConnectionManager sharedConnectionManager] getConnectedScannerId] == scannerId)){
        /// Calling Vibrate function 'vibrateHostOnDeviceDisappeared' by Interverval with reapeat
        vibrateOnLoopTimer = [NSTimer scheduledTimerWithTimeInterval:VIRTUAL_TETHER_ALARM_REPEAT_INTERVAL
            target:self
            selector:@selector(startHostFeedback)
            userInfo:nil
            repeats:YES];
        isOnAlarmMode = YES;  ///Avoid dupilcate calls
        ///Check weak reference delegate
        if (_delegate != NULL){
            [_delegate listenerForChangeInAlarm];
        }
        if (_eventDelegate != NULL){
            [_eventDelegate showVirtualTetherRelatedUI:scannerId];
        }
    }
}


///Rest all virtual tether host alarm setting
-(void)resetAllVirtualTetherHostAlarmSetting{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZT_VIRTUAL_TETHER_ENABLE_HOST_FEEDBACK];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZT_VIRTUAL_TETHER_HOST_ALARM];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZT_VIRTUAL_TETHER_HOST_FLASH];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZT_VIRTUAL_TETHER_HOST_POPUP_MESSAGE];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZT_VIRTUAL_TETHER_HOST_VIBRATE];
}


@end
