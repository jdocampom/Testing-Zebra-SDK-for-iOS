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
 *  Description:  BeeperSettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "BeeperSettingsVC.h"
#import "RMDAttributes.h"
#import "SbtSdkDefs.h"
#import "ScannerAppEngine.h"
#import "config.h"
#import "ScannerDemoAppDelegate.h"
@interface zt_BeeperSettingsVC ()

@end

@implementation zt_BeeperSettingsVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        m_SettingsRetrieved = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Beeper Settings"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (NO == m_SettingsRetrieved)
    {
        UITableViewCell *cell;
        for (int i = 0; i < 3; i++)
        {
            for (int j = 0; j < 2; j++)
            {
                cell = [[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                if (cell != nil)
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }

        [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(getBeeperSettings) withObject:nil withString:nil];
    }
}

- (void)setScannerID:(int)scanner_id
{
    m_ScannerID = scanner_id;
}

- (void)getBeeperSettings
{
    didStartDataRetrieving = YES;
    NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>%d,%d</attrib_list></arg-xml></cmdArgs></inArgs>", m_ScannerID, RMD_ATTR_BEEPER_VOLUME, RMD_ATTR_BEEPER_FREQUENCY];
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    [result setString:@""];
    if (!didStartDataRetrieving) {
        [self operationComplete];
        return;
    }
    
    
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:in_xml aOutXML:&result forScanner:m_ScannerID];
    
    if (SBT_RESULT_SUCCESS != res)
    {
        if (!didStartDataRetrieving) {
            [self operationComplete];
            return;
        }
        
        [NSThread sleepForTimeInterval:2.0];
        SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:in_xml aOutXML:&result forScanner:m_ScannerID];
        if (SBT_RESULT_SUCCESS != res)
        {
            [self operationComplete];
            if (!didStartDataRetrieving) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(),^{
                zt_ScannerDemoAppDelegate *appDelegate = (zt_ScannerDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
                if (self->alert) {
                                if (self->alert) {
                                    if (appDelegate.window.rootViewController.presentedViewController == self->alert)
                                    {
                                        [self->alert dismissViewControllerAnimated:FALSE completion:nil];
                                    }
                                }
                            }
                        
                            [self operationComplete];
                            
                            self->alert = [UIAlertController
                                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                                             message:BEEPER_SETTINGS_CANNOT_RETRIEVE_ALERT_MESSAGE
                                                      preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction* okButton = [UIAlertAction
                                                actionWithTitle:BEEPER_SETTINGS_CANNOT_RETRIEVE_ALERT_OK_TITLE
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            //Handle ok action
                                                        }];
                            [self->alert addAction:okButton];
                            [self presentViewController:self->alert animated:YES completion:nil];
                        });
            return;
        }
    }
    
    BOOL success = FALSE;
    
    /* success */
    do {
        
        if (!didStartDataRetrieving) {
            [self operationComplete];
            return;
        }
        NSString* res_str = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString* tmp = @"<attrib_list><attribute>";
        NSRange range = [res_str rangeOfString:tmp];
        NSRange range2;
        
        if ((range.location == NSNotFound) || (range.length != [tmp length]))
        {
            [self operationComplete];
            break;
        }
        
        res_str = [res_str substringFromIndex:(range.location + range.length)];
        
        tmp = @"</attribute></attrib_list>";
        range = [res_str rangeOfString:tmp];
        
        if ((range.location == NSNotFound) || (range.length != [tmp length]))
        {
            [self operationComplete];
            break;
        }
        
        range.length = [res_str length] - range.location;
        
        res_str = [res_str stringByReplacingCharactersInRange:range withString:@""];
        
        NSArray *attrs = [res_str componentsSeparatedByString:@"</attribute><attribute>"];
        
        if ([attrs count] == 0)
        {
            [self operationComplete];
            break;
        }
        
        NSString *attr_str;
        
        int attr_id;
        int attr_val;
        int row_id;
        int section_id;
        
        for (NSString *pstr in attrs)
        {
            if (!didStartDataRetrieving) {
                [self operationComplete];
                return;
            }
            attr_str = pstr;
            
            tmp = @"<id>";
            range = [attr_str rangeOfString:tmp];
            if ((range.location != 0) || (range.length != [tmp length]))
            {
                [self operationComplete];
                break;
            }
            attr_str = [attr_str stringByReplacingCharactersInRange:range withString:@""];
            
            tmp = @"</id>";
            
            range = [attr_str rangeOfString:tmp];
            
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                [self operationComplete];
                break;
            }
            
            range2.length = [attr_str length] - range.location;
            range2.location = range.location;
            
            NSString *attr_id_str = [attr_str stringByReplacingCharactersInRange:range2 withString:@""];
            
            attr_id = [attr_id_str intValue];
            
            
            range2.location = 0;
            range2.length = range.location + range.length;
            
            attr_str = [attr_str stringByReplacingCharactersInRange:range2 withString:@""];
            
            tmp = @"<value>";
            range = [attr_str rangeOfString:tmp];
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            attr_str = [attr_str substringFromIndex:(range.location + range.length)];
            
            tmp = @"</value>";
            
            range = [attr_str rangeOfString:tmp];
            
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            
            range.length = [attr_str length] - range.location;
            
            attr_str = [attr_str stringByReplacingCharactersInRange:range withString:@""];
        
            attr_val = [attr_str intValue];
            
            if (RMD_ATTR_BEEPER_VOLUME == attr_id)
            {
                section_id = 0;
                if (RMD_ATTR_VALUE_BEEPER_VOLUME_LOW == attr_val)
                {
                    row_id = 0;
                }
                else if (RMD_ATTR_VALUE_BEEPER_VOLUME_MEDIUM == attr_val)
                {
                    row_id = 1;
                }
                else if (RMD_ATTR_VALUE_BEEPER_VOLUME_HIGH == attr_val)
                {
                    row_id = 2;
                }
                else
                {
                    break;
                }
            }
            else if (RMD_ATTR_BEEPER_FREQUENCY == attr_id)
            {
                section_id = 1;
                if (RMD_ATTR_VALUE_BEEPER_FREQ_LOW == attr_val)
                {
                    row_id = 0;
                }
                else if (RMD_ATTR_VALUE_BEEPER_FREQ_MEDIUM == attr_val)
                {
                    row_id = 1;
                }
                else if (RMD_ATTR_VALUE_BEEPER_FREQ_HIGH == attr_val)
                {
                    row_id = 2;
                }
                else
                {
                    break;
                }
            }
            else
            {
                break;
            }
            dispatch_async(dispatch_get_main_queue(),
                       ^{
                          UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row_id inSection:section_id]];
                                    if (cell != nil)
                                    {
                                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                                    }
                       }
                   );
       
        
        }
        
        success = TRUE;
        
    } while (0);
    
    if (FALSE == success)
    {
        if (!didStartDataRetrieving) {
            [self operationComplete];
            return;
        }
        dispatch_async(dispatch_get_main_queue(),
            ^{
                [self operationComplete];
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:ZT_SCANNER_CANNOT_RETRIEVE_BEEPER_SETTINGS
                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:OK
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle ok action
                                        }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            }
        );
        return;
    }
    else
    {
        m_SettingsRetrieved = TRUE;
    }
    didStartDataRetrieving = NO;
    [self operationComplete];
}

- (void)setBeeperSettings:(NSString*)param
{
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_SET aInXML:param aOutXML:nil forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
            ^{
                UIAlertController * alert = [UIAlertController
                                alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                                 message:ZT_SCANNER_CANNOT_APPLY_BEEPER_CONFIG
                                          preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:OK
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle ok action
                                            }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
        );
    }
    
    [self getBeeperSettings];
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
    // Return the number of rows in the section.
    switch (section)
    {
        case 0:
            return 3;
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
    char value = -1;
    int attr_id = -1;
    
    UITableViewCell *c;
    for (int i = 0; i < 3; i++)
    {
        c = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:[indexPath section]]];
        if (c != nil)
        {
            c.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    if ([indexPath section] == 0) /* Volume */
    {
        attr_id = RMD_ATTR_BEEPER_VOLUME;
        if ([indexPath row] == 0) /* Low */
        {
            value = RMD_ATTR_VALUE_BEEPER_VOLUME_LOW;
        }
        else if ([indexPath row] == 1) /* Medium */
        {
            value = RMD_ATTR_VALUE_BEEPER_VOLUME_MEDIUM;
        }
        else if ([indexPath row] == 2) /* High */
        {
            value = RMD_ATTR_VALUE_BEEPER_VOLUME_HIGH;
        }
    }
    else if ([indexPath section] == 1) /* Frequency */
    {
        attr_id = RMD_ATTR_BEEPER_FREQUENCY;
        if ([indexPath row] == 0) /* Low */
        {
            value = RMD_ATTR_VALUE_BEEPER_FREQ_LOW;
        }
        else if ([indexPath row] == 1) /* Medium */
        {
            value = RMD_ATTR_VALUE_BEEPER_FREQ_MEDIUM;
        }
        else if ([indexPath row] == 2) /* High */
        {
            value = RMD_ATTR_VALUE_BEEPER_FREQ_HIGH;
        }
    }
    
    if ((attr_id != -1) && (value != -1))
    {
        if (YES == m_SettingsRetrieved)
        {
            NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list><attribute><id>%d</id><datatype>B</datatype><value>%d</value></attribute></attrib_list></arg-xml></cmdArgs></inArgs>", m_ScannerID, attr_id, value];

            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(setBeeperSettings:) withObject:in_xml withString:nil];
        }
        else
        {
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:ZT_SCANNER_BEEPER_SETTINGS_NOT_RETRIEVED
                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:OK
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle ok action
                                        }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}


@end
