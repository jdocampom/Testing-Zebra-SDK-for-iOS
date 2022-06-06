/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  AppSettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AppSettingsVC.h"
#import "AppSettingsKeys.h"
#import "SbtSdkDefs.h"
#import "ScannerAppEngine.h"
#import "AppSettingsBackgroundVC.h"
#import "config.h"
#import "BTLEScanToConnectVC.h"
#import "SbtSdkDefs.h"
#import "AboutAppVC.h"

// This flag is used to hide the "image event" and "video event" rows in the
// "background notifications" section of the settings table.
//
// Comment out this #define to show the "image event" and "video event" rows.
//
#define LOCAL_CONFIG_HIDE_IMAGE_VIDEO_EVENT_SWITCHES
#define SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG

typedef enum
{
    SECTION_COMM_MODE = 0,
    SECTION_EVENTS,
    SECTION_BG_MODE,
    SECTION_DETECTION,
    SECTION_STC,
    SECTION_TOTAL
    
} SettingsSection;

@interface zt_AppSettingsVC ()
{
    UIButton *restoreBtn;
}

@end

@implementation zt_AppSettingsVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void)dealloc
{
    [self.tableView setDataSource:nil];
    [self.tableView setDelegate:nil];
    [m_cellOpModeBTLE release];
    [m_cellOpModeMFI release];
    [m_cellOpModeBoth release];
    [m_swScannerDetection release];
    [m_swNotificationAvailable release];
    [m_swNotificationActive release];
    [m_swNotificationBarcode release];
    [m_swNotificationImage release];
    [m_swNotificationVideo release];
    [restoreBtn release];
    [barcodeType release];
    [comProtocol release];

    [m_stDfltsSwitch release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"App Settings"];
    
    [m_cellOpModeBoth setAccessoryType:UITableViewCellAccessoryNone];
    [m_cellOpModeBTLE setAccessoryType:UITableViewCellAccessoryNone];
    [m_cellOpModeMFI setAccessoryType:UITableViewCellAccessoryNone];
    
    [self displayCurrentOpmode];

    BOOL animation = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? NO : YES);
    [m_swScannerDetection setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_SCANNER_DETECTION]  animated:animation];
    
#ifdef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
    [m_swNotificationAvailable setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_AVAILABLE] animated:animation];
    [m_swNotificationActive setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_ACTIVE] animated:animation];
    [m_swNotificationBarcode setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_BARCODE] animated:animation];
    [m_swNotificationImage setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_IMAGE] animated:animation];
    [m_swNotificationVideo setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_VIDEO] animated:animation];
#else /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [m_swNotificationAvailable setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_AVAILABLE] animated:animation];
    [m_swNotificationActive setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_ACTIVE] animated:animation];
    [m_swNotificationBarcode setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_BARCODE] animated:animation];
    [m_swNotificationImage setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_IMAGE] animated:animation];
    [m_swNotificationVideo setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_VIDEO] animated:animation];
#endif /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    
    [self resstoreSTCComponents];
    [m_stDfltsSwitch addTarget:self action:@selector(m_stDfltsSwitchToggled:) forControlEvents:UIControlEventValueChanged];

    [self addResetToDefaultsButton];
    UIBarButtonItem *aboutusButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:ABOUTUS_IMAGE] style:UIBarButtonItemStylePlain target:self action:@selector(aboutAction:)];
    [[self navigationItem] setRightBarButtonItem:aboutusButton];
}

/// Call the about app view controller.
/// @param sender Send the button id as a sender.
-(IBAction)aboutAction:(id)sender
{
    zt_AboutAppVC *about_vc = nil;
    about_vc = (zt_AboutAppVC*)[[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_APP_ABOUT_VC];
    if (about_vc != nil)
    {
        [self.navigationController pushViewController:about_vc animated:YES];
    }
}

- (void)m_stDfltsSwitchToggled:(UISwitch*)switchEle
{
    NSNumber *switchVal = [NSNumber numberWithBool:switchEle.on];
    [[NSUserDefaults standardUserDefaults] setObject:switchVal forKey:SETDEFAULTS_SETTINGS_KEY];
    [self setRestoreBtnStatus];
}

- (void)resstoreSTCComponents
{
    [self restoreSetDefaultsStatus];
}

- (void)restoreSetDefaultsStatus
{
    NSNumber *savedNumber = [[NSUserDefaults standardUserDefaults] objectForKey:SETDEFAULTS_SETTINGS_KEY];
    if (savedNumber != nil) {
        if ([savedNumber boolValue] == NO) {
            [m_stDfltsSwitch setOn:NO];
        } else {
            [m_stDfltsSwitch setOn:YES];
        }
    } else {
        [m_stDfltsSwitch setOn:NO];
    }
}


- (void) addResetToDefaultsButton
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 32)];
    
    self.tableView.tableHeaderView = headerView;
    restoreBtn = [[UIButton alloc] init];
    restoreBtn.backgroundColor = headerView.backgroundColor;
    [restoreBtn addTarget:self action:@selector(restoreToDefaultValues) forControlEvents:UIControlEventTouchUpInside];
    [restoreBtn setTitle:@" Reset Defaults " forState:UIControlStateNormal];
    [headerView addSubview:restoreBtn];
    
    restoreBtn.layer.cornerRadius = 3.0;
    restoreBtn.layer.borderWidth = 2.0;
    
    restoreBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *restoreBtnWidth = [NSLayoutConstraint constraintWithItem:restoreBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0];
    
    NSLayoutConstraint *restoreBtnCenter = [NSLayoutConstraint constraintWithItem:restoreBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    NSLayoutConstraint *restoreBtnConsTop = [NSLayoutConstraint constraintWithItem:restoreBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.0];
    
    [headerView addConstraint:restoreBtnWidth];
    [headerView addConstraint:restoreBtnCenter];
    [headerView addConstraint:restoreBtnConsTop];
    [self setRestoreBtnStatus];
    
    [headerView release];
}

- (void) enableResetToDefaultsButton
{
    UIColor *enabledColor = [UIColor colorWithRed:(3.0/255.0f) green:(125.0/255.0f) blue:(179.0/255.0f) alpha:1.0];
    
    [restoreBtn setTitleColor:enabledColor forState:UIControlStateNormal];
    restoreBtn.layer.borderColor = [enabledColor CGColor];
    restoreBtn.enabled = YES;
    restoreBtn.userInteractionEnabled = YES;
}

- (void) disableResetToDefaultsButton
{
    UIColor *disabledColor = [UIColor lightGrayColor];
    
    [restoreBtn setTitleColor:disabledColor forState:UIControlStateNormal];
    restoreBtn.layer.borderColor = [disabledColor CGColor];
    restoreBtn.enabled = NO;
    restoreBtn.userInteractionEnabled = NO;
}

- (void)restoreToDefaultValues
{
    m_swScannerDetection.on = YES;
    m_swNotificationAvailable.on = YES;
    m_swNotificationActive.on = YES;
    m_swNotificationBarcode.on = NO;
    m_stDfltsSwitch.on = NO;
    
    [self setOpModeValue:SBT_OPMODE_ALL];
    [[zt_ScannerAppEngine sharedAppEngine] configureOperationalMode:SBT_OPMODE_ALL];
    
    [self switchScannerDetectionValueChanged:m_swScannerDetection];
    [self switchNotificationAvailableValueChanged:m_swNotificationAvailable];
    [self switchNotificationActiveValueChanged:m_swNotificationActive];
    [self switchNotificationBarcodeValueChanged:m_swNotificationBarcode];
    [self m_stDfltsSwitchToggled:m_stDfltsSwitch];
    
    comProtocol.userInteractionEnabled = YES;
}

- (BOOL)didChangeDefaults
{
    if (m_swScannerDetection.on == YES && m_swNotificationAvailable.on == YES && m_swNotificationActive.on == YES && m_swNotificationBarcode.on == NO && m_cellOpModeBoth.accessoryType == UITableViewCellAccessoryCheckmark && m_stDfltsSwitch.on == NO){
        return false;
    } else {
        return true;
    }
}

- (void)setRestoreBtnStatus
{
    if ([self didChangeDefaults]) {
        [self enableResetToDefaultsButton];
    } else {
        [self disableResetToDefaultsButton];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)opModeValueChanged:(NSInteger)opmode
{
    [[NSUserDefaults standardUserDefaults] setInteger:opmode forKey:ZT_SETTING_OPMODE];
    [self setRestoreBtnStatus];
}

- (void)displayCurrentOpmode
{
    NSInteger op_mode = [[NSUserDefaults standardUserDefaults] integerForKey:ZT_SETTING_OPMODE];
    [self setOpModeValue:op_mode];
}

- (void)setOpModeValue:(NSInteger)opmode
{
    switch (opmode)
    {
        case SBT_OPMODE_MFI:
            [m_cellOpModeMFI setAccessoryType:UITableViewCellAccessoryCheckmark];
            [m_cellOpModeBTLE setAccessoryType:UITableViewCellAccessoryNone];
            [m_cellOpModeBoth setAccessoryType:UITableViewCellAccessoryNone];
            break;
        case SBT_OPMODE_BTLE:
            [m_cellOpModeMFI setAccessoryType:UITableViewCellAccessoryNone];
            [m_cellOpModeBTLE setAccessoryType:UITableViewCellAccessoryCheckmark];
            [m_cellOpModeBoth setAccessoryType:UITableViewCellAccessoryNone];
            break;
        case SBT_OPMODE_ALL:
            [m_cellOpModeMFI setAccessoryType:UITableViewCellAccessoryNone];
            [m_cellOpModeBTLE setAccessoryType:UITableViewCellAccessoryNone];
            [m_cellOpModeBoth setAccessoryType:UITableViewCellAccessoryCheckmark];
            break;
    }
    
    if (opmode != [[NSUserDefaults standardUserDefaults] integerForKey:ZT_SETTING_OPMODE]) {
        [self opModeValueChanged:opmode];
    }
}

- (IBAction)switchScannerDetectionValueChanged:(id)sender
{
    BOOL value = [m_swScannerDetection isOn];
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_SCANNER_DETECTION];
    [[zt_ScannerAppEngine sharedAppEngine] enableScannersDetection:value];
    [[zt_ScannerAppEngine sharedAppEngine] enableBluetoothScannerDiscovery:value];
    [self setRestoreBtnStatus];
}


- (IBAction)switchNotificationAvailableValueChanged:(id)sender
{
    BOOL value = [m_swNotificationAvailable isOn];
#ifdef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_NOTIFICATION_AVAILABLE];
#else /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_EVENT_AVAILABLE];
    [[zt_ScannerAppEngine sharedAppEngine] configureNotificationAvailable:value];
    if (value == YES)
    {
        /*
         to raise notifications that were missed due to disabled notification
         (see description in zt_ScannerAppEngine::raiseDeviceNotificationsIfNeeded)
        */
        [[zt_ScannerAppEngine sharedAppEngine] raiseDeviceNotificationsIfNeeded];
    }
#endif /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [self setRestoreBtnStatus];
}

- (IBAction)switchNotificationActiveValueChanged:(id)sender
{
    BOOL value = [m_swNotificationActive isOn];
#ifdef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_NOTIFICATION_ACTIVE];
#else /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_EVENT_ACTIVE];
    [[zt_ScannerAppEngine sharedAppEngine] configureNotificationActive:value];
    if (value == YES)
    {
        /*
         to raise notifications that were missed due to disabled notification
         (see description in zt_ScannerAppEngine::raiseDeviceNotificationsIfNeeded)
         */
        [[zt_ScannerAppEngine sharedAppEngine] raiseDeviceNotificationsIfNeeded];
    }
#endif /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [self setRestoreBtnStatus];
}

- (IBAction)switchNotificationBarcodeValueChanged:(id)sender
{
    BOOL value = [m_swNotificationBarcode isOn];
#ifdef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_NOTIFICATION_BARCODE];
#else /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_EVENT_BARCODE];
    [[zt_ScannerAppEngine sharedAppEngine] configureNotificationBarcode:value];
#endif /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [self setRestoreBtnStatus];
}

- (IBAction)switchNotificationImageValueChanged:(id)sender
{
    BOOL value = [m_swNotificationImage isOn];
#ifdef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_NOTIFICATION_IMAGE];
#else /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_EVENT_IMAGE];
    [[zt_ScannerAppEngine sharedAppEngine] configureNotificationImage:value];
#endif /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
}

- (IBAction)switchNotificationVideoValueChanged:(id)sender
{
    BOOL value = [m_swNotificationVideo isOn];
#ifdef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_NOTIFICATION_VIDEO];
#else /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_EVENT_VIDEO];
    [[zt_ScannerAppEngine sharedAppEngine] configureNotificationVideo:value];
#endif /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
}

#pragma mark - Table view data source
/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return SECTION_TOTAL;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section)
    {
        case SECTION_COMM_MODE:
            return APP_SETTINGS_TABLE_ROW_3;
        case SECTION_DETECTION:
            return APP_SETTINGS_TABLE_ROW_1;
        case SECTION_EVENTS:
#ifdef LOCAL_CONFIG_HIDE_IMAGE_VIDEO_EVENT_SWITCHES
            return APP_SETTINGS_TABLE_ROW_3;
#else
            return APP_SETTINGS_TABLE_ROW_5;
#endif
        case SECTION_BG_MODE:
#ifndef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
            return APP_SETTINGS_TABLE_ROW_1;
#else
            return APP_SETTINGS_TABLE_ROW_0;
#endif
        case SECTION_STC:
            return APP_SETTINGS_TABLE_ROW_1;
        default:
            return APP_SETTINGS_TABLE_ROW_0;
    }
    return APP_SETTINGS_TABLE_ROW_0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_COMM_MODE: /* opmode */
            return @"Communication mode";
        case SECTION_DETECTION: /* detection */
            return @"Scanner Discovery";
        case SECTION_EVENTS: /* events  */
            return @"Background Notifications";
        case SECTION_STC:
            return @"Scan To Connect";
        case SECTION_BG_MODE: /* background mode */
#ifndef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
            return @"Background mode";
#else
            return nil;
#endif
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if(section == SECTION_BG_MODE)
    {
#ifndef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
        return [super tableView:tableView heightForHeaderInSection:section];
#else
        return 0.1;
#endif
        
    }
    else
    {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if(section == SECTION_BG_MODE)
    {
#ifndef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
        return [super tableView:tableView heightForHeaderInSection:section];
#else
        return 0.1;
#endif
    }
    else
    {
        return [super tableView:tableView heightForFooterInSection:section];
    }
}

#pragma mark - Table view delegate
/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == SECTION_COMM_MODE) /* op mode section */
    {
        /* TBD: set op mode for particular scanner */
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell != nil)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            int op_mode = 0;
            if ([cell isEqual:m_cellOpModeMFI] == YES)
            {
                op_mode = SBT_OPMODE_MFI;
            }
            else if ([cell isEqual:m_cellOpModeBTLE] == YES)
            {
                op_mode = SBT_OPMODE_BTLE;
            }
            else if ([cell isEqual:m_cellOpModeBoth] == YES)
            {
                op_mode = SBT_OPMODE_ALL;
            }
            
            [self setOpModeValue:op_mode];
            [[zt_ScannerAppEngine sharedAppEngine] configureOperationalMode:op_mode];
        }
        for (int idx = 0; idx < 3; idx++)
        {
            if (idx != [indexPath row])
            {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                if (cell != nil)
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
    }
    
#ifndef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
    if ([indexPath section] == SECTION_BG_MODE)
    {
        if ([indexPath row] == 0)
        {
            /* Background notifications */
            zt_AppSettingsBackgroundVC *notifications_vc = nil;
            
            notifications_vc = (zt_AppSettingsBackgroundVC*)[[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_APP_SETTINGS_BACKGROUND_VC];
            
            if (notifications_vc != nil)
            {
                [self.navigationController pushViewController:notifications_vc animated:YES];
                /* notifications_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
            }

        }
    }
#endif
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (SETDEFAULT_STATUS)setDefaultStatus
{
    if (m_stDfltsSwitch.isOn) {
        return SETDEFAULT_YES;
    } else {
        return SETDEFAULT_NO;
    }
}

@end
