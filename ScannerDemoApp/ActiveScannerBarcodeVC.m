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
 *  Description:  ActiveScannerBarcodeVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ActiveScannerBarcodeVC.h"
//#import "BarcodeEventVC.h"
#import "BarcodeTypes.h"
#import "config.h"
#import "ScannerAppEngine.h"
#import "ActiveScannerVC.h"
#import "DecodeEvent.h"
#import "BarcodeList.h"
#import "NSString+Contain.h"

@interface zt_ActiveScannerBarcodeVC ()
@end

@implementation zt_ActiveScannerBarcodeVC

static NSString *const kTitlePullTrigger = @"Pull Trigger";
static NSString *const kTitleReleaseTrigger = @"Release Trigger";
static NSString *const kTitleBarcodeMode = @"Switch to barcode mode";

- (id) initWithCoder:(NSCoder*) aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self != nil) {
        m_ScannerID = -1;
        m_HideModeSwitch = NO;
        m_HideReleaseTrigger = NO;
        m_BarcodeList = [[NSMutableArray alloc] init];
        activityView = [[zt_AlertView alloc]init];
    }
    return self;
}


- (void) dealloc {
    if (m_BarcodeList != nil) {
        [m_BarcodeList removeAllObjects];
        [m_BarcodeList release];
    }
    if (activityView != nil) {
        [activityView release];
    }
    [super dealloc];
}


- (void) viewDidLoad {
    [super viewDidLoad];
}


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear: animated];
}

- (void) viewDidAppear:(BOOL) animated {
    [super viewDidAppear: animated];
    if (m_ScannerID == -1) {
        m_ScannerID = [(zt_ActiveScannerVC*)self.tabBarController getScannerID];
        SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:m_ScannerID];
        /// Hide the unsupported mode switch scanners that do not support it.
        m_HideModeSwitch = YES;
        /// Hide the unsupported release trigger button for scanners that do not support it.
        if ([[scanner_info getScannerName]containsSubString: SST_SCANNER_MODEL_SSI_CS4070]) {
            m_HideReleaseTrigger = YES;
        } else {
            m_HideModeSwitch = YES;
        }
    }
    [self showBarcode];
}

- (void) showBarcode {
    NSArray *tmp_barcode_lst = [[zt_ScannerAppEngine sharedAppEngine] getScannerBarcodesByID:m_ScannerID];
    [m_BarcodeList removeAllObjects];
    [m_BarcodeList addObjectsFromArray: tmp_barcode_lst];
    UITableView *tb = [self tableView];
    if (tb != nil) {
        /// Show updated barcode list for this scanner.
        [tb reloadData];
        /// Scroll to top to show most recent barcode.
        [tb scrollRectToVisible: CGRectMake(SCROLL_REACT_TO_VISIBILE_X_ZERO, SCROLL_REACT_TO_VISIBILE_Y_ZERO, SCROLL_REACT_TO_VISIBILE_WIDTH_ONE, SCROLL_REACT_TO_VISIBILE_HEIGHT_ONE) animated: YES];
    }
}


- (void) performActionTriggerPull:(NSString*) param {
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand: SBT_DEVICE_PULL_TRIGGER aInXML: param aOutXML: nil forScanner: m_ScannerID];
    if (res != SBT_RESULT_SUCCESS) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController * alert = [UIAlertController alertControllerWithTitle: ZT_SCANNER_APP_NAME message: ZT_SCANNER_CANNOT_PERFORM_TRIGGER_PULL preferredStyle: UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle: OK style: UIAlertActionStyleDefault handler: ^(UIAlertAction * action) {
                /// Handle OK action.
            }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            [alert release];
        });
    }
}


- (void) performActionTriggerRelease:(NSString*) param {
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_RELEASE_TRIGGER aInXML: param aOutXML: nil forScanner: m_ScannerID];
    if (res != SBT_RESULT_SUCCESS) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController * alert = [UIAlertController alertControllerWithTitle: ZT_SCANNER_APP_NAME message: ZT_SCANNER_CANNOT_PERFORM_TRIGGER_RELEASE preferredStyle: UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle: OK style: UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                /// Handle OK action.
            }];
            [alert addAction: okButton];
            [self presentViewController: alert animated: YES completion: nil];
            [alert release];
        });
    }
}


- (void) performActionBarcodeMode:(NSString*) param {
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_CAPTURE_BARCODE aInXML: param aOutXML: nil forScanner: m_ScannerID];
    if (res != SBT_RESULT_SUCCESS) {
        dispatch_async(dispatch_get_main_queue(),  ^{
            UIAlertController * alert = [UIAlertController alertControllerWithTitle: ZT_SCANNER_APP_NAME message: ZT_SCANNER_CANNOT_PERFORM_SCANNER_MODE preferredStyle: UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle: OK style: UIAlertActionStyleDefault handler: ^(UIAlertAction * action) {
                /// Handle OK action.
            }];
            [alert addAction: okButton];
            [self presentViewController: alert animated: YES completion: nil];
            [alert release];
        });
    }
}


// MARK: - TableView Data Source

- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
    return 2;
}


- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
    switch (section) {
        case 0:
            return 3 - (YES == m_HideModeSwitch ? 1 : 0) - (YES == m_HideReleaseTrigger ? 1 : 0);
        case 1:
            if ([m_BarcodeList count] > 0) {
                return [m_BarcodeList count];
            } else {
                return 1;
            }
        default:
            return 0;
    }
}


- (NSString*) tableView:(UITableView*) tableView titleForHeaderInSection:(NSInteger) section {
    if (0 == section) {
        return @"Actions";
    } else if (1 == section) {
        return [NSString stringWithFormat: @"Barcode List: Count = %d", (unsigned int)[m_BarcodeList count]];
    }
    return @"Unknown";
}


- (UIView*) tableView:(UITableView*) tableView viewForHeaderInSection:(NSInteger) section {
    /// Add custom section header for the Barcode list section in the table.
    if (1 == section) {
        /// Specify component sizes...
        CGFloat headerWidth = self.tableView.frame.size.width;
        CGFloat headerHeight = 20.0f;
        CGFloat btnWidth = 60.0f;
        CGFloat btnHeight = 30.0f;
        /// Create custom view for section header.
        UITableViewHeaderFooterView *customHeaderView = [[[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, headerWidth, headerHeight)] autorelease];
        
        /* Create clear button */
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [clearButton setFrame:CGRectMake(headerWidth-btnWidth, 7.0f, btnWidth, btnHeight)];
        [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
        [clearButton setBackgroundColor:[UIColor clearColor]];
        [clearButton addTarget:self action:@selector(btnClearBarcodeList:) forControlEvents:UIControlEventTouchUpInside];
        [customHeaderView addSubview:clearButton];
        
        [clearButton setEnabled:[m_BarcodeList count] > 0 ? true : false];
        clearButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (@available(iOS 11, *)) {
          NSLayoutConstraint  *clearBtnConstraintRight = [NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:customHeaderView.safeAreaLayoutGuide attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10];
             [customHeaderView addConstraint:clearBtnConstraintRight];
        } else {
           NSLayoutConstraint *clearBtnConstraintRight = [NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:customHeaderView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10];
             [customHeaderView addConstraint:clearBtnConstraintRight];
        }
        
        NSLayoutConstraint *clearBtnConstraintBottom = [NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:customHeaderView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [customHeaderView addConstraint:clearBtnConstraintBottom];

        return customHeaderView;
    }
    
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (0 == [indexPath section]) /* action section */
    {
        static NSString *CellIdentifierAction = @"BarcodeActionCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierAction forIndexPath:indexPath];
    
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierAction];
        }
    
        switch ([indexPath row])
        {
            case 0:
                cell.textLabel.text = kTitlePullTrigger;
                break;
            case 1:
            {
                if (m_HideReleaseTrigger)
                {
                    cell.textLabel.text = kTitleBarcodeMode;
                }
                else
                {
                    cell.textLabel.text = kTitleReleaseTrigger;
                }
            }
                break;
            case 2:
                cell.textLabel.text = kTitleBarcodeMode;
                break;
            default:
                cell.textLabel.text = @"Unknown";
        }
    }
    else if (1 == [indexPath section]) /* barcode list section */
    {
        if ([m_BarcodeList count] > 0)
        {
            static NSString *CellIdentifierData = @"BarcodeDataCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierData forIndexPath:indexPath];
            
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierData];
            }
            
            cell.textLabel.text = [(zt_BarcodeData*)[m_BarcodeList objectAtIndex:([m_BarcodeList count] - 1 - [indexPath row])] getDecodeDataAsStringUsingEncoding:NSUTF8StringEncoding];
            
            cell.detailTextLabel.text = get_barcode_type_name([(zt_BarcodeData*)[m_BarcodeList objectAtIndex:([m_BarcodeList count] - 1 - [indexPath row])] getDecodeType]);
        }
        else
        {
            static NSString *CellIdentifierNoData = @"BarcodeNoDataCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierNoData forIndexPath:indexPath];
            
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierNoData];
            }
            
            cell.textLabel.text = @"No barcode received";
            cell.detailTextLabel.text = nil;
        }
        
        [cell layoutIfNeeded];
    }
    
    return cell;
}

#pragma mark - Table view delegate
/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([indexPath section] == 0) /* actions section */
    {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *cellText = selectedCell.textLabel.text;
        
        if ([cellText isEqualToString:kTitlePullTrigger])
        {
            /* we are going to perform attempt of scanning */
            NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
            
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performActionTriggerPull:) withObject:in_xml withString:nil];
        }
        else if ([cellText isEqualToString:kTitleReleaseTrigger])
        {
            NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
            
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performActionTriggerRelease:) withObject:in_xml withString:nil];
        }
        else if ([cellText isEqualToString:kTitleBarcodeMode])
        {
            // Not supported
            NSLog(@"ERROR: Switch to barcode mode is currently unsupported.");
        }
    }
    else if (1 == [indexPath section]) /* barcode list section */
    {
//        if ([m_BarcodeList count] > 0)
//        {
//            zt_BarcodeEventVC *barcode_vc = (zt_BarcodeEventVC*)[[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_BARCODE_EVENT_VC];
//
//            if (barcode_vc != nil)
//            {
//                zt_BarcodeData *decode_event = (zt_BarcodeData*)[m_BarcodeList objectAtIndex:([m_BarcodeList count] - 1 - [indexPath row])];
//                [barcode_vc configureAsChild];
//                [barcode_vc setBarcodeEventData:decode_event fromScanner:m_ScannerID];
//                [self.navigationController pushViewController:barcode_vc animated:YES];
//                /* barcode_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
//            }
//        }
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //[cell setSelected:NO animated:YES];
    }
}

/* Clear table containing the scanned barcode list */
- (IBAction)btnClearBarcodeList:(id)sender
{
    UIAlertController *popupMessageAlert = [UIAlertController alertControllerWithTitle:ACTIVE_SCANNER_BARCODE_ALERT_TITLE message:ACTIVE_SCANNER_BARCODE_ALERT_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:ACTIVE_SCANNER_BARCODE_ALERT_CANCEL style:UIAlertActionStyleDefault handler:NULL];
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:ACTIVE_SCANNER_BARCODE_ALERT_CONTINUE style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
        [[zt_ScannerAppEngine sharedAppEngine] clearScannerBarcodesByID:m_ScannerID];
        [m_BarcodeList removeAllObjects];
        [self.tableView reloadData];
    }];
    [popupMessageAlert addAction:cancelAction];
    [popupMessageAlert addAction:continueAction];
    [self presentViewController:popupMessageAlert animated:YES completion:nil];
}

@end
