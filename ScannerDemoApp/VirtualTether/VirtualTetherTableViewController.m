//
//  VirtualTetherTableViewController.m
//  ScannerDemoApp
//
//  Created by Adrian Danushka on 11/3/20.
//  Copyright © 2020 Alexei Igumnov. All rights reserved.
//

#import "VirtualTetherTableViewController.h"
#import "config.h"
#import "SbtSdkDefs.h"
#import "ScannerAppEngine.h"
#import "UIColor+DarkModeExtension.h"
#import "AppSettingsKeys.h"
//#import "MFiScannersTableVC.h"
#import "BTLEScanToConnectVC.h"

@interface VirtualTetherTableViewController()
@end


/// Responsible for set/get virtual tether settings
@implementation VirtualTetherTableViewController

#pragma mark - Life cycle

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:RMD_VIRTUAL_TITLE];
    [self darkModeCheck:self.traitCollection];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    simulationInProgress = false;
    pauseInProgress = false;
    [switchHostFeedback setEnabled:NO];
    [self updateAlaramEnableUi];
    ///Disable scanner and host alarm buttons
    [buttonSnoozeAlarmOnScanner setEnabled:NO];
    [buttonSnoozeAlarmOnHost setEnabled:NO];
    ///Set Connection Manager Alaram Mode Delegate
    [[ConnectionManager sharedConnectionManager] setDelegate:self];
    [self listenerForChangeInAlarm];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appInBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appInForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

///A Boolean value indicating whether the toolbar at the bottom of the screen is hidden when the view controller is pushed on to a navigation controller.
-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

/// This method will call when app become active
/// @param note A container for information broadcast through a notification center to all registered observers.
-(void)appInBecomeActive:(NSNotification*)notification
{
    ///Check device above version iOS 13.0
    if (@available(iOS 13.0, *)){
        self.view.layer.backgroundColor = [UIColor getDarkModeSectionViewBackgroundColor].CGColor;
        [self changeViewColor];
    }else{
        ///Device below version iOS 13.0
        if ([[ConnectionManager sharedConnectionManager] getIsDirectionFromNotification]) {
            [[ConnectionManager sharedConnectionManager] setDirectionFromNotification:NO];
        }else{
            self.view.layer.backgroundColor = [UIColor getDarkModeSectionViewBackgroundColor].CGColor;
            [self changeViewColor];
        }
    }
}

/// This method will call when app in foreground
/// @param note A container for information broadcast through a notification center to all registered observers.
-(void)appInForeground:(NSNotification*)notification
{
    ///Check only device above version iOS 13.0
    if (@available(iOS 13.0, *)) {
        self.view.layer.backgroundColor = [UIColor getDarkModeSectionViewBackgroundColor].CGColor;
        [self changeViewColor];
    }
}

///Notifies the view controller that its view was added to a view hierarchy.
/// @param animated If true, the view was added to the window using an animation.
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self checkAndOpenPopupVirtualTetherMessage];
}

///Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[ConnectionManager sharedConnectionManager] setVirtualTetherUI:YES];
    
    ///Change in buttons size only in iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        _stopAlarmHostBtnHeight.constant = VIRTUAL_TETHER_PAGE_BUTTON_HEIGHT_IPAD;
        _snoozeAlarmScannerBtnHeight.constant = VIRTUAL_TETHER_PAGE_BUTTON_HEIGHT_IPAD;
    }
}

///Notifies the view controller that its view is about to be removed from a view hierarchy.
/// @param animated If true, the disappearance of the view is being animated.
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    ///Handling back button
    if ([self isMovingFromParentViewController]) {
        /* Decide if applition in active mode:
         - UIApplicationStateActive
         The app is running in the foreground and currently receiving events.
         */
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive){
            ///Stop alarm on moving view from parent. Only in Active state
            [[ConnectionManager sharedConnectionManager] stopHostAllAlertAlarm];
        }
    
        ///Redirect to connect page if virtual tether alram stoped and on click of back button
        if (![[ConnectionManager sharedConnectionManager] isConnected]){
            NSArray *viewControllerArray = [[self navigationController] viewControllers];
            for( int index=0;index<[viewControllerArray count];index++){
                id stackViewController = [viewControllerArray objectAtIndex:index];
//                if([stackViewController isKindOfClass:[MFiScannersTableVC class]]){
//                    [[self navigationController] popToViewController:stackViewController animated:NO];
//                    return;
//                }
                if([stackViewController isKindOfClass:[BTLEScanToConnectVC class]]){
                    [[self navigationController] popToViewController:stackViewController animated:NO];
                    return;
                }
            }
            
            [[zt_ScannerAppEngine sharedAppEngine] updateScannersList];
        }
    }
    ///Sets Virtual Tether UI presented to NO
    [[ConnectionManager sharedConnectionManager] setVirtualTetherUI:NO];
    ///Stop Animation
    [self.view.layer removeAllAnimations];
}

/// Add help button in navigation bar
-(void)addHelpButtonInNavigationbar {
    UIImage *image = [[UIImage imageNamed:HELP_ICON_IMAGE] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(clickHelpButton)];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem = rightButton;
}

/// The click event for the help button in navigation bar
- (void)clickHelpButton
{
    NSLog(@"Click help");
}


#pragma mark - Table view data source

/// Asks the data source to return the number of sections in the table view.
/// @param tableView An object representing the table view requesting this information.
/// @return The number of sections in tableView.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return VIRTUAL_TETHER_TABLE_NO_OF_SECTION;
}

/// Asks the delegate for a view to display in the header of the specified section of the table view.
/// @param tableView The table view asking for the view.
/// @param section The index number of the section containing the header view.
/// @return A UILabel, UIImageView, or custom view to display at the top of the specified section.
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(10, 0, 320, 50);
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];

    UIView *sectionHeaderView = [[UIView alloc] init];
    [sectionHeaderView setBackgroundColor:[UIColor getDarkModeSectionViewBackgroundColor]];
    [sectionHeaderView addSubview:titleLabel];

    return sectionHeaderView;
}

/// Tells the data source to return the number of rows in a given section of a table view.
/// @param tableView The table-view object requesting this information.
/// @param section An index number identifying a section in tableView.
/// @return The number of rows in section..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return VIRTUAL_TETHER_TABLE_SCANNER_SETTINGS_NO_OF_ROW;
            break;
        case 1:
            return VIRTUAL_TETHER_TABLE_HOST_SETTINGS_NO_OF_ROW;
            break;
        default:
            return 0;
            break;
    }
}

/// Tells the delegate a row is selected.
/// @param tableView A table view informing the delegate about the new row selection.
/// @param indexPath An index path locating the new selected row in tableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Did select row : %ld", (long)indexPath.row);
    
}

/// Asks the delegate for the height to use for the header of a particular section.
/// @param tableView The table view requesting this information.
/// @param section An index number identifying a section of tableView .
/// @return A nonnegative floating-point value that specifies the height (in points) of the header for section.
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return VIRTUAL_TETHER_SECTION_HEADER_HEIGHT;
}

#pragma mark - IBAction - UISwitch

/// Virtual tether on/off
/// @param sender The switch callback
-(IBAction)switchSimulateAlarmEnableDisable:(id)sender {
    if ([switchSimulateAlarm isOn]){
        int scannerId = [[ConnectionManager sharedConnectionManager] getConnectedScannerId];
        [[ConnectionManager sharedConnectionManager] virutalTetherEvents:scannerId simulate:YES];
        [self enableSimulation];
    }
}

/// Pause virtual tether on/off
/// @param sender The switch callback
- (IBAction)actionSnoozAlarmOnScanner:(UIButton *)sender {
    if ([buttonSnoozeAlarmOnScanner isEnabled]){
        [self pauseSimulation];
    }
}

/// Enable /Disable virtual thether
/// @param sender The switch callback
- (IBAction)enableVirtualTether:(UISwitch *)sender {
    [self virutalTether:sender.isOn];
}

#pragma mark - Methods

/// Enable / Disable virtual thether
/// @param isEnable The button callback
-(void)virutalTether:(BOOL)isEnable{
    if (isEnable) {
        [self storeVirtualTetherSetting:RMD_VIRTUAL_TETHER_ALARM_ENABLE attributeValue:RMD_ATTRIBUTE_VALUE_ONE attributeType:RMD_ATTRIBUTE_TYPE_BYTE];
    }else{
        [self storeVirtualTetherSetting:RMD_VIRTUAL_TETHER_ALARM_ENABLE attributeValue:RMD_ATTRIBUTE_VALUE_ZERO attributeType:RMD_ATTRIBUTE_TYPE_BYTE];
    }
}

/// Enable / Disable Host Feedback option
/// @param isEnable The button callback
-(void)hostFeedbackSettings:(BOOL) isEnable{
    if (isEnable) {
        [switchHostFeedback setEnabled:YES];
        ///Enable all host feedback on Virtual Tether turn off
        [self setEnableHostFeedback:YES];
    }else{
        [switchHostFeedback setEnabled:NO];
        ///Disable all host feedback on Virtual Tether turn off
        [self setEnableHostFeedback:NO];
    }
}

/// Set connected scanner id
/// @param currentScannerID Connnected scanner id
- (void)setScannerID:(int)currentScannerID
{
    m_ScannerID = currentScannerID;
}

/// Update alarm enable button UI component with color and enable both buttons
- (void)updateAlaramEnableUi
{
    /*
     check 'getIsOnAlarmMode' to avoid fetching virtual tether settings from disconnected scanner.
     */
    if ([[ConnectionManager sharedConnectionManager] getIsOnAlarmMode]) {
        [switchVirtualTether setOn:YES];
        [switchHostFeedback setEnabled:YES];
        ///Check all host feedback
        [self checkAllAvailableOptionStatus];
        return;
    }
    ///Updating UI by scanner settings
    [switchVirtualTether setEnabled:YES];
    NSString* currentValue = [self getVirtualTetherSetting:RMD_VIRTUAL_TETHER_ALARM_ENABLE];
    if ([currentValue isEqual:RMD_ATTRIBUTE_VALUE_ONE]){
        [switchVirtualTether setOn:YES];
        ///Host feedback Enable
        [switchHostFeedback setEnabled:YES];
        ///Enable simulate alarm switch
        [switchSimulateAlarm setEnabled:YES];
    }else{
        [switchVirtualTether setOn:NO];
        ///Host feedback Disable
        [switchHostFeedback setEnabled:NO];
        ///Disable simulate alarm switch
        [switchSimulateAlarm setEnabled:NO];
    }
    [self checkAllAvailableOptionStatus];
}

/// Sets given value to given attribute
/// @param attributeID ID of the attribute to be set to
/// @param value Value to set
/// @param type Type of the attribute
- (void)setVirtualTetherSetting:(int)attributeId attributeValue:(NSString*)value attributeType:(NSString *)type
{
    NSString *inXml = [NSString
                       stringWithFormat:@"%@%@%d%@%@%@%@%@%@%d%@%@%@%@%@%@%@%@%@%@%@%@", XML_TAG_INARGS_START, XML_TAG_SCANNERID_START, m_ScannerID, XML_TAG_SCANNERID_END, XML_TAG_CMDARGS_START, XML_TAG_ARGXML_START, XML_TAG_ATTRIBUTE_LIST_START, XML_TAG_ATTRIBUTE_START, XML_TAG_ID_START, attributeId, XML_TAG_ID_END, XML_TAG_DATATYPE_START, type, XML_TAG_DATATYPE_END, XML_TAG_VALUE_START, value, XML_TAG_VALUE_END, XML_TAG_ATTRIBUTE_END, XML_TAG_ATTRIBUTE_LIST_END, XML_TAG_ARGXML_END, XML_TAG_CMDARGS_END, XML_TAG_INARGS_END];
    
    SBT_RESULT sbtResult = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_SET aInXML:inXml aOutXML:nil forScanner:m_ScannerID];
    
    if (sbtResult != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:MESSAGE_CANNOT_SET_VIRTUAL_TETHER_SETTING
                                      preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:OK
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                               //Handle ok
                                            }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            [alert release];
        }
                       );
    }
}

/// Stores given value to given attribute
/// @param attributeID ID of the attribute to be stored to
/// @param value Value to store
/// @param type Type of the attribute
- (void)storeVirtualTetherSetting:(int)attributeId attributeValue:(NSString*)value attributeType:(NSString *)type
{
    NSString *inXml = [NSString
                       stringWithFormat:@"%@%@%d%@%@%@%@%@%@%d%@%@%@%@%@%@%@%@%@%@%@%@", XML_TAG_INARGS_START, XML_TAG_SCANNERID_START, m_ScannerID, XML_TAG_SCANNERID_END, XML_TAG_CMDARGS_START, XML_TAG_ARGXML_START, XML_TAG_ATTRIBUTE_LIST_START, XML_TAG_ATTRIBUTE_START, XML_TAG_ID_START, attributeId, XML_TAG_ID_END, XML_TAG_DATATYPE_START, type, XML_TAG_DATATYPE_END, XML_TAG_VALUE_START, value, XML_TAG_VALUE_END, XML_TAG_ATTRIBUTE_END, XML_TAG_ATTRIBUTE_LIST_END, XML_TAG_ARGXML_END, XML_TAG_CMDARGS_END, XML_TAG_INARGS_END];
    NSMutableString *outXML = [[NSMutableString alloc] init];
    [outXML setString:@""];
    SBT_RESULT sbtResult = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_STORE aInXML:inXml aOutXML:&outXML forScanner:m_ScannerID];
    
    if (sbtResult != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:MESSAGE_CANNOT_STORE_VIRTUAL_TETHER_SETTING
                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:OK
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                               //Handle ok
                                            }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            [alert release];
        }
                       );
    }else{
        ///Host feedback Enable / Disable on success of virutal tether setting store
        if ([value  isEqual: RMD_ATTRIBUTE_VALUE_ONE]) {
            [self hostFeedbackSettings:YES];
            ///Enable simulate alarm switch
            [switchSimulateAlarm setEnabled:YES];
        }else if ([value  isEqual: RMD_ATTRIBUTE_VALUE_ZERO]) {
            [self hostFeedbackSettings:NO];
            ///Disable simulate alarm switch
            [switchSimulateAlarm setEnabled:NO];
        }
    }
}

/// Returns value of given attribute
/// @param attributeID ID of the attribute to be retrived
/// @return Value of the given attribute
- (NSString*)getVirtualTetherSetting:(int)attributeId
{
    NSString *inXml = [NSString stringWithFormat:@"%@%@%d%@%@%@%@%d%@%@%@%@", XML_TAG_INARGS_START, XML_TAG_SCANNERID_START, m_ScannerID, XML_TAG_SCANNERID_END, XML_TAG_CMDARGS_START, XML_TAG_ARGXML_START, XML_TAG_ATTRIBUTE_LIST_START, attributeId, XML_TAG_ATTRIBUTE_LIST_END, XML_TAG_ARGXML_END, XML_TAG_CMDARGS_END, XML_TAG_INARGS_END];

    NSMutableString *result = [[NSMutableString alloc] init];
    
    [result setString:@""];
    
    SBT_RESULT sbtResult = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:inXml aOutXML:&result forScanner:m_ScannerID];
    
    if (SBT_RESULT_SUCCESS != sbtResult)
    {
        [NSThread sleepForTimeInterval:2.0];
        sbtResult = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:inXml aOutXML:&result forScanner:m_ScannerID];
        
        if (sbtResult != SBT_RESULT_SUCCESS)
        {
            return @"";
        }
    }
    
    BOOL success = FALSE;
    /* success */
    do {
        
        NSString* resultString = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString* searchString = [NSString stringWithFormat:@"%@%@", XML_TAG_ATTRIBUTE_LIST_START, XML_TAG_ATTRIBUTE_START];
        
        NSRange startRange = [resultString rangeOfString:searchString];
        NSRange endRange;
        
        if ((startRange.location == NSNotFound) || (startRange.length != [searchString length]))
        {
            break;
        }
        resultString = [resultString substringFromIndex:(startRange.location + startRange.length)];
        
        searchString = [NSString stringWithFormat:@"%@%@", XML_TAG_ATTRIBUTE_END, XML_TAG_ATTRIBUTE_LIST_END];
        startRange = [resultString rangeOfString:searchString];
        
        if ((startRange.location == NSNotFound) || (startRange.length != [searchString length]))
        {
            break;
        }
        
        startRange.length = [resultString length] - startRange.location;
        resultString = [resultString stringByReplacingCharactersInRange:startRange withString:@""];
        
        NSArray *attrs = [resultString componentsSeparatedByString:[NSString stringWithFormat:@"%@%@", XML_TAG_ATTRIBUTE_END, XML_TAG_ATTRIBUTE_START]];
        if ([attrs count] == 0)
        {
            break;
        }
        
        NSString *attributeString;
        
        int inXmlAttributeId;
        int inXmlAttributeValue;
        
        //extract attribute info
        attributeString = resultString;
        searchString = XML_TAG_ID_START;
        startRange = [attributeString rangeOfString:searchString];
        if ((startRange.location != 0) || (startRange.length != [searchString length]))
        {
            break;
        }
        attributeString = [attributeString stringByReplacingCharactersInRange:startRange withString:@""];

        searchString = XML_TAG_ID_END;
        startRange = [attributeString rangeOfString:searchString];
        
        if ((startRange.location == NSNotFound) || (startRange.length != [searchString length]))
        {
            break;
        }
        
        endRange.length = [attributeString length] - startRange.location;
        endRange.location = startRange.location;
        NSString *inXmlAttributeIdString = [attributeString stringByReplacingCharactersInRange:endRange withString:@""];
        inXmlAttributeId = [inXmlAttributeIdString intValue];
        
        
        endRange.location = 0;
        endRange.length = startRange.location + startRange.length;
        attributeString = [attributeString stringByReplacingCharactersInRange:endRange withString:@""];
        
        searchString = XML_TAG_VALUE_START;
        startRange = [attributeString rangeOfString:searchString];
        if ((startRange.location == NSNotFound) || (startRange.length != [searchString length]))
        {
            break;
        }
        
        attributeString = [attributeString substringFromIndex:(startRange.location + startRange.length)];
        searchString = XML_TAG_VALUE_END;
        startRange = [attributeString rangeOfString:searchString];
        if ((startRange.location == NSNotFound) || (startRange.length != [searchString length]))
        {
            break;
        }
        
        startRange.length = [attributeString length] - startRange.location;
        attributeString = [attributeString stringByReplacingCharactersInRange:startRange withString:@""];
        inXmlAttributeValue = [attributeString intValue];
        
        if (attributeId == inXmlAttributeId)
        {
            success = TRUE;
            return attributeString;
        }
        else
        {
            NSLog(@"Incorrect attribute info");
            break;
        }
    } while (0);
    
    if (FALSE == success)
    {
        return @"";
    }
    return @"";
}


/// Execute action command with given value
/// @param value Value to execute action command with
- (void)executeActionCommand:(NSString*)value
{
    NSString *inXml = [NSString stringWithFormat:@"%@%@%d%@%@%@%@%@%@%@",XML_TAG_INARGS_START, XML_TAG_SCANNERID_START, m_ScannerID, XML_TAG_SCANNERID_END, XML_TAG_CMDARGS_START,XML_TAG_ARG_INT_START,value,XML_TAG_ARG_INT_END,XML_TAG_CMDARGS_END, XML_TAG_INARGS_END];
    
    SBT_RESULT sbtResult = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_SET_ACTION aInXML:inXml aOutXML:nil forScanner:m_ScannerID];
    if (sbtResult != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:MESSAGE_VIRTUAL_TETHER_SIMULATION_FAILED
                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:OK
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                               //Handle ok
                                            }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            [alert release];
        }
                       );
    }
}

/// Start virtual tether simulation for TIMEOUT_VIRTUAL_TETHER_SIMULATION seconds, current timeout 5 seconds
- (void)enableSimulation
{
    //skip if simulation is in progress
    if(!simulationInProgress)
    {
        simulationInProgress = true;
        dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(dispatchQueue,
                       ^{
            //enable virtual tether for audio, led, illumination and haptics
            [self setVirtualTetherSetting:RMD_VIRTUAL_TETHER_AUDIO_ALARM attributeValue:RMD_ATTRIBUTE_VALUE_ENABLE_NIGHT_MODE attributeType:RMD_ATTRIBUTE_TYPE_BYTE];
            [self setVirtualTetherSetting:RMD_VIRTUAL_TETHER_LED attributeValue:RMD_ATTRIBUTE_VALUE_TRUE attributeType:RMD_ATTRIBUTE_TYPE_FLAG];
            [self setVirtualTetherSetting:RMD_VIRTUAL_TETHER_ILLUMINATION attributeValue:RMD_ATTRIBUTE_VALUE_TRUE attributeType:RMD_ATTRIBUTE_TYPE_FLAG];
            [self setVirtualTetherSetting:RMD_VIRTUAL_TETHER_HAPTICS attributeValue:RMD_ATTRIBUTE_VALUE_TRUE attributeType:RMD_ATTRIBUTE_TYPE_FLAG];
            [self executeActionCommand:RMD_ATTRIBUTE_VALUE_ENABLE_SIMULATION]; //start simulation
            
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                [switchSimulateAlarm setUserInteractionEnabled:false]; // disable user interactions for simulation switch
                [switchVirtualTether setEnabled:NO];
                [self disableEnableCell:true trait:self.view.traitCollection]; //enable pause button
            }
                           );
            //wait for TIMEOUT_VIRTUAL_TETHER_SIMULATION seconds, current timeout 5 seconds
            NSDate *startTime = [NSDate date];
            while (TRUE)
            {
                usleep(10*1000);
                
                // Number of seconds we have been in the while loop
                double secondsElapsed = [[NSDate date] timeIntervalSinceDate:startTime];
                
                if (secondsElapsed >= TIMEOUT_VIRTUAL_TETHER_SIMULATION || pauseInProgress)
                {
                    break;
                }
            }
            //only if timeout
            if (!pauseInProgress)
            {
                [self executeActionCommand:RMD_ATTRIBUTE_VALUE_DISABLE_SIMULATION]; //end simulation
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                    [switchSimulateAlarm setUserInteractionEnabled:true];// Eable user interactions for simulation switch
                    [switchSimulateAlarm setOn:NO animated:YES];// Set state of simulation switch to off
                    [self disableEnableCell:false trait:self.view.traitCollection]; //disable pause button
                    [switchVirtualTether setEnabled:YES];
                }
                               );
            }
            simulationInProgress = false;
        }
                       );
    }
}

/// Pause virtual tether simulation for TIMEOUT_VIRTUAL_TETHER_SIMULATION_PAUSE seconds, current timeout 3 seconds
- (void)pauseSimulation
{
    //skip if pause is in progress
    if(!pauseInProgress)
    {
        pauseInProgress = true;
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            [buttonSnoozeAlarmOnScanner setEnabled:NO]; //Set disable Snooz Button
            [switchVirtualTether setEnabled:NO];
        }
                       );
        dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(dispatchQueue,
                       ^{
            [self executeActionCommand:RMD_ATTRIBUTE_VALUE_DISABLE_SIMULATION];//end simulation
            
            //wait for TIMEOUT_VIRTUAL_TETHER_SIMULATION_PAUSE seconds, current timeout 3 seconds
            NSDate *startTime = [NSDate date];
            while (TRUE)
            {
                usleep(10*1000);
                
                // Number of seconds we have been in the while loop
                double secondsElapsed = [[NSDate date] timeIntervalSinceDate:startTime];
                
                if (secondsElapsed >= TIMEOUT_VIRTUAL_TETHER_SIMULATION_PAUSE)
                {
                    break;
                }
            }
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                [buttonSnoozeAlarmOnScanner setEnabled:YES]; //Set Snooz button to enable
                
                [self disableEnableCell:true trait:self.view.traitCollection]; //enable pause button
                [switchVirtualTether setEnabled:YES];
            }
                           );
            simulationInProgress = false;
            pauseInProgress = false;
            [self enableSimulation]; //When pause duration is expired, should restart simulation for 5 seconds
        });
    }
}


/// To disable/enable cell and change the color of cell lable
/// @param enableDisableCellStatus The status of enable/disable of cell. To enable set true, otherwise false
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)disableEnableCell:(bool)enableDisableCellStatus trait:(UITraitCollection *)traitCollection {
    
    [tableViewCellPauseVirtualTetherAlarm setUserInteractionEnabled:enableDisableCellStatus];
    [buttonSnoozeAlarmOnScanner setUserInteractionEnabled:enableDisableCellStatus];
    [buttonSnoozeAlarmOnScanner setEnabled:enableDisableCellStatus];
    if (enableDisableCellStatus) {
        buttonSnoozeAlarmOnScanner.backgroundColor = [UIColor colorWithRed:0.0f/255.0 green:165.0f/255.0 blue:211.0f/255.0 alpha:1.0]; //Active //0 165 211
    }else {
        buttonSnoozeAlarmOnScanner.backgroundColor = [UIColor colorWithRed:187.0f/255.0 green:203.0f/255.0 blue:209.0f/255.0 alpha:1.0]; //Inactive //187 203 209
    }
    
}

#pragma mark - Host Settings

///Check status for Host Settings and update UI
- (void) checkAllAvailableOptionStatus{
    [self checkAllHostFeedbackDisable];
}

///Host Feedback
/// @param sender The switch callback
- (IBAction)actionEnableHostFeedback:(UISwitch *)sender {
    [self setEnableHostFeedback:sender.isOn];
}

///Enable or Disable host feedback
/// @param isOn state of host feedback
-(void)setEnableHostFeedback: (BOOL)isOn{
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:ZT_VIRTUAL_TETHER_ENABLE_HOST_FEEDBACK];
    ///Disable or Enable all other option on Host Feedback status
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:ZT_VIRTUAL_TETHER_HOST_ALARM];
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:ZT_VIRTUAL_TETHER_HOST_FLASH];
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:ZT_VIRTUAL_TETHER_HOST_POPUP_MESSAGE];
    ///Disable vibrate support in iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [switchVibrate setOn:NO animated:YES];
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:ZT_VIRTUAL_TETHER_HOST_VIBRATE];
    }
    [switchVibrate setEnabled:isOn];
    [switchAudioAlarm setEnabled:isOn];
    [switchFlashingScreen setEnabled:isOn];
    [switchPopupMessage setEnabled:isOn];
    [self checkAllHostFeedbackDisable];
}

///Vibrate
/// @param sender The switch callback
- (IBAction)actionEnableVibrate:(UISwitch *)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [switchVibrate setOn:NO animated:YES];
        [self nonSupportedVibrateDevicePopupMessage];
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:ZT_VIRTUAL_TETHER_HOST_VIBRATE];
        [self checkAllHostFeedbackDisable];
    }
}

///Vibrate non-supported device alert popup
-(void)nonSupportedVibrateDevicePopupMessage{
    UIAlertController *popupMessageAlert = [UIAlertController alertControllerWithTitle:NULL message:VIRTUAL_TETHER_NON_VIBRATE_SUPPORT_MESSAGE preferredStyle:UIAlertControllerStyleAlert]; ///No title
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:OK style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
        
    }];
    [popupMessageAlert addAction:okAction];
    [self presentViewController:popupMessageAlert animated:YES completion:nil];
}

///Alarm
- (IBAction)actionEnableAlarm:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:ZT_VIRTUAL_TETHER_HOST_ALARM];
    [self checkAllHostFeedbackDisable];
}

///Screen flash
- (IBAction)actionFlashView:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:ZT_VIRTUAL_TETHER_HOST_FLASH];
    [self checkAllHostFeedbackDisable];
}

///Popup Message
- (IBAction)actionEnablePopupMessage:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:ZT_VIRTUAL_TETHER_HOST_POPUP_MESSAGE];
    [self checkAllHostFeedbackDisable];
}

///Enable or Disable all Host Feedback
- (void)checkAllHostFeedbackDisable{
    NSUserDefaults *stdUserDefaults = [NSUserDefaults standardUserDefaults];
    ///Enable host feedback
    BOOL isHostFeedbackEnable = (BOOL)[stdUserDefaults boolForKey:ZT_VIRTUAL_TETHER_ENABLE_HOST_FEEDBACK];
    [switchHostFeedback setOn:isHostFeedbackEnable];
    ///Host Vibrate
    BOOL isHostVibrateEnable = (BOOL)[stdUserDefaults boolForKey:ZT_VIRTUAL_TETHER_HOST_VIBRATE];
    [switchVibrate setOn:isHostVibrateEnable];
    ///Host Alarm
    BOOL isHostAlarmEnable = (BOOL)[stdUserDefaults boolForKey:ZT_VIRTUAL_TETHER_HOST_ALARM];
    [switchAudioAlarm setOn:isHostAlarmEnable];
    ///Host Flash
    BOOL isHostFlashEnable = (BOOL)[stdUserDefaults boolForKey:ZT_VIRTUAL_TETHER_HOST_FLASH];
    [switchFlashingScreen setOn:isHostFlashEnable];
    ///Host Popup Message
    BOOL isHostPopupEnable = (BOOL)[stdUserDefaults boolForKey:ZT_VIRTUAL_TETHER_HOST_POPUP_MESSAGE];
    [switchPopupMessage setOn:isHostPopupEnable];
    ///Disable host feedback if all other options are disabled
    if (!(isHostVibrateEnable || isHostAlarmEnable || isHostFlashEnable || isHostPopupEnable)){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZT_VIRTUAL_TETHER_ENABLE_HOST_FEEDBACK];
        [switchHostFeedback setOn:NO animated:YES];
        [switchVibrate setEnabled:NO];
        [switchAudioAlarm setEnabled:NO];
        [switchFlashingScreen setEnabled:NO];
        [switchPopupMessage setEnabled:NO];
    }
}

///Delegate to change alarm stop button enable/disable
- (void)listenerForChangeInAlarm {
    if ([[ConnectionManager sharedConnectionManager] getIsOnAlarmMode]) {
        [buttonSnoozeAlarmOnHost setEnabled:YES];
        [self updateAlaramEnableUi];
        buttonSnoozeAlarmOnHost.backgroundColor = [UIColor colorWithRed:0.0f/255.0 green:165.0f/255.0 blue:211.0f/255.0 alpha:1.0]; //Active //0 165 211
    }else{
        [buttonSnoozeAlarmOnHost setEnabled:NO];
        buttonSnoozeAlarmOnHost.backgroundColor = [UIColor colorWithRed:187.0f/255.0 green:203.0f/255.0 blue:209.0f/255.0 alpha:1.0]; //Inactive //187 203 209
    }
   
    [self changeViewColor];
    [self checkAndOpenPopupVirtualTetherMessage];
 
}

/// Popup to the main view on scanner reconnect
-(void)popToMainViewOnReconnectAlarmStop{
    ///Redirect to Connect page on Scanner reconnection
    NSArray *viewControllerArray = [[self navigationController] viewControllers];
    for( int index=0;index<[viewControllerArray count];index++){
        id stackViewController=[viewControllerArray objectAtIndex:index];
        NSUInteger valueToCheckIfExitWithoutScannerTableVC = viewControllerArray.count - VIRTUAL_TETHER_CHECK_LAST_VC;
//        if([stackViewController isKindOfClass:[MFiScannersTableVC class]]){
//            [[self navigationController] popToViewController:stackViewController animated:NO];
//            return;
//        }else
        if([stackViewController isKindOfClass:[BTLEScanToConnectVC class]]){
            [[self navigationController] popToViewController:stackViewController animated:NO];
            return;
        }else if (valueToCheckIfExitWithoutScannerTableVC == index) {
            [[self navigationController] popViewControllerAnimated:NO];
            return;
        }
    }
    [[zt_ScannerAppEngine sharedAppEngine] updateScannersList];
}


// Change the view color
- (void)changeViewColor {
    
    NSUserDefaults *stdUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isHostFlashEnable = (BOOL)[stdUserDefaults boolForKey:ZT_VIRTUAL_TETHER_HOST_FLASH];
    
    if ([[ConnectionManager sharedConnectionManager] getIsOnAlarmMode]) {
        if (isHostFlashEnable) {
            [self flashTheScreenWithAnimation];
        } else {
            self.view.layer.backgroundColor = [UIColor getDarkModeSectionViewBackgroundColor].CGColor;
        }
       
    }else{
        
        self.view.layer.backgroundColor = [UIColor getDarkModeSectionViewBackgroundColor].CGColor;
    }
}

///Open pop up view on Virtual tether alarm
-(void)checkAndOpenPopupVirtualTetherMessage{
    NSUserDefaults *stdUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isHostPopupEnable = (BOOL)[stdUserDefaults boolForKey:ZT_VIRTUAL_TETHER_HOST_POPUP_MESSAGE];
    ///Check if Alarm is ON mode 'AND' Host Popup message is Enable
    if ([[ConnectionManager sharedConnectionManager] getIsOnAlarmMode] && isHostPopupEnable) {
        UIAlertController *popupMessagealert = [UIAlertController alertControllerWithTitle:NULL message:VIRTUAL_TETHER_NOTIFICATION_TITLE preferredStyle:UIAlertControllerStyleAlert]; ///No title
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:OK style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
            ///Tap ok button to stop virtual tether alarm
            [[ConnectionManager sharedConnectionManager] stopHostAllAlertAlarm];
        }];
        [popupMessagealert addAction:okAction];
        [self presentViewController:popupMessagealert animated:YES completion:nil];
    }else{
        /// Auto dissmisses the virtual tether alarm alert popup from view on alarm stop or simluate stop
        /// Dismisses the view controller that was presented modally by the view controller.
        /// @param flag Pass YES to animate the transition.
        /// @param completion The block to execute after the view controller is dismissed. This block has no return value and takes no parameters. You may specify nil for this parameter.
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


/// Change the color of background view with animation
-(void)flashTheScreenWithAnimation {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
       
         [self.view.layer removeAllAnimations];
         [UIView animateWithDuration:1.0f
                           delay:0.0f
                         options: UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                      animations: ^(void) {
             self.view.layer.backgroundColor = [UIColor colorWithRed:0.0f/255.0 green:124.0f/255.0 blue:176.0f/255.0 alpha:1.0].CGColor;
            
                                 
             
         } completion:NULL];
            
        });
    });
  
    
}
    

///Snooz Host Alaram button actions
- (IBAction)actionSnoozAlarmOnHost:(UIButton *)sender {
    [[ConnectionManager sharedConnectionManager] stopHostAllAlertAlarm];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor,.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    if ([switchSimulateAlarm isOn]){
        [self disableEnableCell:true trait:traitCollection];
    }else{
        [self disableEnableCell:false trait:traitCollection];
    }
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [tableViewCellSimulateOutOfRange release];
    [tableViewCellPauseVirtualTetherAlarm release];
    [lableSimulateOutOfRangeHeader release];
    [switchSimulateAlarm release];
    [switchVirtualTether release];
    [labelHostFeedback release];
    [labelVibrate release];
    [labelAudioAlarm release];
    [labelFlashingScreen release];
    [labelPopupMessage release];
    [switchHostFeedback release];
    [switchVibrate release];
    [switchAudioAlarm release];
    [switchFlashingScreen release];
    [switchPopupMessage release];
    [buttonSnoozeAlarmOnHost release];
    [buttonSnoozeAlarmOnScanner release];
    [_snoozeAlarmScannerBtnHeight release];
    [_stopAlarmHostBtnHeight release];
    [super dealloc];
}

@end
