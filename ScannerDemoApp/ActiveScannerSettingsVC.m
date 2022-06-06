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
 *  Description:  ActiveScannerSettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ActiveScannerSettingsVC.h"
#import "SymbologiesVC.h"
#import "config.h"
#import "ScannerAppEngine.h"
#import "ActiveScannerVC.h"
#import "BeeperSettingsVC.h"
#import "UpdateFirmwareVC.h"
#import "RMDAttributes.h"
#import "VirtualTetherTableViewController.h"
#import "NSString+Contain.h"

@interface zt_ActiveScannerSettingsVC ()

@end

@implementation zt_ActiveScannerSettingsVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_ScannerID = -1;
        m_HideBeeperSettings = NO;
    }
    return self;
}

- (void)dealloc
{
    if (activityView != nil)
    {
        [activityView release];
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    activityView = [[zt_AlertView alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (m_ScannerID == -1)
    {
        m_ScannerID = [(zt_ActiveScannerVC*)self.tabBarController getScannerID];
        SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:m_ScannerID];
        if ([[scanner_info getScannerName] containsSubString:SST_SCANNER_MODEL_SSI_CS4070])
        {
            m_HideBeeperSettings = YES;
        }
    }
}

- (void)performActionScanEnable:(NSString*)param
{
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_SCAN_ENABLE aInXML:param aOutXML:nil forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:ZT_SCANNER_CANNOT_PERFORM_SCAN_ENABLE
                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:OK
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle ok action
                                        }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            [alert release];
                       }
                       );
    }
}

- (void)performActionScanDisable:(NSString*)param
{
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_SCAN_DISABLE aInXML:param aOutXML:nil forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:ZT_SCANNER_CANNOT_PERFORM_SCAN_DISABLE
                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:OK
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle ok action
                                        }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            [alert release];
                       }
                       );
    }
}
- (void)performActionAimON:(NSString*)param
{
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_AIM_ON aInXML:param aOutXML:nil forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:ZT_SCANNER_CANNOT_PERFORM_AIM_ON
                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:OK
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle ok action
                                        }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            [alert release];
                       }
                       );
    }
}

- (void)performActionAimOFF:(NSString*)param
{
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_AIM_OFF aInXML:param aOutXML:nil forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:ZT_SCANNER_CANNOT_PERFORM_AIM_OFF
                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:OK
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle ok action
                                        }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            [alert release];
                       }
                       );
    }
}

- (void)performActionVibrationFeedBack:(NSString*)param
{
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_VIBRATION_FEEDBACK aInXML:param aOutXML:nil forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:ZT_SCANNER_CANNOT_PERFORM_VIBRATION_FEEDBACK
                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:OK
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle ok action
                                        }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            [alert release];
                       }
                       );
    }
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
    // Return the number of rows in the section.
    switch (section)
    {
        case 0:
            return SETTINGS_TABLE_NO_OF_ROW;
        default:
            return SETTINGS_TABLE_DEFAULT_NO_OF_ROW;
    }

}

#pragma mark - Table view delegate
/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0)
    {
        if ([indexPath row] == 0) /* Symbologies */
        {
            zt_SymbologiesVC *symbologies_vc = nil;
            
            symbologies_vc = (zt_SymbologiesVC*)[[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_SCANNER_SYMBOLOGIES_VC];
            
            if (symbologies_vc != nil)
            {
                [symbologies_vc setScannerID:[(zt_ActiveScannerVC*)self.tabBarController getScannerID]];
                [self.navigationController pushViewController:symbologies_vc animated:YES];
                 /* symbologies_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
            }

        }
        else if ([indexPath row] == 1 /*&& NO == m_HideBeeperSettings*/) /* Beeper*/
        {
            zt_BeeperSettingsVC *beeper_vc = nil;
            
            beeper_vc = (zt_BeeperSettingsVC*)[[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_SCANNER_BEEPER_VC];
            
            if (beeper_vc != nil)
            {
                [beeper_vc setScannerID:[(zt_ActiveScannerVC*)self.tabBarController getScannerID]];
                [self.navigationController pushViewController:beeper_vc animated:YES];
                /* beeper_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
            }

        }
        else if ([indexPath row] == 2 /*(1 + (m_HideBeeperSettings == YES ? 0 : 1))*/ /* 3 */) /* enable scanning */
        {
            NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
            
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performActionScanEnable:) withObject:in_xml withString:nil];
        }
        else if ([indexPath row] == 3 /*(2 + (m_HideBeeperSettings == YES ? 0 : 1))*/ /* 4 */) /* disable scanning */
        {
            NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
            
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performActionScanDisable:) withObject:in_xml withString:nil];
        }
        else if ([indexPath row] == 4 /*(2 + (m_HideBeeperSettings == YES ? 0 : 1))*/ /* 4 */) /* disable scanning */
        {
            NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performActionAimON:) withObject:in_xml withString:nil];
        }
        else if ([indexPath row] == 5 /*(2 + (m_HideBeeperSettings == YES ? 0 : 1))*/ /* 4 */) /* disable scanning */
        {
            NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performActionAimOFF:) withObject:in_xml withString:nil];
        }
        else if ([indexPath row] == 6 /*(2 + (m_HideBeeperSettings == YES ? 0 : 1))*/ /* 4 */) /* disable scanning */
        {
            NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performActionVibrationFeedBack:) withObject:in_xml withString:nil];
        }
        
        else if ([indexPath row] == 7 /*(2 + (m_HideBeeperSettings == YES ? 0 : 1))*/ /* 4 */) /* disable scanning */
        {
            UpdateFirmwareVC *updateFW_vc = nil;
            
            updateFW_vc = (UpdateFirmwareVC*)[[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_SCANNER_FWUPDATE_DAT_VC];
            
            if (updateFW_vc != nil)
            {
                [updateFW_vc setScannerID:m_ScannerID];
                [self.navigationController pushViewController:updateFW_vc animated:YES];
            }
        }
        
        else if ([indexPath row] == 8)
        {
            NSString *inXml = [NSString stringWithFormat:@"%@%@%d%@%@%@%@%d%@%@%@%@", XML_TAG_INARGS_START, XML_TAG_SCANNERID_START, m_ScannerID, XML_TAG_SCANNERID_END, XML_TAG_CMDARGS_START, XML_TAG_ARGXML_START, XML_TAG_ATTRIBUTE_LIST_START, RMD_VIRTUAL_TETHER_ALARM_ENABLE, XML_TAG_ATTRIBUTE_LIST_END, XML_TAG_ARGXML_END, XML_TAG_CMDARGS_END, XML_TAG_INARGS_END];
            NSMutableString *result = [[NSMutableString alloc] init];
            [result setString:@""];
            SBT_RESULT sbtResult = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:inXml aOutXML:&result forScanner:m_ScannerID];
            if (sbtResult != SBT_RESULT_SUCCESS || ![self isAttributeValueReturned:result attributeIdValue:RMD_VIRTUAL_TETHER_ALARM_ENABLE])
            {
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                    UIAlertController * alert = [UIAlertController
                                    alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                                     message:MESSAGE_VIRTUAL_TETHER_NOT_SUPPORTED
                                              preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction
                                        actionWithTitle:OK
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    //Handle ok action
                                                }];
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                    [alert release];
                }
                               );
            }
            else
            {
                VirtualTetherTableViewController *virtualTetherVC = nil;
                
                virtualTetherVC = (VirtualTetherTableViewController*)[[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_SCANNER_VIRTUAL_THETHER_VC];
                
                if (virtualTetherVC != nil)
                {
                    [virtualTetherVC setScannerID:m_ScannerID];
                    [self.navigationController pushViewController:virtualTetherVC animated:YES];
                }
            }
        }


    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //[cell setSelected:NO animated:YES];
    }
}

/// Check for the existance of an attribute in a given out xml retunred by get attribute
/// @param outXML Out xml returned by execution of get attribute command
/// @param attributeId Attribute id to be checked
/// @return True If attribute value retunred and false if not
- (BOOL)isAttributeValueReturned:(NSString*) outXML attributeIdValue:(int) attributeId
{
    BOOL success = FALSE;
    /* success */
    do {
        
        NSString* resultString = [outXML stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
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
            //attribute is found
            success = TRUE;
            break;
        }
        else
        {
            break;
        }
    } while (0);
    
    return success;
}

@end
