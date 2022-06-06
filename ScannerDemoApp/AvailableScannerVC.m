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
 *  Description:  AvailableScannerVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AvailableScannerVC.h"
#import "ScannersTableVC.h"
#import "config.h"

@interface zt_AvailableScannerVC ()

@end

@implementation zt_AvailableScannerVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_ScannerID = SBT_SCANNER_ID_INVALID;
        [[zt_ScannerAppEngine sharedAppEngine] addDevConnectionsDelegate:self];
        m_DidAppear = NO;
        m_ShallDisappear = NO;
        m_BusyIndicator = nil;
        m_IsBusy = NO;
    }
    return self;
}

- (void)dealloc
{
    [[zt_ScannerAppEngine sharedAppEngine] removeDevConnectiosDelegate:self];
    [m_lblScannerID release];
    [m_lblScannerName release];
    [m_lblScannerType release];
    
    if (m_BusyIndicator != nil)
    {
        [m_BusyIndicator stopAnimating];
        [m_BusyIndicator release];
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:@"Available Scanner"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    SbtScannerInfo *info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:m_ScannerID];
    
    if (info != nil)
    {
        /* TBD */
        [m_lblScannerID setText:[NSString stringWithFormat:@"%d", [info getScannerID]]];
        switch ([info getConnectionType])
        {
            case SBT_CONNTYPE_MFI:
                [m_lblScannerType setText:@"MFi"];
                [m_lblScannerName setText:[NSString stringWithFormat:@"%@ (%@)", [info getScannerName], [[zt_ScannerAppEngine sharedAppEngine] getScannerModelName:[info getScannerModel]]]];
                break;
            case SBT_CONNTYPE_BTLE:
                [m_lblScannerType setText:@"BT LE"];
                [m_lblScannerName setText:[NSString stringWithFormat:@"%@ (%@)", [info getScannerName], [[zt_ScannerAppEngine sharedAppEngine] getScannerModelName:[info getScannerModel]]]];
                break;
            default:
                [m_lblScannerType setText:@"Unknown"];
                [m_lblScannerName setText:@"Unknown"];
        }
    }
    else
    {
        [m_lblScannerID setText:@"Unknown"];
        [m_lblScannerName setText:@"Unknown"];
        [m_lblScannerType setText:@"Unknown"];
    }
    
    if (m_BusyIndicator == nil)
    {
        m_BusyIndicator = [[UIActivityIndicatorView alloc]
                           initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
        [m_BusyIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        [m_BusyIndicator setColor:[UIColor redColor]];
        
        m_BusyIndicator.hidesWhenStopped = YES;
        
        [self.view addSubview:m_BusyIndicator];
    }
    
    m_BusyIndicator.center = self.view.center;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    m_DidAppear = YES;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        /* iphone */
        if (YES == m_ShallDisappear)
        {
            //[self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    m_DidAppear = NO;
}

- (void)setScannerID:(int)scannerID
{
    m_ScannerID = scannerID;
}

- (int)getScannerID
{
    return m_ScannerID;
}

- (void)btnConnectPressed
{
    if (NO == m_IsBusy)
    {
        [m_BusyIndicator startAnimating];
        m_IsBusy = YES;
        [self performSelectorInBackground:@selector(establishCommunicationSession) withObject:nil];
    }
}

- (void)establishCommunicationSession
{
    [[zt_ScannerAppEngine sharedAppEngine] connect:m_ScannerID];
    [m_BusyIndicator stopAnimating];
    m_IsBusy = NO;
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
    if (scannerID == m_ScannerID)
    {
        /*
         // All alerts are in ScannerAppEngine
        UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:MOT_SCANNER_APP_NAME
                          message:@"Available scanner has disappeared"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        [alert show];
        [alert release];
         */
    
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            /* iphone */
            
            /* 
             nrv364:
                - nested pop animation results in corrupted navigation bar;
                - example:
                    - active vc is presented
                    - active scanner disappears
                    - processing of sessionTerminated notification results in:
                        - popping active VC;
                        - pushing available VC by ScannersTableVC
                    - processing of disappeared notification results in:
                        - popping available VC (and available VC has not been loaded yet)
             */
            
            [self.navigationController popViewControllerAnimated:NO];

            /*
            if (m_DidAppear == YES)
            {
                [self.navigationController popViewControllerAnimated:NO];
            }
            else
            {
                m_ShallDisappear = YES;
            }
            */
        }
        else
        {
            /* ipad */
            /* do nothing; all logic is in ScannersTableVC */
        }
        
        return YES; /* we have processed the notification */
    }
    return NO; /* we have not processed the notification */
}

- (BOOL)scannerHasConnected:(int)scannerID
{
    if (scannerID == m_ScannerID)
    {
        /*
         // All alerts are in ScannerAppEngine
        UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:MOT_SCANNER_APP_NAME
                          message:@"Communication session has been established"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        [alert show];
        [alert release];
         */
    
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            /* iphone */
            NSArray* vc = [self.navigationController viewControllers];
            
            /* previous (back) vc -> should be scanners list vc */
            UIViewController *back_vc = [vc objectAtIndex:([vc count] - 2)];
            if ([back_vc isKindOfClass:[zt_ScannersTableVC class]] == YES)
            {
                /* after connection active vc will be shown with animation;
                 the animated poping will cause UI degradation */
                [self.navigationController popToViewController:back_vc animated:NO];
            }
        }
        else
        {
            /* ipad */
            /* do nothing; all logic is in ScannersTableVC */
        }
        return YES; /* we have processed the notification */
    }
    return NO; /* we have not processed the notification */
}

- (BOOL)scannerHasDisconnected:(int)scannerID
{
    /* does not matter */
    return NO; /* we have not processed the notification */
}

#pragma mark - Table view data source
/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 1;
        case 1:
            return 3;
        default:
            return 0;
    }
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 static NSString *CellIdentifier = @"Cell";
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate
/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //[cell setSelected:NO animated:YES];
    }
    
    if (([indexPath section] == 0) && ([indexPath row] == 0)) /* (0,0) ~ Connect Action */
    {
        [self btnConnectPressed];
    }
}

@end
