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
 *  Description:  MFiScannersTableVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import <ExternalAccessory/ExternalAccessory.h>
#import "ConnectionManager.h"
#import "MFiScannersTableVC.h"
#import "ActiveScannerVC.h"
#import "AppSettingsKeys.h"
#import "config.h"
#import "UpdateFirmwareVC.h"
#import "VirtualTetherTableViewController.h"
#import "AboutAppVC.h"
#import "ActiveScannerVC.h"

@interface MFiScannersTableVC () {
    BOOL didDisplayNoScannerFoundUI;
}

@property (nonatomic, retain) NSArray *m_tableData;
@end

@implementation MFiScannersTableVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_EmptyDeviceList = YES;
        
        self.m_tableData = [[NSArray alloc] init];
        
        m_CurrentScannerActive = NO;
        m_CurrentScannerId = SBT_SCANNER_ID_INVALID;
        
        m_btnUpdateDevList = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(btnUpdateScannersListPressed)];
        
        [[zt_ScannerAppEngine sharedAppEngine] addDevListDelegate:self];
        [[zt_ScannerAppEngine sharedAppEngine] addDevConnectionsDelegate:self];

    }
    return self;
}

- (void)dealloc
{
    [[zt_ScannerAppEngine sharedAppEngine] removeDevListDelegate:self];
    [[zt_ScannerAppEngine sharedAppEngine] removeDevConnectiosDelegate:self];
    
    [self.tableView setDataSource:nil];
    [self.tableView setDelegate:nil];

    if (m_btnUpdateDevList != nil)
    {
        [m_btnUpdateDevList release];
    }
    
    if (self.m_tableData != nil)
    {
        [self.m_tableData release];
    }
    
    if (activityView != nil)
    {
        [activityView release];
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Initialize the connection manager
    [ConnectionManager sharedConnectionManager];
    [[self navigationItem] setTitle:ZT_SCANNER_PAGE_CONNECT_MFI_SCANNERS_TITLE];
    activityView = [[zt_AlertView alloc]init];
    UIBarButtonItem *aboutusButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:ABOUTUS_IMAGE] style:UIBarButtonItemStylePlain target:self action:@selector(aboutAction:)];
    [[self navigationItem] setRightBarButtonItem:aboutusButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /* just to reload data from app engine */
    
    [self scannersListHasBeenUpdated];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showActiveScannerVC:(NSNumber*)scannerID aBarcodeView:(BOOL)barcodeView aAnimated:(BOOL)animated
{
    int scanner_id = [scannerID intValue];
    
    m_CurrentScannerId = scanner_id;
    m_CurrentScannerActive = YES;
    ///Check if it's firmware update event
    if([[zt_ScannerAppEngine sharedAppEngine] firmwareDidUpdate] && [[zt_ScannerAppEngine sharedAppEngine] previousScannerId] == scanner_id) {
        
        zt_ActiveScannerVC *active_vc = [[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_ACTIVE_SCANNER_VC];
        
        if (active_vc != nil)
        {
            [active_vc setScannerID:scanner_id];
            [self.navigationController pushViewController:active_vc animated:NO];
            [active_vc showFirmwareUpdate:scanner_id];
        }
    } else {
        zt_ActiveScannerVC *active_vc = nil;
        
        active_vc = (zt_ActiveScannerVC*)[[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_ACTIVE_SCANNER_VC];
        
        
        if (active_vc != nil)
        {
            [active_vc setScannerID:scanner_id];

            [self.navigationController pushViewController:active_vc animated:animated];
            
            if (YES == barcodeView)
            {
                [active_vc showBarcodeList];
            }
            
            // active_vc is autoreleased object returned by instantiateViewControllerWithIdentifier
            // TBD: shouldn't be released, but without this is not deallocated
            [active_vc release];
        }
    }
}


/// Show virtual tether ui on alarm event
-(void)showVirtualTetherUI{
    
    VirtualTetherTableViewController *virtual_tether_vc = (VirtualTetherTableViewController*)[[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_SCANNER_VIRTUAL_THETHER_VC];
    
    if (virtual_tether_vc != nil)
    {
        [self.navigationController pushViewController:virtual_tether_vc animated:NO];
    }
}

- (void)btnUpdateScannersListPressed
{
    /* 
     nrv364:
        just to avoid following situations:
        - active VC is shown
        - notifications are turned off
        - active disappears
        - new available appears
        - user press upd button
        - as appeared available scanner has the same id as disappeared
        active one, then in accordance with scannersListHasBeenUpdated
        availble VC will be presented
     */
    m_CurrentScannerId = SBT_SCANNER_ID_INVALID;
    m_btnUpdateDevList.enabled = false;
    [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(updateScannersList) withObject:nil withString:@"Updating..."];

    usleep(10*1000);
    [self scannersListHasBeenUpdated];
    
}

- (void)updateScannersList
{
    [[zt_ScannerAppEngine sharedAppEngine] updateScannersList];
    m_btnUpdateDevList.enabled = true;
}

/* ###################################################################### */
/* ########## IScannerAppEngineDevListDelegate Protocol implementation ## */
/* ###################################################################### */
- (BOOL)scannersListHasBeenUpdated
{
    [[self tableView] reloadData];
    
    NSArray *allScannersListArray = [[zt_ScannerAppEngine sharedAppEngine] getAvailableScannersList];
    NSMutableArray *fillterMFI = [[NSMutableArray alloc] init];
    for (int i = 0; i < allScannersListArray.count; i++) {
        SbtScannerInfo *info = [allScannersListArray objectAtIndex:(int)i];
        if ([info getConnectionType] == SBT_CONNTYPE_MFI)
        {
            [fillterMFI addObject:info];
        }
    }
    self.m_tableData = fillterMFI;
    [[self tableView] reloadData];
    
    if ([self.m_tableData count] > 0)
    {
        /* determine actual status of previously selected scanner */
        NSArray *lst = self.m_tableData;
        BOOL found = NO;
        int selected_scanner_idx = 0;
        SbtScannerInfo *info = nil;
        for (int i = 0; i < [lst count]; i++)
        {
            info = (SbtScannerInfo*)[lst objectAtIndex:i];

            if ([info isActive])
            {
                /* previously selected scanner is still at least available */
                /* get new idx of previously selected scanner */
                selected_scanner_idx = i;
                found = YES;
                break;
            }
        }
        
        if (YES == found)
        {
            //delegate event is not triggered when selecting row programatically */
            info = (SbtScannerInfo*)[lst objectAtIndex:selected_scanner_idx];
        }
    }
    else
    {
        m_CurrentScannerId = SBT_SCANNER_ID_INVALID;
    }
    
    return YES;
}

#pragma mark - Table view data source
/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [self.m_tableData count];
    if (count == 0)
    {
        count = 1;
        m_EmptyDeviceList = YES;
        m_CurrentScannerId = SBT_SCANNER_ID_INVALID;
    }
    else
    {
        m_EmptyDeviceList = NO;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ActiveScannerCellIdentifier = @"ActiveScannerCell";
    static NSString *AvailableScannerCellIdentifier = @"AvailableScannerCell";
    static NSString *NoScannerCellIdentifier = @"NoScannerCell";
    
    UITableViewCell *cell = nil;
    
    if (m_EmptyDeviceList == NO)
    {
        SbtScannerInfo *info = [self.m_tableData objectAtIndex:(int)[indexPath row]];
                    
            if ([info isActive] == YES)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:ActiveScannerCellIdentifier];
                if (cell == nil)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ActiveScannerCellIdentifier];
                }
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",@"\u2713",[info getScannerName]];
            }
            else
            {
                cell = [tableView dequeueReusableCellWithIdentifier:AvailableScannerCellIdentifier];
                if (cell == nil)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AvailableScannerCellIdentifier];
                }
                
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",@"\u2001",[info getScannerName]];
            }
            
            [cell.detailTextLabel setHidden:true];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:NoScannerCellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NoScannerCellIdentifier];
        }
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.text = [NSString stringWithFormat:@"No device connected"];

    }
    return cell;
}


#pragma mark - Table view delegate
/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell != nil)
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }

    if (m_EmptyDeviceList == NO)
    {
        SbtScannerInfo *info = [self.m_tableData objectAtIndex:(int)[indexPath row]];
        
        if ([info isActive] == YES)
        {
            [self showActiveScannerVC:[NSNumber numberWithInt:[info getScannerID]] aBarcodeView:NO aAnimated:YES];
        }
        else
        {
            // attempt to connect to selected scanner
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(connectToScanner:) withObject:info withString:@"Connecting..."];
        }
    }
}

- (void) connectToScanner :(SbtScannerInfo *)scannerInfo
{
    [[ConnectionManager sharedConnectionManager] connectDeviceUsingScannerId:[scannerInfo getScannerID]];
}

/* ###################################################################### */
/* ########## IScannerAppEngineDevConnectionsDelegate Protocol implementation ## */
/* ###################################################################### */
- (BOOL)scannerHasAppeared:(int)scannerID
{
    /* does not matter */
    return NO; /* we have not processed the notification */
}

- (BOOL)scannerHasDisappeared:(int)scannerID
{
    /* does not matter */
    return NO; /* we have not processed the notification */
}

- (BOOL)scannerHasConnected:(int)scannerID
{
    
    SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:scannerID];
    
    if ([scanner_info getConnectionType] == SBT_CONNTYPE_BTLE)
    {
        return  NO;
    }
    
    ///Scanner auto reconnect to check virutal tether alarm
    if ([[ConnectionManager sharedConnectionManager] getConnectedScannerId] == scannerID)
    {
        [[ConnectionManager sharedConnectionManager] scannerReconnectedOnVirtualTetherAlarm];
    }
    
    [self showActiveScannerVC:[NSNumber numberWithInt:scannerID] aBarcodeView:NO aAnimated:YES];
    
    return YES; /* we have processed the notification */


}

- (BOOL)scannerHasDisconnected:(int)scannerID
{
    /* does not matter */
    return NO; /* we have not processed the notification */
}


@end
